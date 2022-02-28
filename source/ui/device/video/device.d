// module ui.device.video.device;

// import ui.device.device;
// import core.sync.mutex;

// enum SCREEN_WIDTH  = 240;
// enum SCREEN_HEIGHT = 160;

// struct Pixel {
//     uint r;
//     uint g;
//     uint b;
// }

// abstract class VideoDevice : Observer {
//     Mutex render_mutex;

//     this(Mutex render_mutex) {
//         this.render_mutex = render_mutex;
//     }

//     final void __render(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer) {
//         render_mutex.lock_nothrow();
//         render(buffer);
//         render_mutex.unlock_nothrow();
//     }

//     abstract void render(Pixel[SCREEN_HEIGHT][SCREEN_WIDTH] buffer);
//     abstract void reset_fps();
// }