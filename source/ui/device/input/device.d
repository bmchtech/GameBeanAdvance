module ui.device.input.device;

import ui.device.device;

abstract class InputDevice : Observer {
    void set_callbacks(void delegate(int key, bool value) set_vanilla_key, void delegate(int key, bool value) set_beancomputer_key) {
        this.set_vanilla_key      = set_vanilla_key;
        this.set_beancomputer_key = set_beancomputer_key;
    }

    void handle_input();

    // GBA callbacks
    void delegate(int key, bool value) set_vanilla_key;
    void delegate(int key, bool value) set_beancomputer_key;
}