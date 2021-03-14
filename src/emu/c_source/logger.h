#ifndef LOGGER_H
#define LOGGER_H

#include "gba.h"

class GBA;

class Logger {
    public:
        Logger(GBA* gba);
        void error(std::string message);
        void warning(std::string message);

    private:
        GBA* gba;
};

#endif