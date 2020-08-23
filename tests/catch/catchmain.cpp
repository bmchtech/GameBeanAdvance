#define CATCH_CONFIG_MAIN

#include "../../src/gba.h"
#include "catch.hpp"

// setup and teardown for tests. see for more info:
// https://github.com/catchorg/Catch2/blob/master/docs/event-listeners.md
struct SetupTeardownListener : Catch::TestEventListenerBase {

    using TestEventListenerBase::TestEventListenerBase; // inherit constructor

    void testRunStarting(Catch::TestRunInfo const& testRunInfo) override {
        setup_memory();
    }
    
    void testRunEnded(Catch::TestRunStats const& testRunStats) override {
        cleanup_memory();
    }
};
CATCH_REGISTER_LISTENER(SetupTeardownListener)