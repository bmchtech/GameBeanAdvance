module ui.device.device;

import ui.device.event;

enum SCREEN_WIDTH  = 240;
enum SCREEN_HEIGHT = 160;

alias NotifyObserversCallback = void delegate(Event e);
alias SetKey                  = void delegate(int key, bool value);

abstract class Observer {
    NotifyObserversCallback notify_observers;
    
    final void set_event_callback(NotifyObserversCallback callback) {
        this.notify_observers = callback;
    }

    abstract void notify(Event e);
}

struct Sample {
    short L;
    short R;
}

struct Pixel {
    uint r;
    uint g;
    uint b;
}

abstract class MultiMediaDevice : Observer {
    SetKey set_vanilla_key;
    SetKey set_beancomputer_key;

    this() {
        this.set_vanilla_key      = set_vanilla_key;
        this.set_beancomputer_key = set_beancomputer_key;
    }

    final void set_callbacks(SetKey set_vanilla_key, SetKey set_beancomputer_key) {
        this.set_vanilla_key      = set_vanilla_key;
        this.set_beancomputer_key = set_beancomputer_key;
    }

    abstract void update();
    abstract void draw();

    // video stuffs
    abstract void receive_videobuffer(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer);
    abstract void reset_fps();

    // audio stuffs
    void push_sample(Sample);
    void pause();
    void play();
    uint get_sample_rate();
    uint get_samples_per_callback();
    size_t get_buffer_size();

    // input stuffs
    void handle_input();
}