module ui.reng.console;

import re.core;
import re.ng.diag.console;

import hw.gba;

class EmuConsole {
    GBA gba;

    void register() {
        Core.inspector_overlay.console.reset();

        // get the gba instance
        gba = Core.jar.resolve!GBA().get;

        // add emu commands
        Core.inspector_overlay.console.add_command(ConsoleCommand("gamebean", &cmd_gamebean, "gamebean"));
    }

    void unregister() {
        Core.inspector_overlay.console.reset();
    }

    void cmd_gamebean(string[] args) {
        Core.log.info("GameBeanAdvance Emulator Console");
        Core.log.info("GBA: %s", gba);
    }
}
