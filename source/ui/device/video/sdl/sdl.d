module ui.device.video.sdl.sdl;

import bindbc.sdl;
import bindbc.opengl;
import bindbc.sdl.image;

import std.conv;

import core.sync.mutex;

import util;

import ui.device.video.device;
import ui.device.event;

final class SDLVideoDevice : VideoDevice {
    SDL_Window* window;
    SDL_Renderer* renderer;
    SDL_Texture* screen_tex;
    
    GLuint gl_texture;

    Mutex render_mutex;

    bool fast_forward = false;

    this(Mutex render_mutex, int screen_scale) {
        super(render_mutex);
        
        window = SDL_CreateWindow(
            "GameBean Advance", 
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED, 
            SCREEN_WIDTH * screen_scale,
            SCREEN_HEIGHT * screen_scale, 
            SDL_WINDOW_OPENGL
        );

        if (window == null) error("SDL window init failed!");

        SDL_GLContext gContext = SDL_GL_CreateContext(window);
        if (gContext == null) {
            error(format("OpenGL context couldn't be created! SDL Error: %s", SDL_GetError()));
        }

        const GLSupport openglLoaded = loadOpenGL();
        if (openglLoaded != glSupport) {
            error(format("Error loading OpenGL shared library: %s", to!string(openglLoaded)));
        }
        
        version(OSX) {
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
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

        SDL_GL_SetSwapInterval(0);

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

        GLuint sv = glCreateShader(GL_VERTEX_SHADER);

        static import shader.test;
        const GLchar* codev = shader.test.vertex_shader;
        glShaderSource(sv, 1, &codev, null);
        glCompileShader(sv);

        GLint isCompiled = 0;
        glGetShaderiv(sv, GL_COMPILE_STATUS, &isCompiled);
        if (isCompiled == GL_FALSE) {
            GLint maxLength = 300;
            glGetShaderiv(sv, GL_INFO_LOG_LENGTH, &maxLength);
            char[300] errorLog;

            glGetShaderInfoLog(sv, maxLength, &maxLength, &errorLog[0]);

            glDeleteShader(sv);
            error(cast(string) errorLog);
            return;
        }

        GLuint sf = glCreateShader(GL_FRAGMENT_SHADER);

        static import shader.test;
        const GLchar* codef = shader.test.fragment_shader;
        glShaderSource(sf, 1, &codef, null);
        glCompileShader(sf);

        isCompiled = 0;
        glGetShaderiv(sf, GL_COMPILE_STATUS, &isCompiled);
        if (isCompiled == GL_FALSE) {
            GLint maxLength = 300;
            glGetShaderiv(sf, GL_INFO_LOG_LENGTH, &maxLength);
            char[300] errorLog;

            glGetShaderInfoLog(sf, maxLength, &maxLength, &errorLog[0]);

            glDeleteShader(sf);
            error(cast(string) errorLog);
            return;
        }

        auto prog_id = glCreateProgram();
        glAttachShader(prog_id, sv);
        glAttachShader(prog_id, sf);

        glLinkProgram(prog_id);


        uint y;
        glGenBuffers(1, &y);

        glBindBuffer(GL_ARRAY_BUFFER, y);

        glUseProgram(prog_id);
        
        glDeleteShader(sv);
        glDeleteShader(sf);

        SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest");
    }
    
    uint fps = 0;
    override void render(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer) {
        fps++;

        uint[SCREEN_HEIGHT * SCREEN_WIDTH] gl_buffer;
        for (int i = 0; i < SCREEN_WIDTH; i++) {
        for (int j = 0; j < SCREEN_HEIGHT; j++) {
            Pixel p = buffer[i][j];
            gl_buffer[j * (SCREEN_WIDTH) + i] = 
                (0xFF << 24) | 
                ((p.b << 3) << 16) |
                ((p.g << 3) << 8)  |
                ((p.r << 3) << 0);
        }
        }

        glClearColor(0, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT);

        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, gl_texture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, SCREEN_WIDTH, SCREEN_HEIGHT, 0, GL_RGBA, GL_UNSIGNED_BYTE, cast(void*) gl_buffer);
        
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
        if (glerror != GL_NO_ERROR) {
            error(format("OpenGL error: %s", glerror));
        }

        SDL_GL_SwapWindow(window);
    }

    override void reset_fps() {
        SDL_SetWindowTitle(window, cast(char*) ("FPS: " ~ format("%d", fps)));
        fps = 0;
    }

    override void notify(Event e) {
        final switch (e) {
            case Event.FAST_FORWARD:           break;
            case Event.UNFAST_FORWARD:         break;
            case Event.STOP:                   stop(); break;
            case Event.AUDIO_BUFFER_LOW:       break;
            case Event.AUDIO_BUFFER_SATURATED: break;
            case Event.POLL_INPUT:             break;
        }
    }

    void stop() {
        SDL_DestroyWindow(window);
    }
}