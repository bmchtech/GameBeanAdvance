module host.sdl;

import bindbc.sdl;
import std.stdio;
import std.conv;

import gba;
import cputrace;
import logger;

import apu;

import core.sync.mutex;

class GameBeanSDLHost {
    // extern (C) {
    //     static void fill_audio(void* userdata, ubyte* stream, int len) nothrow {
    //         AudioData* audio_data = cast(AudioData*) userdata;

    //         /* Only play if we have data left */
    //         if (audio_data.bytes_left == 0)
    //             return;

    //         len = (len > audio_data.bytes_left ? audio_data.bytes_left : len);

    //         try {
    //             writefln("Mixing... %d %d", audio_data.bytes_left, len);
    //         } catch (Exception e) {

    //         }

    //         for (int i = 0; i < len; i++)
    //             stream[i] = audio_data.chunk[i];
            
    //         for (int i = len; i < audio_data.total_bytes; i++)
    //             audio_data.chunk[i - len] = audio_data.chunk[i];

    //         audio_data.bytes_left -= len;
    //     }
    // }

    Mutex gba_batch_enable_mutex;
    bool gba_batch_enable = false;

    this(GBA gba, int screen_scale) {
        this.gba = gba;
        this.screen_scale = screen_scale;
        gba_batch_enable_mutex = new Mutex();
    }

    void init() {
        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0)
            assert(0, "sdl init failed");

        window = SDL_CreateWindow("GameBean Advance", SDL_WINDOWPOS_UNDEFINED,
                SDL_WINDOWPOS_UNDEFINED, GBA_SCREEN_WIDTH * screen_scale,
                GBA_SCREEN_HEIGHT * screen_scale, SDL_WindowFlags.SDL_WINDOW_SHOWN);
        assert(window !is null, "sdl window init failed!");

        renderer = SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_PRESENTVSYNC);

        screen_tex = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888,
                SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING,
                GBA_SCREEN_WIDTH, GBA_SCREEN_HEIGHT);

        pixels = new uint[GBA_SCREEN_WIDTH* GBA_SCREEN_HEIGHT];

        SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest"); // scale with pixel-perfect interpolation

        SDL_AudioSpec wanted;
        SDL_AudioSpec received;

        /* Set the audio format */
        wanted.freq = 44100;
        wanted.format = AUDIO_S16LSB;
        wanted.channels = 1;    /* 1 = mono, 2 = stereo */
        wanted.samples = 1024;  /* Good low-latency value for callback */
        wanted.callback = &apu.audiobuffer.callback;
        wanted.userdata = apu.audiobuffer.get_audio_data();

        // audio_data.chunk = new ubyte[44100 * 2];
        // audio_data.pos = audio_data.chunk.ptr;
        // audio_data.bytes_left = 44100;
        // audio_data.total_bytes = 44100;
        // audio_data.verification = VERIFICATION;

        // short[] buffer = new short[0x10000];
        // for (int i = 0; i < 0x10000; i++) {
            // buffer[i] = cast(short) (256.0 * (cast(double)(i % 200)) / 200.0);
        // }

        // push_to_buffer(buffer);
        /* Open the audio device, forcing the desired format */
        int output = SDL_OpenAudio(&wanted, &received);
        if (output < 0) {
            writefln("Couldn't open audio: %s\n", SDL_GetError());
        } else {
            writefln("connected. %d %d %d %s", received.freq, received.channels, received.samples, received.format);
            writefln("[SDL] Audio driver: %s\n", SDL_GetCurrentAudioDriver());
        }

        gba.set_internal_sample_rate(16_000_000 / received.freq);
        this.sample_rate          = received.freq;
        this.samples_per_callback = received.samples;

        writeln("Complete.");
    }

    void run() {
        readln();
        running = true;

        int num_batches       = this.sample_rate / this.samples_per_callback;
        enum cycles_per_second = 16_780_000 / 4;
        this.cycles_per_batch  = 2 * cycles_per_second / num_batches;
        writefln("%d batches per second, %d batches per cycle.", num_batches, cycles_per_batch);
        writefln("sample rate: %d, samples_per_callback: %d", sample_rate, samples_per_callback);

        set_audio_buffer_callback(&cycle_gba);
        SDL_PauseAudio(0);

        // // each cycle() does 4 cpu cycles
        // enum cycles_per_second = 16_000_000 / 4;
        // enum gba_cycle_batch_sz = 1024;
        // enum nsec_per_cycle = 1_000_000_000 / cast(double) cycles_per_second;
        // // 62.5 nsec per cycle: this is nsec per batch
        // enum nsec_per_gba_cyclebatch = cast(long) (nsec_per_cycle * gba_cycle_batch_sz);
        // // enum nsec_per_gba_cyclebatch = 1; // unlock speed
        // // enum nsec_per_gba_cyclebatch = 50_000; // medium locking

        // // 16.6666 ms
        enum nsec_per_frame = 16_666_660;

        auto stopwatch = new NSStopwatch();
        // long clockfor_cycle = 0;
        long clockfor_frame = 0;
        // auto total_cycles = 0;

        enum sec_per_log = 1;
        enum nsec_per_log = sec_per_log * 1_000_000_000;
        enum cycles_per_log = cycles_per_second * sec_per_log;
        long clockfor_log = 0;
        ulong cycles_since_last_log = 0;

        // writefln("ns for single: %s, ns for batch: %s, ", nsec_per_cycle, nsec_per_gba_cyclebatch);

        while (running) {
            long elapsed = stopwatch.update();
            clockfor_frame += elapsed;
            clockfor_log   += elapsed;

        //     mixin(VERBOSE_LOG!(`3`, `format("elapsed: %s ns", elapsed)`));

        //     // GBA cycle batching
        //     if (clockfor_cycle > nsec_per_gba_cyclebatch) {
        //         for (int i = 0; i < gba_cycle_batch_sz; i++) {
        //             mixin(VERBOSE_LOG!(`3`, `format("pc: %00000000x (cycle %s)",
        //                     *gba.cpu.pc, total_cycles + i)`));
        //             gba.cycle();
        //         }
        //         total_cycles += gba_cycle_batch_sz;
        //         cycles_since_last_log += gba_cycle_batch_sz;
        //         mixin(VERBOSE_LOG!(`3`, `format("CYCLE[%s]", gba_cycle_batch_sz)`));
        //         clockfor_cycle -= nsec_per_gba_cyclebatch;
        //     }

        //     // 60Hz frame refresh (mod 267883)
            if (clockfor_frame > nsec_per_frame) {
                frame();
                mixin(VERBOSE_LOG!(`3`, `format("FRAME %s", frame_count)`));
                clockfor_frame = 0;
            }

            audio_data.mutex.lock();
                if (audio_data.buffer_offset < samples_per_callback * 3) {
                    // writefln("Cycling");
                    for (int i = 0; i < cycles_per_batch; i++) {
                        gba.cycle();
                    }
                    // gba_batch_enable = false;
                    cycles_since_last_log += cycles_per_batch;
                    // writefln("Cycled");
                }
            audio_data.mutex.unlock();

        //     // writefln("NSEC: %s  |  %s OF %s", total_time.total!"nsecs", clockfor_log, nsec_per_log);
            if (clockfor_log > nsec_per_log) {
                immutable auto cpu_cycles_since_last_log = cycles_since_last_log;
                double avg_speed = (cast(double) cpu_cycles_since_last_log / cast(
                        double) cycles_per_log);
                mixin(VERBOSE_LOG!(`1`, `format("AVG SPEED: [%s/%s] = %s",
                        cpu_cycles_since_last_log, cycles_per_log, avg_speed)`));
                clockfor_log = 0;
                cycles_since_last_log = 0;
            }

            // Thread.sleep(0.msecs);
        }
    }

    void cycle_gba() {
        // writefln("Enabling");
        bool acquired = gba_batch_enable_mutex.tryLock();
        if (acquired) {
            gba_batch_enable = true;
            gba_batch_enable_mutex.unlock();
        }
    }

    void exit() {
        SDL_DestroyWindow(window);
        SDL_Quit();
        running = false;
    }

    int frame_count;
    GBA gba;
    bool running;
    SDL_Window* window;
    SDL_Renderer* renderer;
    SDL_Texture* screen_tex;
    uint[] pixels;
    enum GBA_SCREEN_WIDTH = 240;
    enum GBA_SCREEN_HEIGHT = 160;
    int screen_scale;

    bool cpu_tracing_enabled = false;
    CpuTrace trace;

    void enable_cpu_tracing(int trace_length) {
        cpu_tracing_enabled = true;
        trace = new CpuTrace(gba.cpu, trace_length);
        Logger.singleton(trace);
    }

    void print_trace() {
        if (cpu_tracing_enabled)
            trace.print_trace();
    }

private:
    uint sample_rate;
    uint samples_per_callback;
    uint cycles_per_batch;

    void frame() {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_QUIT:
                exit();
                break;
            case SDL_KEYDOWN:
                on_input(event.key.keysym.sym, true);
                if (event.key.keysym.sym == SDL_Keycode.SDLK_ESCAPE) {
                    exit();
                }
                break;
            case SDL_KEYUP:
                on_input(event.key.keysym.sym, false);
                break;
            default:
                break;
            }
        }

        frame_count++;

        // sync from GBA video buffer
        for (int j = 0; j < GBA_SCREEN_HEIGHT; j++) {
            for (int i = 0; i < GBA_SCREEN_WIDTH; i++) {
                auto p = gba.memory.video_buffer[i][j];
                pixels[j * (GBA_SCREEN_WIDTH) + i] = p;
            }
        }

        SDL_RenderClear(renderer);

        // copy pixel buffer to texture
        auto px_vp = cast(void*) pixels;
        SDL_UpdateTexture(screen_tex, null, px_vp, GBA_SCREEN_WIDTH * 4);

        // copy texture to scren
        const SDL_Rect dest = SDL_Rect(0, 0, GBA_SCREEN_WIDTH * screen_scale, GBA_SCREEN_HEIGHT * screen_scale);
        SDL_RenderCopy(renderer, screen_tex, null, &dest);

        // render present
        SDL_RenderPresent(renderer);
    }

    enum KEYMAP = [
            SDL_Keycode.SDLK_z : GBAKey.A, // A
            SDL_Keycode.SDLK_x : GBAKey.B, // B
            SDL_Keycode.SDLK_TAB : GBAKey.SELECT, // SELECT
            SDL_Keycode.SDLK_RETURN : GBAKey.START, // START
            SDL_Keycode.SDLK_RIGHT : GBAKey.RIGHT, // RIGHT
            SDL_Keycode.SDLK_LEFT : GBAKey.LEFT, // LEFT
            SDL_Keycode.SDLK_UP : GBAKey.UP, // UP
            SDL_Keycode.SDLK_DOWN : GBAKey.DOWN, // DOWN
            SDL_Keycode.SDLK_s
            : GBAKey.RIGHT, // R
            SDL_Keycode.SDLK_a : GBAKey.LEFT, // L
        ];

    void on_input(SDL_Keycode key, bool pressed) {
        if (key !in KEYMAP)
            return;
        auto gba_key = to!int(KEYMAP[key]);
        gba.key_input.set_key(cast(ubyte) gba_key, pressed);
    }
}
