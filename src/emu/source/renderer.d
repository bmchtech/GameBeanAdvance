module renderer;
import bindbc.sdl;
import std.stdio;
import gba;
import core.time;

class GameBeanSDLRenderer {
    this(GBA gba) {
        this.gba = gba;
    }

    void init() {
        if (SDL_Init(SDL_INIT_VIDEO) != 0)
            assert(0, "sdl init failed");

        window = SDL_CreateWindow("GameBean Advance", SDL_WINDOWPOS_UNDEFINED,
                SDL_WINDOWPOS_UNDEFINED, GBA_SCREEN_WIDTH * GBA_SCREEN_SCALE,
                GBA_SCREEN_HEIGHT * GBA_SCREEN_SCALE, SDL_WindowFlags.SDL_WINDOW_SHOWN);
        assert(window != null, "sdl window init failed!");
    }

    void run() {
        running = true;
        auto lastTicks = MonoTime.currTime();

        auto nsec_per_gba_cycle = (1.seconds / 16_000_000).total!"nsecs";
        auto nsec_per_frame = (1.seconds / 60).total!"nsecs";
        auto total_time = nsecs(0);
        auto clock_cycle = 0;
        auto clock_frame = 0;

        while (running) {
            auto ticks = MonoTime.currTime();
            auto el = ticks - lastTicks;
            lastTicks = ticks;

            auto el_nsecs = el.total!"nsecs";
            
            clock_cycle += el_nsecs;
            clock_frame += el_nsecs;

            // 16 MHz GBA cycle
            if (clock_cycle > nsec_per_gba_cycle) {
                gba.cycle();
                clock_cycle = 0;
            }

            // 60Hz frame refresh (mod 267883)
            if (clock_frame > nsec_per_frame) {
                frame();
                clock_frame = 0;
            }
        }
    }

    void exit() {
        SDL_DestroyWindow(window);
        SDL_Quit();
    }

    int frameCount;
    GBA gba;
    bool running;
    SDL_Window* window;
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
                // this.keys.pump_keydown(event.key.keysym.sym, frameCount);
                break;
            case SDL_KEYUP:
                // this.keys.pump_keyup(event.key.keysym.sym);
                break;
            default:
                break;
            }
        }

        frameCount++;

        writeln("%d frames.", frameCount);
    }
}
