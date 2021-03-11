module host.sdl;
import bindbc.sdl;
import std.stdio;
import gba;
import core.time : MonoTime, nsecs, msecs;
import std.conv;
import core.thread.osthread: Thread;

class GameBeanSDLHost {
    this(GBA gba, int screen_scale) {
        this.gba = gba;
        this.screen_scale = screen_scale;
    }

    void init() {
        if (SDL_Init(SDL_INIT_VIDEO) != 0)
            assert(0, "sdl init failed");

        window = SDL_CreateWindow("GameBean Advance", SDL_WINDOWPOS_UNDEFINED,
                SDL_WINDOWPOS_UNDEFINED, GBA_SCREEN_WIDTH * screen_scale,
                GBA_SCREEN_HEIGHT * screen_scale, SDL_WindowFlags.SDL_WINDOW_SHOWN);
        assert(window !is null, "sdl window init failed!");

        renderer = SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_PRESENTVSYNC);

        screen_tex = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888,
                SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING,
                GBA_SCREEN_WIDTH * screen_scale, GBA_SCREEN_HEIGHT * screen_scale);

        pixels = new uint[GBA_SCREEN_WIDTH * screen_scale * GBA_SCREEN_HEIGHT * screen_scale];
    }

    void run() {
        running = true;
        auto lastTicks = MonoTime.currTime();

        // each cycle() does 4 cpu cycles
        enum cycles_per_second = 16_000_000 / 4;
        enum gba_cycle_batch_sz = 1024;
        enum nsec_per_cycle = 1_000_000_000 / cast(double) cycles_per_second;
        // 62.5 nsec per cycle: this is nsec per batch
        // enum nsec_per_gba_cyclebatch = nsec_per_cycle * gba_cycle_batch_sz;
        enum nsec_per_gba_cyclebatch = 1; // unlock speed
        // enum nsec_per_gba_cyclebatch = 50_000; // medium locking

        // 16.6666 ms
        enum nsec_per_frame = 16_666_660;
        auto total_time = nsecs(0);
        long clock_cycle = 0;
        long clock_frame = 0;
        auto total_cycles = 0;

        // 2 seconds
        enum sec_per_log = 2;
        enum nsec_per_log = sec_per_log * 1_000_000_000;
        enum cycles_per_log = cycles_per_second * sec_per_log;
        long clock_log = 0;
        ulong cycles_since_last_log = 0;

        writefln("ns for single: %s, ns for batch: %s, ", nsec_per_cycle, nsec_per_gba_cyclebatch);

        while (running) {
            auto ticks = MonoTime.currTime();
            auto el = ticks - lastTicks;
            lastTicks = ticks;

            total_time += el;
            auto el_nsecs = el.total!"nsecs";
            mixin(VERBOSE_LOG!(`3`, `format("nsecs elapsed: %s", el_nsecs)`));

            clock_cycle += el_nsecs;
            clock_frame += el_nsecs;
            clock_log += el_nsecs;

            // GBA cycle batching
            if (clock_cycle > nsec_per_gba_cyclebatch) {
                for (int i = 0; i < gba_cycle_batch_sz; i++) {
                    mixin(VERBOSE_LOG!(`3`, `format("pc: %00000000x (cycle %s)",
                            *gba.cpu.pc, total_cycles + i)`));
                    gba.cycle();
                }
                total_cycles += gba_cycle_batch_sz;
                cycles_since_last_log += gba_cycle_batch_sz;
                mixin(VERBOSE_LOG!(`3`, `format("CYCLE[%s]", gba_cycle_batch_sz)`));
                clock_cycle = 0;
            }

            // 60Hz frame refresh (mod 267883)
            if (clock_frame > nsec_per_frame) {
                frame();
                mixin(VERBOSE_LOG!(`3`, `format("FRAME %s", frame_count)`));
                clock_frame = 0;
            }

            // writefln("NSEC: %s  |  %s OF %s", total_time.total!"nsecs", clock_log, nsec_per_log);
            if (clock_log > nsec_per_log) {
                immutable auto cpu_cycles_since_last_log = cycles_since_last_log;
                double avg_speed = (cast(double) cpu_cycles_since_last_log / cast(
                        double) cycles_per_log);
                mixin(VERBOSE_LOG!(`1`, `format("AVG SPEED: [%s/%s] = %s",
                        cpu_cycles_since_last_log, cycles_per_log, avg_speed)`));
                clock_log = 0;
                cycles_since_last_log = 0;
            }

            // Thread.sleep(0.msecs);
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

private:
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
        for (int j = 0; j < GBA_SCREEN_HEIGHT * screen_scale; j++) {
            for (int i = 0; i < GBA_SCREEN_WIDTH * screen_scale; i++) {
                auto p = gba.memory.video_buffer[i / screen_scale][j / screen_scale];
                pixels[j * (GBA_SCREEN_WIDTH * screen_scale) + i] = p;
            }
        }

        SDL_RenderClear(renderer);

        // copy pixel buffer to texture
        auto px_vp = cast(void*) pixels;
        SDL_UpdateTexture(screen_tex, null, px_vp, GBA_SCREEN_WIDTH * screen_scale * 4);

        // copy texture to scren
        SDL_RenderCopy(renderer, screen_tex, null, null);

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
        gba.memory.set_key(cast(ubyte) gba_key, pressed);
    }
}
