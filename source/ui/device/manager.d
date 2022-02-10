module ui.device.manager;

import ui.device.device;
import ui.device.event;

class DeviceManager {
    Observer[] devices;

    void add_device(Observer device) {
        device.set_event_callback(&this.notify_devices_callback);
        devices ~= device;
    }

    void notify_devices_callback(Event event) {
        foreach (Observer device; devices) {
            device.notify(event);
        }
    }
}