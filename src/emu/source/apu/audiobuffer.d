module apu.audiobuffer;

import std.stdio;
import std.math;

import util;

import core.sync.mutex;

// audiobuffer provides a way of adding sound to the buffer that the gba can use
// the callback function callback() must be connected to sdl for this to function
// properly.

struct AudioData {
    short[] buffer;
    uint    buffer_offset;
    Mutex   mutex;
    void delegate() callback;
}

enum BUFFER_SIZE = 0x100000;
// enum INDEX_MASK  = BUFFER_SIZE - 1;

AudioData audio_data;
private bool      has_set_up_audio_data = false;

void* get_audio_data() {
    if (has_set_up_audio_data) return cast(void*) &audio_data;
    
    audio_data.buffer        = new short[BUFFER_SIZE];
    audio_data.buffer_offset = 0;
    audio_data.mutex         = new Mutex();
    has_set_up_audio_data    = true;
    return cast(void*) &audio_data;
}

extern (C) {
    static void callback(void* userdata, ubyte* stream, int len) nothrow {
        AudioData* audio_data = cast(AudioData*) userdata;
        if (audio_data.mutex is null) return;
        // writefln("call");

        short* out_stream = cast(short*) stream;
        
        audio_data.mutex.lock_nothrow();

            // try { writefln("Details: %x %x", len, audio_data.buffer_offset);} catch (Exception e) {}

            if (len > audio_data.buffer_offset) {
                // try { warning("Emulator too slow!"); } catch (Exception e) {}
            }

            len = (len > audio_data.buffer_offset ? audio_data.buffer_offset : len);

            for (int i = 0; i < len / 2; i++) {
                short sample = cast(short)(audio_data.buffer[i] * 0x2A);

                out_stream[i] = sample;            try {
            } catch (Exception e) {
            }
            }

            for (int i = 0; i < audio_data.buffer_offset - len; i++) {
                audio_data.buffer[i] = audio_data.buffer[i + len];
            }

            audio_data.buffer_offset -= len / 2;
            
        audio_data.mutex.unlock_nothrow();
    }
}

void set_audio_buffer_callback(void delegate() callback) {
    audio_data.callback = callback;
}

void push_to_buffer(short[] data) {
    if (audio_data.mutex is null) return;
    
    audio_data.mutex.lock_nothrow();

        if (!has_set_up_audio_data) return;
        

        for (int i = 0; i < data.length; i++) {
            audio_data.buffer[audio_data.buffer_offset + i] = data[i];
        }

        audio_data.buffer_offset += data.length;

    audio_data.mutex.unlock_nothrow();
}