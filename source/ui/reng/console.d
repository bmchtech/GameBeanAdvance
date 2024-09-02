module ui.reng.console;

import re.core;
import re.ng.diag.console;

class EmuConsole {
    void register() {
        Core.inspector_overlay.console.reset();

        // add emu commands
        Core.inspector_overlay.console.add_command(ConsoleCommand("gamebean", &cmd_gamebean, "gamebean"));
    }

    void unregister() {
        Core.inspector_overlay.console.reset();
    }

    void cmd_gamebean(string[] args) {
        Core.log.info("GameBeanAdvance Emulator Console");
        // exit this process
        Core.exit();
    }
}
