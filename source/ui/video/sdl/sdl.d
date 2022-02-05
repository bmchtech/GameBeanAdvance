module ui.video.sdl.sdl;

import hw.gba;
import hw.apu;
import hw.cpu;
import save;

import diag.cputrace;
import diag.logger;
import diag.log;

import util;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.sdl.image;

import std.stdio;
import std.conv;
import std.mmfile;
import std.file;

import ui.audio.sdl.sdldevice;

import core.sync.mutex;

version (Imgui) {
    import derelict.imgui.imgui;
}

__gshared GBA _gba;
__gshared int _samples_per_callback;
__gshared int _cycles_per_batch;

final class GameBeanSDLHost {
    Mutex gba_batch_enable_mutex;
    bool gba_batch_enable = false;

    this(GBA gba, int screen_scale) {
        _gba = gba;
        this.screen_scale = screen_scale;
        gba_batch_enable_mutex = new Mutex();
    }

    uint prog_id;
    GLint g_AttribLocationVtxColor;

    void init() {

    }

    int fps = 0;
    bool fast_forward = false;

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

    GLuint gl_texture;

    void enable_cpu_tracing(int trace_length) {
        cpu_tracing_enabled = true;
        trace = new CpuTrace(_gba.cpu, trace_length);
        Logger.singleton(trace);
        log!(LogSource.DEBUG)("Enabled CPU trace logging");
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
        fps++;
        // sync from GBA video buffer
        for (int j = 0; j < GBA_SCREEN_HEIGHT; j++) {
            for (int i = 0; i < GBA_SCREEN_WIDTH; i++) {
                auto p = _gba.memory.video_buffer[i][j];
                pixels[j * (GBA_SCREEN_WIDTH) + i] = p;
            }
        }

        // SDL_RenderClear(renderer);

        // // copy pixel buffer to texture
        // auto px_vp = cast(void*) pixels;
        // SDL_UpdateTexture(screen_tex, null, px_vp, GBA_SCREEN_WIDTH * 4);

        // // copy texture to scren
        // const SDL_Rect dest = SDL_Rect(0, 0, GBA_SCREEN_WIDTH * screen_scale, GBA_SCREEN_HEIGHT * screen_scale);
        // SDL_RenderCopy(renderer, screen_tex, null, &dest);

        // render present
        // SDL_RenderPresent(renderer);
        glClearColor(0, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, gl_texture);
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,GBA_SCREEN_WIDTH,GBA_SCREEN_HEIGHT,0,GL_RGBA,GL_UNSIGNED_BYTE, cast(void*) pixels);

        // glBufferData(GL_ARRAY_BUFFER, 240*160*4, cast(void*) pixels, GL_STREAM_DRAW);
        
        glBegin(GL_QUADS);
        glTexCoord2f(0.0f, 1.0f);
        glVertex2f(-1.0f, -1.0f);
        glTexCoord2f(1.0f, 1.0f);
        glVertex2f(1.0f, -1.0f);
        glTexCoord2f(1.0f, 0.0f);
        glVertex2f(1.0f, 1.0f);
        glTexCoord2f(0.0f, 0.0f);
        glVertex2f(-1.0f, 1.0f);
        glEnd();

        auto glerror = glGetError();
        if( glerror != GL_NO_ERROR ) {
            error(format("open gl error: %s", glerror));
        }

        SDL_GL_SwapWindow(window);

        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            switch (event.type) {
            case SDL_QUIT:
                exit();
                break;
            case SDL_KEYDOWN:
                on_input(event.key.keysym.sym, true);
                break;
            case SDL_KEYUP:
                on_input(event.key.keysym.sym, false);
                break;
            default:
                break;
            }
        }
    }

    enum KEYMAP_VANILLA = [
        SDL_Keycode.SDLK_z            : GBAKeyVanilla.A,
        SDL_Keycode.SDLK_x            : GBAKeyVanilla.B,
        SDL_Keycode.SDLK_SPACE        : GBAKeyVanilla.SELECT,
        SDL_Keycode.SDLK_RETURN       : GBAKeyVanilla.START,
        SDL_Keycode.SDLK_RIGHT        : GBAKeyVanilla.RIGHT,
        SDL_Keycode.SDLK_LEFT         : GBAKeyVanilla.LEFT,
        SDL_Keycode.SDLK_UP           : GBAKeyVanilla.UP,
        SDL_Keycode.SDLK_DOWN         : GBAKeyVanilla.DOWN,
        SDL_Keycode.SDLK_s            : GBAKeyVanilla.R,
        SDL_Keycode.SDLK_a            : GBAKeyVanilla.L,
    ];
    
    enum KEYMAP_BEANCOMPUTER = [
        SDL_Keycode.SDLK_a            : GBAKeyBeanComputer.A,
        SDL_Keycode.SDLK_b            : GBAKeyBeanComputer.B,
        SDL_Keycode.SDLK_c            : GBAKeyBeanComputer.C,
        SDL_Keycode.SDLK_d            : GBAKeyBeanComputer.D,
        SDL_Keycode.SDLK_e            : GBAKeyBeanComputer.E,
        SDL_Keycode.SDLK_f            : GBAKeyBeanComputer.F,
        SDL_Keycode.SDLK_g            : GBAKeyBeanComputer.G,
        SDL_Keycode.SDLK_h            : GBAKeyBeanComputer.H,
        SDL_Keycode.SDLK_i            : GBAKeyBeanComputer.I,
        SDL_Keycode.SDLK_j            : GBAKeyBeanComputer.J,
        SDL_Keycode.SDLK_k            : GBAKeyBeanComputer.K,
        SDL_Keycode.SDLK_l            : GBAKeyBeanComputer.L,
        SDL_Keycode.SDLK_m            : GBAKeyBeanComputer.M,
        SDL_Keycode.SDLK_n            : GBAKeyBeanComputer.N,
        SDL_Keycode.SDLK_o            : GBAKeyBeanComputer.O,
        SDL_Keycode.SDLK_p            : GBAKeyBeanComputer.P,
        SDL_Keycode.SDLK_q            : GBAKeyBeanComputer.Q,
        SDL_Keycode.SDLK_r            : GBAKeyBeanComputer.R,
        SDL_Keycode.SDLK_s            : GBAKeyBeanComputer.S,
        SDL_Keycode.SDLK_t            : GBAKeyBeanComputer.T,
        SDL_Keycode.SDLK_u            : GBAKeyBeanComputer.U,
        SDL_Keycode.SDLK_v            : GBAKeyBeanComputer.V,
        SDL_Keycode.SDLK_w            : GBAKeyBeanComputer.W,
        SDL_Keycode.SDLK_x            : GBAKeyBeanComputer.X,
        SDL_Keycode.SDLK_y            : GBAKeyBeanComputer.Y,
        SDL_Keycode.SDLK_z            : GBAKeyBeanComputer.Z,
        SDL_Keycode.SDLK_LSHIFT       : GBAKeyBeanComputer.SHIFT,
        SDL_Keycode.SDLK_RSHIFT       : GBAKeyBeanComputer.SHIFT,
        SDL_Keycode.SDLK_LCTRL        : GBAKeyBeanComputer.CTRL,
        SDL_Keycode.SDLK_RCTRL        : GBAKeyBeanComputer.CTRL,
        SDL_Keycode.SDLK_LALT         : GBAKeyBeanComputer.ALT,
        SDL_Keycode.SDLK_RALT         : GBAKeyBeanComputer.ALT,
        SDL_Keycode.SDLK_LGUI         : GBAKeyBeanComputer.SUPER,
        SDL_Keycode.SDLK_ESCAPE       : GBAKeyBeanComputer.ESCAPE,
        SDL_Keycode.SDLK_0            : GBAKeyBeanComputer.NUMBER_0,
        SDL_Keycode.SDLK_1            : GBAKeyBeanComputer.NUMBER_1,
        SDL_Keycode.SDLK_2            : GBAKeyBeanComputer.NUMBER_2,
        SDL_Keycode.SDLK_3            : GBAKeyBeanComputer.NUMBER_3,
        SDL_Keycode.SDLK_4            : GBAKeyBeanComputer.NUMBER_4,
        SDL_Keycode.SDLK_5            : GBAKeyBeanComputer.NUMBER_5,
        SDL_Keycode.SDLK_6            : GBAKeyBeanComputer.NUMBER_6,
        SDL_Keycode.SDLK_7            : GBAKeyBeanComputer.NUMBER_7,
        SDL_Keycode.SDLK_8            : GBAKeyBeanComputer.NUMBER_8,
        SDL_Keycode.SDLK_9            : GBAKeyBeanComputer.NUMBER_9,
        SDL_Keycode.SDLK_COMMA        : GBAKeyBeanComputer.COMMA,
        SDL_Keycode.SDLK_PERIOD       : GBAKeyBeanComputer.PERIOD,
        SDL_Keycode.SDLK_SLASH        : GBAKeyBeanComputer.SLASH,
        SDL_Keycode.SDLK_SEMICOLON    : GBAKeyBeanComputer.SEMICOLON,
        SDL_Keycode.SDLK_QUOTE        : GBAKeyBeanComputer.QUOTE,
        SDL_Keycode.SDLK_LEFTBRACKET  : GBAKeyBeanComputer.LBRACKET,
        SDL_Keycode.SDLK_RIGHTBRACKET : GBAKeyBeanComputer.RBRACKET,
        SDL_Keycode.SDLK_BACKSLASH    : GBAKeyBeanComputer.BACKSLASH,
        SDL_Keycode.SDLK_MINUS        : GBAKeyBeanComputer.MINUS,
        SDL_Keycode.SDLK_PLUS         : GBAKeyBeanComputer.PLUS,
        SDL_Keycode.SDLK_TAB          : GBAKeyBeanComputer.TAB,
        SDL_Keycode.SDLK_RETURN       : GBAKeyBeanComputer.RETURN,
        SDL_Keycode.SDLK_BACKSPACE    : GBAKeyBeanComputer.BACKSPACE,
        SDL_Keycode.SDLK_RIGHT        : GBAKeyBeanComputer.RIGHT,
        SDL_Keycode.SDLK_LEFT         : GBAKeyBeanComputer.LEFT,
        SDL_Keycode.SDLK_UP           : GBAKeyBeanComputer.UP,
        SDL_Keycode.SDLK_DOWN         : GBAKeyBeanComputer.DOWN,
        SDL_Keycode.SDLK_RIGHT        : GBAKeyBeanComputer.RIGHT,
        SDL_Keycode.SDLK_LEFT         : GBAKeyBeanComputer.LEFT,
        SDL_Keycode.SDLK_UP           : GBAKeyBeanComputer.UP,
        SDL_Keycode.SDLK_DOWN         : GBAKeyBeanComputer.DOWN
    ];

    void on_input(SDL_Keycode key, bool pressed) {
        if (key == SDL_Keycode.SDLK_TAB) {
            fast_forward = pressed;
        }

        if (key in KEYMAP_VANILLA) {
            auto gba_key = to!int(KEYMAP_VANILLA[key]);
            _gba.key_input.set_key(cast(ubyte) gba_key, pressed);
        }

        if (key in KEYMAP_BEANCOMPUTER) {
            auto gba_key = to!int(KEYMAP_BEANCOMPUTER[key]);
            _gba.beancomputer.set_key(cast(ubyte) gba_key, pressed);
        }
    }
}
