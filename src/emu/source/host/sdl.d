module host.sdl;

import hw.gba;
import hw.apu;
import hw.cpu;

import diag.cputrace;
import diag.logger;

import util;

import bindbc.sdl;

import std.stdio;
import std.conv;

import core.sync.mutex;

version (Imgui) {
    import derelict.imgui.imgui;
}

__gshared GBA _gba;
__gshared int _samples_per_callback;
__gshared int _cycles_per_batch;

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
        _gba = gba;
        this.screen_scale = screen_scale;
        gba_batch_enable_mutex = new Mutex();
    }

    extern(C) int test(void* uwu) nothrow {
        return 0;
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
        wanted.channels = 2;    /* 1 = mono, 2 = stereo */
        wanted.samples = 1024;  /* Good low-latency value for callback */
        wanted.userdata = hw.apu.audiobuffer.get_audio_data();
        wanted.callback = &hw.apu.audiobuffer.callback;

        int output = SDL_OpenAudio(&wanted, &received);
        if (output < 0) {
            writefln("Couldn't open audio: %s\n", SDL_GetError());
        } else {
            writefln("connected. %d %d %d %s", received.freq, received.channels, received.samples, received.format);
            writefln("[SDL] Audio driver: %s\n", SDL_GetCurrentAudioDriver());
        }

        _gba.set_internal_sample_rate(16_780_000 / received.freq);
        this.sample_rate      = received.freq;
        _samples_per_callback = received.samples;

        version (Imgui) {
            writefln("Setting up imgui");
            
            loadSDL();
	        // DerelictImgui.load();
            // loadImGui();
            // loadOpenGL();
            igCreateContext();
            // ImGuiIO* io = igGetIO();
            // igStyleColorsDark(null);

            // ImGui_ImplSDL2_InitForOpenGL(window, null);

            // Setup Dear ImGui context
            // IMGUI_CHECKVERSION();
	        // DerelictImgui.load("cimgui.so");
            // igCreateContext();
            // ImGuiIO& io = ImGui::GetIO(); (void)io;

            // // Setup Dear ImGui style
            // ImGui::StyleColorsDark();

            // // Setup Platform/Renderer bindings
            // // window is the SDL_Window*
            // // context is the SDL_GLContext
            // ImGui_ImplSDL2_InitForOpenGL(window, context);
            // ImGui_ImplOpenGL3_Init();
        }

        writeln("Complete.");
    }

    void run() {
        running = true;

        int num_batches       = this.sample_rate / _samples_per_callback;
        enum cycles_per_second = 16_780_000;
        _cycles_per_batch  = cycles_per_second / num_batches;
        writefln("%d batches per second, %d batches per cycle.", num_batches, _cycles_per_batch);
        writefln("sample rate: %d, samples_per_callback: %d", sample_rate, _samples_per_callback);

        // set_audio_buffer_callback(&cycle_gba);
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
        enum msec_per_frame = 16;

        auto stopwatch = new NSStopwatch();
        // long clockfor_cycle = 0;
        long clockfor_frame = 0;
        // auto total_cycles = 0;

        enum sec_per_log = 1;
        enum nsec_per_log = sec_per_log * 1_000_000_000;
        enum msec_per_log = sec_per_log * 1_000;
        enum cycles_per_log = cycles_per_second * sec_per_log;
        long clockfor_log = 0;
        ulong cycles_since_last_log = 0;

        // writefln("ns for single: %s, ns for batch: %s, ", nsec_per_cycle, nsec_per_gba_cyclebatch);

        int fps = 0;
        ulong cycle_timestamp = 0;

        ulong start_timestamp = SDL_GetTicks();

        while (running) {
            ulong end_timestamp = SDL_GetTicks();
            ulong elapsed = end_timestamp - start_timestamp;
            start_timestamp = end_timestamp;

            clockfor_log   += elapsed;
            clockfor_frame += elapsed;

            while (_audio_data.buffer[0].offset < _samples_per_callback * 4) {
                _gba.cycle_at_least_n_times(_cycles_per_batch);
            }

            if (clockfor_frame > msec_per_frame) {
                clockfor_frame = 0;
                frame();
                fps++;
            }

            if (clockfor_log > msec_per_log) {
                ulong cycles_elapsed = _gba.scheduler.get_current_time() - cycle_timestamp;
                cycle_timestamp = _gba.scheduler.get_current_time();
                double speed = ((cast(double) cycles_elapsed) / (cast(double) cycles_per_second));
                // writefln("fps: %x", cast(char*) format("Speed: %f", speed));
                SDL_SetWindowTitle(window, cast(char*) ("FPS: " ~ format("%d", fps)));
                // SDL_SetWindowTitle(window, cast(char*) format("Speed: %f", speed));
                clockfor_log = 0;
                cycles_since_last_log = 0;
                fps = 0;
            }
        }
    }

    void exit() {
        SDL_DestroyWindow(window);
        SDL_Quit();
        
        running = false;
    }

    int frame_count;
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
        trace = new CpuTrace(_gba.cpu, trace_length);
        Logger.singleton(trace);
    }

    void print_trace() {
        if (cpu_tracing_enabled)
            trace.print_trace();
    }

    int counter = 0;
    float f = 0;

private:
    uint sample_rate;

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
                auto p = _gba.memory.video_buffer[i][j];
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

        version (Imgui) {
            igBegin("Hello, world!", null, cast(ImGuiWindowFlags)0);                          // Create a window called "Hello, world!" and append into it.

            igText("This is some useful text.");               // Display some text (you can use a format strings too)
            // igCheckbox("Demo Window", true);      // Edit bools storing our window open/close state
            // igCheckbox("Another Window", true);

            igSliderFloat("float", &f, 0.0f, 1.0f, null, 0);            // Edit 1 float using a slider from 0.0f to 1.0f
            //igColorEdit3("clear color", cast(float*)&clear_color.x); // Edit 3 floats representing a color

            if (igButton("Button", ImVec2(0,0)))                            // Buttons return true when clicked (most widgets return true when edited/activated)
                counter++;
            igSameLine(0,0);
            igText("counter = %d", counter);

            igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / igGetIO().Framerate, igGetIO().Framerate);
            igEnd();
        }
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
            : GBAKey.R, // R
            SDL_Keycode.SDLK_a : GBAKey.L, // L
        ];

    void on_input(SDL_Keycode key, bool pressed) {
        if (key !in KEYMAP)
            return;
        auto gba_key = to!int(KEYMAP[key]);
        _gba.key_input.set_key(cast(ubyte) gba_key, pressed);
    }
}
