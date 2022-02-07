module ui.device.device;

import ui.device.event;

alias NotifyObserversCallback = void delegate(Event e);

abstract class Observer {
    NotifyObserversCallback notify_observers;
    
    final void set_event_callback(NotifyObserversCallback callback) {
        this.notify_observers = callback;
    }

    abstract void notify(Event e);
}