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
    void delegate() callback;
}

enum BUFFER_SIZE = 0x100000;
// enum INDEX_MASK  = BUFFER_SIZE - 1;

AudioData audio_data;
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
        // writefln("call");
        
        audio_data.mutex.lock_nothrow();

            // try { writefln("Details: %x %x", len, audio_data.buffer_offset);} catch (Exception e) {}

            // try {
            //     for (int i = 0; i < audio_data.buffer_offset; i++) writefln("%x", audio_data.buffer[i]);
            // } catch (Exception e) {
            // }
            len = (len > audio_data.buffer_offset ? audio_data.buffer_offset : len);

            for (int i = 0; i < len; i++) {
                stream[i] = audio_data.buffer[i];
                // try {
                //     writefln("%x", stream[i]);
                // } catch (Exception e) {
                // }
            }

            for (int i = 0; i < audio_data.buffer_offset - len; i++) {
                audio_data.buffer[i] = audio_data.buffer[i + len];
            }

            audio_data.buffer_offset -= len;
            
        audio_data.mutex.unlock_nothrow();
    }
}

void set_audio_buffer_callback(void delegate() callback) {
    audio_data.callback = callback;
}

void push_to_buffer(ubyte[] data) {
    if (audio_data.mutex is null) return;
    
    audio_data.mutex.lock_nothrow();

        if (!has_set_up_audio_data) return;
        

        for (int i = 0; i < data.length; i++) {
            audio_data.buffer[audio_data.buffer_offset + i] = data[i];
        }

        audio_data.buffer_offset += data.length;

    audio_data.mutex.unlock_nothrow();
}