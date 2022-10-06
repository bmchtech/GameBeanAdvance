module ui.debugger.core;

import ui.debugger.scene;

import core.sync.mutex;

import re;
import re.math;

final class DebuggerCore : Core {
	enum WIDTH  = 1000;
	enum HEIGHT = 1000;

    Mutex render_mutex;

	this(Mutex render_mutex) {
        this.render_mutex = render_mutex;

		super(WIDTH, HEIGHT, "Debugger");
    }

	override void initialize() {
		default_resolution = Vector2(1000 / 4, 1000 / 4);
		load_scenes([new DebugScene()]);
	}

    override protected void draw() {
        super.draw();
    }
}