module host.sdl;

import hw.gba;
import hw.apu;
import hw.cpu;
import save;

import diag.cputrace;
import diag.logger;

import util;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.sdl.image;

import std.stdio;
import std.conv;
import std.mmfile;
import std.file;

import core.sync.mutex;

version (Imgui) {
    import derelict.imgui.imgui;
}

__gshared GBA _gba;
__gshared int _samples_per_callback;
__gshared int _cycles_per_batch;

class GameBeanSDLHost {
    Mutex gba_batch_enable_mutex;
    bool gba_batch_enable = false;

    this(GBA gba, int screen_scale) {
        _gba = gba;
        this.screen_scale = screen_scale;
        gba_batch_enable_mutex = new Mutex();
    }

    void init() {
        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0)
            assert(0, "sdl init failed");

        window = SDL_CreateWindow(
                "GameBean Advance", 
                SDL_WINDOWPOS_CENTERED,
                SDL_WINDOWPOS_CENTERED, 
                GBA_SCREEN_WIDTH * screen_scale,
                GBA_SCREEN_HEIGHT * screen_scale, 
                SDL_WINDOW_OPENGL);
        assert(window !is null, "sdl window init failed!");

        SDL_GLContext gContext = SDL_GL_CreateContext(window);
        if (gContext == null) {
            error(format("OpenGL context couldn't be created! SDL Error: %s", SDL_GetError()));
        }

        const GLSupport openglLoaded = loadOpenGL();
        if (openglLoaded != glSupport) {
            error(format("Error loading OpenGL shared library: %s", to!string(openglLoaded)));
        }
        
        version(OSX) {
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG); // Always required on Mac
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
        } else {
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 0);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
        }
        
        SDL_SetHint(SDL_HINT_RENDER_DRIVER, "opengl");
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

        // SDL_GL_MakeCurrent(window, gContext);
        SDL_GL_SetSwapInterval(0);

        // if (glewInit()) {
        //     error("failed to initialize opengl");
        // }

        glGenTextures(1, &gl_texture);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glEnable(GL_TEXTURE_2D);
        glGenTextures(1, &gl_texture);
        glBindTexture(GL_TEXTURE_2D, gl_texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        // SDL_SetHint(SDL_HINT_RENDER_VSYNC, "0");

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


        // time to detect the savetype
        Savetype savetype = detect_savetype(_gba.memory.rom.get_bytes());
        
        if (savetype != Savetype.NONE && savetype != Savetype.UNKNOWN) {
            Backup save = create_savetype(savetype);
            _gba.memory.add_backup(save);

            bool file_exists = "test.beansave".exists;

 	        MmFile mm_file = new MmFile("test.beansave", MmFile.Mode.readWrite, save.get_backup_size(), null, 0);
            if (file_exists) save.deserialize(cast(ubyte[]) mm_file[]);
            save.set_backup_file(mm_file);
        }

        writeln("Complete.");
    }

    int fps = 0;
    bool fast_forward = false;

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

        ulong cycle_timestamp = 0;

        ulong start_timestamp = SDL_GetTicks();

        _gba.set_frontend_vblank_callback(&frame);

        while (running) {
            ulong end_timestamp = SDL_GetTicks();
            ulong elapsed = end_timestamp - start_timestamp;
            start_timestamp = end_timestamp;

            clockfor_log   += elapsed;
            clockfor_frame += elapsed;

            if (_gba.enabled) {
                if (!fast_forward) {
                    while (_samples_per_callback * 2 > _audio_data.buffer[Channel.L].offset) {
                        _gba.cycle_at_least_n_times(_cycles_per_batch);
                    }
                } else {
                    _gba.cycle_at_least_n_times(_cycles_per_batch);
                }
            } else {
                frame();
            }
            // frame();

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

    GLuint gl_texture;

    void enable_cpu_tracing(int trace_length) {
        cpu_tracing_enabled = true;
        trace = new CpuTrace(_gba.cpu, trace_length);
        Logger.singleton(trace);
        writefln("Enabled logging");
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
        glBindTexture(GL_TEXTURE_2D, gl_texture);
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,GBA_SCREEN_WIDTH,GBA_SCREEN_HEIGHT,0,GL_RGBA,GL_UNSIGNED_BYTE, cast(void*) pixels);

        glBegin(GL_QUADS);
        glTexCoord2f(0, 0);
        glVertex2f(-1.0f, 1.0f);
        glTexCoord2f(1.0f, 0);
        glVertex2f(1.0f, 1.0f);
        glTexCoord2f(1.0f, 1.0f);
        glVertex2f(1.0f, -1.0f);
        glTexCoord2f(0, 1.0f);
        glVertex2f(-1.0f, -1.0f);
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
