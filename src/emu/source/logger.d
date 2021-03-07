module logger;

import gba;

class Logger {
    this(GBA gba) {
        gba = gba;
    }

    void error(string message) {
        assert(0);
    }

    void warning(string message) {
        assert(0);
    }

private:
    GBA gba;
}
