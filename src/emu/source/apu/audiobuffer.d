module apu.audiobuffer;

import std.stdio;
import std.math;

import util;

import core.sync.mutex;

// audiobuffer provides a way of adding sound to the buffer that the gba can use
// the callback function callback() must be connected to sdl for this to function
// properly.

struct AudioData {
    ubyte[] buffer;
    uint    buffer_offset;
    Mutex   mutex;
}

enum BUFFER_SIZE = 0x100000;
// enum INDEX_MASK  = BUFFER_SIZE - 1;

private AudioData audio_data;
private bool      has_set_up_audio_data = false;

void* get_audio_data() {
    if (has_set_up_audio_data) return cast(void*) &audio_data;

    audio_data.buffer        = new ubyte[BUFFER_SIZE];
    audio_data.buffer_offset = 0;
    audio_data.mutex         = new Mutex();
    has_set_up_audio_data    = true;
    return cast(void*) &audio_data;
}

extern (C) {
    static void callback(void* userdata, ubyte* stream, int len) nothrow {
        AudioData* audio_data = cast(AudioData*) userdata;
        if (audio_data.mutex is null) return;
        
        audio_data.mutex.lock_nothrow();

            // try { writefln("Details: %x %x", len, audio_data.buffer_offset);} catch (Exception e) {}
            len = (len > BUFFER_SIZE ? BUFFER_SIZE : len);

            for (int i = 0; i < len; i++) {
                stream[i] = audio_data.buffer[(i * audio_data.buffer_offset) / len];
                try {
                    // writefln("%x: %x", (i * audio_data.buffer_offset) / len, stream[i]);
                } catch (Exception e) {
                }
            }

            for (int i = 0; i < audio_data.buffer_offset; i++) {
                audio_data.buffer[i] = 0;
            }

            audio_data.buffer_offset = 0;

        audio_data.mutex.unlock_nothrow();
    }
}

void push_to_buffer(ubyte[] data) {
    audio_data.mutex.lock_nothrow();

        if (!has_set_up_audio_data) return;
        
        // writefln("Pushed %x to buffer at index %x", data[0], audio_data.buffer_offset);

        for (int i = 0; i < data.length; i++) {
            audio_data.buffer[audio_data.buffer_offset + i] = data[i];
        }

        audio_data.buffer_offset += data.length;

    audio_data.mutex.unlock_nothrow();
}