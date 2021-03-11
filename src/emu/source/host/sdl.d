module host.sdl;
import bindbc.sdl;
import std.stdio;
import gba;
import core.time : MonoTime, nsecs;
import std.conv;

class GameBeanSDLHost {
    this(GBA gba) {
        this.gba = gba;
    }

    void init() {
        if (SDL_Init(SDL_INIT_VIDEO) != 0)
            assert(0, "sdl init failed");

        window = SDL_CreateWindow("GameBean Advance", SDL_WINDOWPOS_UNDEFINED,
                SDL_WINDOWPOS_UNDEFINED, GBA_SCREEN_WIDTH * GBA_SCREEN_SCALE,
                GBA_SCREEN_HEIGHT * GBA_SCREEN_SCALE, SDL_WindowFlags.SDL_WINDOW_SHOWN);
        assert(window !is null, "sdl window init failed!");

        renderer = SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_PRESENTVSYNC);

        screen_tex = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888,
                SDL_TextureAccess.SDL_TEXTUREACCESS_STREAMING,
                GBA_SCREEN_WIDTH * GBA_SCREEN_SCALE, GBA_SCREEN_HEIGHT * GBA_SCREEN_SCALE);

        pixels = new uint[GBA_SCREEN_WIDTH * GBA_SCREEN_SCALE * GBA_SCREEN_HEIGHT * GBA_SCREEN_SCALE];
    }

    void run() {
        running = true;
        auto lastTicks = MonoTime.currTime();

        // each cycle() does 4 cpu cycles
        enum cycles_per_second = 16_000_000 / 4;
        enum gba_cycle_batch_sz = 1024;
        // 62.5 nsec per cycle: this is nsec per batch
        enum nsec_per_gba_cyclebatch = cycles_per_second / gba_cycle_batch_sz;

        // 16.6666 ms
        enum nsec_per_frame = 16_666_660;
        auto total_time = nsecs(0);
        auto clock_cycle = 0;
        auto clock_frame = 0;
        auto total_cycles = 0;

        // 2 seconds
        enum sec_per_log = 2;
        enum nsec_per_log = sec_per_log * 1_000_000_000;
        enum cycles_per_log = nsec_per_gba_cyclebatch * gba_cycle_batch_sz * sec_per_log;
        auto clock_log = 0;
        ulong cycles_since_last_log = 0;

        while (running) {
            auto ticks = MonoTime.currTime();
            auto el = ticks - lastTicks;
            lastTicks = ticks;

            total_time += el;
            auto el_nsecs = el.total!"nsecs";
            util.verbose_log(format("nsecs elapsed: %s", el_nsecs), 3);

            clock_cycle += el_nsecs;
            clock_frame += el_nsecs;
            clock_log += el_nsecs;

            // GBA cycle batching
            if (clock_cycle > nsec_per_gba_cyclebatch) {
                for (int i = 0; i < gba_cycle_batch_sz; i++) {
                    util.verbose_log(format("pc: %00000000x (cycle %s)",
                            *gba.cpu.pc, total_cycles + i), 3);
                    gba.cycle();
                }
                total_cycles += gba_cycle_batch_sz;
                cycles_since_last_log += gba_cycle_batch_sz;
                util.verbose_log(format("CYCLE[%s]", gba_cycle_batch_sz), 3);
                clock_cycle = 0;
            }

            // 60Hz frame refresh (mod 267883)
            if (clock_frame > nsec_per_frame) {
                frame();
                util.verbose_log(format("FRAME %s", frame_count), 3);
                clock_frame = 0;
            }

            if (clock_log > nsec_per_log) {
                auto cpu_cycles_since_last_log = cycles_since_last_log;
                double avg_speed = (cast(double) cpu_cycles_since_last_log / cast(
                        double) cycles_per_log);
                util.verbose_log(format("AVG SPEED: [%s/%s] = %s",
                        cpu_cycles_since_last_log, cycles_per_log, avg_speed), 1);
                clock_log = 0;
                cycles_since_last_log = 0;
            }
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
    enum GBA_SCREEN_SCALE = 2;

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
        for (int j = 0; j < GBA_SCREEN_HEIGHT * GBA_SCREEN_SCALE; j++) {
            for (int i = 0; i < GBA_SCREEN_WIDTH * GBA_SCREEN_SCALE; i++) {
                auto p = gba.memory.video_buffer[i / GBA_SCREEN_SCALE][j / GBA_SCREEN_SCALE];
                pixels[j * (GBA_SCREEN_WIDTH * GBA_SCREEN_SCALE) + i] = p;
            }
        }

        SDL_RenderClear(renderer);

        // copy pixel buffer to texture
        auto px_vp = cast(void*) pixels;
        SDL_UpdateTexture(screen_tex, null, px_vp, GBA_SCREEN_WIDTH * GBA_SCREEN_SCALE * 4);

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
