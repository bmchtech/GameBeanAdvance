#define CATCH_CONFIG_MAIN

#include "../../src/gba.h"
#include "catch.hpp"

// setup and teardown for tests. see for more info:
// https://github.com/catchorg/Catch2/blob/master/docs/event-listeners.md
struct SetupTeardownListener : Catch::TestEventListenerBase {

    using TestEventListenerBase::TestEventListenerBase; // inherit constructor

    void testCaseStarting(Catch::TestCaseInfo const& testInfo) override {
        setup_memory();
    }
    
    void testCaseEnded(Catch::TestCaseStats const& testCaseStats) override {
        // Tear-down after a test case is run
    }
};
CATCH_REGISTER_LISTENER(SetupTeardownListener)