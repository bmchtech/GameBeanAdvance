module apu.audiobuffer;

import std.stdio;
import std.math;

// audiobuffer provides a way of adding sound to the buffer that the gba can use
// the callback function callback() must be connected to sdl for this to function
// properly.

struct AudioData {
    ubyte[] buffer;
    uint    buffer_offset;
}

enum BUFFER_SIZE = 0x1000; // must be a power of two
enum INDEX_MASK  = BUFFER_SIZE - 1;

private AudioData audio_data;
private bool      has_set_up_audio_data = false;

void* get_audio_data() {
    if (has_set_up_audio_data) return cast(void*) &audio_data;

    audio_data.buffer        = new ubyte[BUFFER_SIZE];
    audio_data.buffer_offset = 0;
    has_set_up_audio_data    = true;
    return cast(void*) &audio_data;
}

extern (C) {
    static void callback(void* userdata, ubyte* stream, int len) nothrow {
        AudioData* audio_data = cast(AudioData*) userdata;

        len = (len > BUFFER_SIZE ? BUFFER_SIZE : len);

        for (int i = 0; i < len; i++) {
            stream[i] = audio_data.buffer[(audio_data.buffer_offset + i) & INDEX_MASK];
            audio_data.buffer[(audio_data.buffer_offset + i) & INDEX_MASK] = 0;
        }

        audio_data.buffer_offset += len;
        audio_data.buffer_offset &= INDEX_MASK;
    }
}


void push_to_buffer(ubyte[] data) {
    if (!has_set_up_audio_data) return;

    for (int i = 0; i < data.length; i++) {
        audio_data.buffer[i] = data[i];
    }
}