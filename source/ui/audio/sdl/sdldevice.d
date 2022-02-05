module ui.audio.sdl.sdldevice;

import ui.audio.device;

import core.sync.mutex;
import core.stdc.string;

import bindbc.sdl;

import diag.log;

import std.algorithm;

enum BUFFER_SIZE = 0x1000;

__gshared Sample[] audio_buffer;
__gshared size_t   audio_buffer_offset;
__gshared Sample   last_sample = Sample(0, 0);
__gshared Mutex    audio_mutex;

final class SDLAudioDevice : AudioDevice {
    SDL_AudioSpec spec;

    this() {
        SDL_AudioSpec wanted;
        
        wanted.freq     = 44100;
        wanted.format   = AUDIO_S16LSB;
        wanted.channels = 2;
        wanted.samples  = 1024;
        wanted.userdata = null;
        wanted.callback = &this.callback;

        int output = SDL_OpenAudio(&wanted, &spec);
        if (output < 0) {
            log!(LogSource.INIT)("Couldn't open audio: %s\n", SDL_GetError());
        } else {
            log!(LogSource.INIT)("Established SDL audio connection.");
        }

        audio_buffer        = new Sample[BUFFER_SIZE];
        audio_buffer_offset = 0;
        audio_mutex         = new Mutex();
    }

    void push_sample(Sample s) {
        if (audio_buffer_offset >= BUFFER_SIZE) return;

        audio_mutex.lock_nothrow();
        audio_buffer[audio_buffer_offset++] = s;
        audio_mutex.unlock_nothrow();
    }

    void pause() {
        SDL_PauseAudio(1);
    }

    void play() {
        SDL_PauseAudio(0);
    }

    extern(C)
    static void callback(void* userdata, ubyte* stream, int len) nothrow {    
        audio_mutex.lock_nothrow();

            short* out_stream = cast(short*) stream;    
            int cut_len = cast(int) min(len, audio_buffer_offset * 4);

            for (int i = len / 4 - 1; i >= 0; i--) {
                Sample s = audio_buffer_offset == 0 ? last_sample : audio_buffer[--audio_buffer_offset];
                last_sample = s;
                out_stream[2 * i + 0] = cast(short) (s.L * 0x2A);
                out_stream[2 * i + 1] = cast(short) (s.R * 0x2A);
            }

            for (int i = 0; i < audio_buffer_offset + (len / 4) - (cut_len / 4); i++) {
                audio_buffer[i] = audio_buffer[i + (cut_len / 4)];
            }

        audio_mutex.unlock_nothrow();
    }
}