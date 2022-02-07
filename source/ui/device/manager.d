module ui.device.manager;

class DeviceManager {
    Device[] devices;

    void add_device(Device device) {
        device.set_event_callback(&this.notify_devices_callback);
        devices ~= device;
    }

    void notify_devices_callback(Event event) {
        foreach (Device device; devices) {
            device.notify(event);
        }
    }
}