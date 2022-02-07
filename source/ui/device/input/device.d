module ui.device.audio.input.device;

abstract class InputDevice : Device {
    void set_callbacks(void delegate(uint key) set_vanilla_key, void delegate(uint key) set_beancomputer_key) {
        this.set_vanilla_key      = set_vanilla_key;
        this.set_beancomputer_key = set_beancomputer_key;
    }

    void handle_input();

    // GBA callbacks
    void delegate(uint key) set_vanilla_key;
    void delegate(uint key) set_beancomputer_key;
}