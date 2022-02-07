module ui.device.video.sdl.sdl;

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
}
