module diag.log;

import std.stdio;

enum LogSource {
    INIT,
    MEMORY,
    LCD,
    DEBUG,
    SAVE
}

static const ulong logsource_padding = get_largest_logsource_length!();

static ulong get_largest_logsource_length()(){
    import std.algorithm;
    import std.conv;

    ulong largest_logsource_length = 0;
    foreach (source; LogSource.min .. LogSource.max) {
        largest_logsource_length = max(to!string(source).length, largest_logsource_length);
    }

    return largest_logsource_length;
}

// thanks https://github.com/dlang/phobos/blob/4239ed8ebd3525206453784908f5d37c82d338ee/std/outbuffer.d
void log(LogSource log_source, Char, A...)(scope const(Char)[] fmt, A args) {
    import host.sdl;
    import std.format.write : formattedWrite;
    import std.conv;


    static if (log_source == LogSource.DEBUG) return;
    else {
        ulong timestamp = _gba ? _gba.scheduler.get_current_time_relative_to_cpu() : 0;
        writef("[%016x] %s: ", timestamp, pad_string_right!(to!string(log_source), logsource_padding));
        writefln(fmt, args);
    }
}

static string pad_string_right(string s, ulong pad)() {
    import std.array;

    static assert(s.length <= pad);
    return s ~ (replicate(" ", pad - s.length));
}