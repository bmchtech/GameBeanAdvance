module hw.apu.audiobuffer;

import hw.apu;

import std.stdio;
import std.math;
import std.datetime.stopwatch;

import util;

import core.sync.mutex;
import core.stdc.string;

import ui.sdl;

// audiobuffer provides a way of adding sound to the buffer that the gba can use
// the callback function callback() must be connected to sdl for this to function
// properly.

struct Buffer {
    short[] data;
    ulong   offset;
    short   last_sample = 0;
}

struct AudioData {
    Buffer[2] buffer;

    Mutex   mutex;
    void delegate() callback;
}

enum Channel {
    L = 0,
    R = 1
}

enum BUFFER_SIZE = 0x1000;
// enum INDEX_MASK  = BUFFER_SIZE - 1;

__gshared AudioData _audio_data;
private bool      has_set_up_audio_data = false;

void* get_audio_data() {
    if (has_set_up_audio_data) return cast(void*) &_audio_data;
    
    for (int channel = 0; channel < 2; channel++) {
        _audio_data.buffer[channel].data   = new short[BUFFER_SIZE];
        _audio_data.buffer[channel].offset = 0;
    }

    _audio_data.mutex         = new Mutex();
    has_set_up_audio_data    = true;
    return cast(void*) &_audio_data;
}

auto __gshared _stopwatch = new StopWatch(AutoStart.no);

extern (C) {
    static void callback(void* userdata, ubyte* stream, int len) nothrow {

        AudioData* audio_data = cast(AudioData*) userdata;
        if (audio_data.mutex is null) return;

        short* out_stream = cast(short*) stream;        

        audio_data.mutex.lock_nothrow();

            int cut_len = cast(int) (len > (audio_data.buffer[Channel.L].offset * 4) ? (audio_data.buffer[Channel.L].offset * 4) : len);

            for (int channel = 0; channel < 2; channel++) {
                for (int i = 0; i < len / 4; i++) {
                    ushort sample;
                    if (i < audio_data.buffer[channel].offset) {
                        sample = cast(short) (audio_data.buffer[channel].data[i] * 0x2A);
                        audio_data.buffer[channel].last_sample = sample;
                        audio_data.buffer[channel].data[i] = 0;
                    } else {
                        sample = audio_data.buffer[channel].last_sample;
                    }

                    out_stream[2 * i + channel] = sample;
                }
            }

            for (int channel = 0; channel < 2; channel++) {
                for (int i = 0; i < audio_data.buffer[channel].offset - (cut_len / 4); i++) {
                    audio_data.buffer[channel].data[i] = audio_data.buffer[channel].data[i + (cut_len / 4)];
                }

                audio_data.buffer[channel].offset -= cut_len / 4;
            }
        audio_data.mutex.unlock_nothrow();
    }
}

__gshared void push_to_buffer(Channel channel, short[] data) {
    if ((_audio_data.buffer[channel].offset + data.length) >= BUFFER_SIZE) return;
    for (int i = 0; i < data.length; i++) {
        _audio_data.buffer[channel].data[_audio_data.buffer[channel].offset + i] = data[i];
        // writefln("pushed a sussy %x", data[i]);
    }
    _audio_data.buffer[channel].offset += data.length;
}