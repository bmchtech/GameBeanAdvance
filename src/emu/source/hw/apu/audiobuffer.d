module hw.apu.audiobuffer;

import hw.apu;

import std.stdio;
import std.math;
import std.datetime.stopwatch;

import util;

import core.sync.mutex;
import core.stdc.string;

import host.sdl;

// audiobuffer provides a way of adding sound to the buffer that the gba can use
// the callback function callback() must be connected to sdl for this to function
// properly.

struct Buffer {
    short[] data;
    ulong    offset;
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

enum BUFFER_SIZE = 0x100000;
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
        memset(out_stream, 0, len);
        audio_data.mutex.lock_nothrow();

            // try { writefln("Details: %x %x", len, audio_data.buffer[0].offset);} catch (Exception e) {}

            if (len / 4 > audio_data.buffer[Channel.L].offset) {
                // try { writefln("Emulator too slow!"); } catch (Exception e) {}
            }

            len = cast(int) (len > (audio_data.buffer[Channel.L].offset * 4) ? (audio_data.buffer[Channel.L].offset * 4) : len);

            for (int i = 0; i < len / 4; i++) {
                for (int channel = 0; channel < 2; channel++) {
                    short sample = cast(short) (audio_data.buffer[channel].data[i] * 0x2A);
                    audio_data.buffer[channel].data[i] = 0;
                    out_stream[2 * i + channel] = sample;
                    // try { writefln("%x", 2 * i + channel); } catch (Exception e) {}
                }

                // try { writefln("%x", out_stream[i]); } catch (Exception e) {}
            }

            for (int channel = 0; channel < 2; channel++) {
                for (int i = 0; i < audio_data.buffer[channel].offset - (len / 4); i++) {
                    audio_data.buffer[channel].data[i] = audio_data.buffer[channel].data[i + (len / 4)];
                }

                audio_data.buffer[channel].offset -= len / 4;
            }

        
        // try { writefln("unlock"); } catch(Exception e) {}
        audio_data.mutex.unlock_nothrow();
    }
}

__gshared void push_to_buffer(Channel channel, short[] data) {
    for (int i = 0; i < data.length; i++) {
        _audio_data.buffer[channel].data[_audio_data.buffer[channel].offset + i] = data[i];
    }
    // writefln("here?");
    _audio_data.buffer[channel].offset += data.length;
}