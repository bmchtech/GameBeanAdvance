module ui.device.debugger.debugger;

import core.thread.osthread;
import core.sync.mutex;

import ui.device.device;
import ui.device.event;
import ui.debugger.core;

final class DebuggerDevice : Observer {
    this(Mutex render_mutex) {
        new Thread({
            new DebuggerCore(render_mutex).run();
        }).start();
    }
    
    override void notify(Event e) {
        // ill do this later
    }
}