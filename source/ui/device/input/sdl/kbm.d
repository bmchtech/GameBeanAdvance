// module ui.device.input.sdl.kbm;

// import ui.device.input.device;
// import ui.device.event;

// import bindbc.sdl;

// import std.conv;

// import hw.gba;

// final class SDLInputDevice_KBM : InputDevice {
//     override void handle_input() {
//         SDL_Event event;
//         while (SDL_PollEvent(&event)) {
//             switch (event.type) {
//             case SDL_QUIT:
//                 notify_observers(Event.STOP);
//                 break;
//             case SDL_KEYDOWN:
//                 on_input(event.key.keysym.sym, true);
//                 break;
//             case SDL_KEYUP:
//                 on_input(event.key.keysym.sym, false);
//                 break;
//             default:
//                 break;
//             }
//         }
//     }

//     void on_input(SDL_Keycode key, bool pressed) {
//         if (key == SDL_Keycode.SDLK_TAB) {
//             if (pressed) notify_observers(Event.FAST_FORWARD);
//             else         notify_observers(Event.UNFAST_FORWARD);
//         }

//         if (key in KEYMAP_VANILLA) {
//             auto gba_key = to!int(KEYMAP_VANILLA[key]);
//             set_vanilla_key(cast(ubyte) gba_key, pressed);
//         }

//         if (key in KEYMAP_BEANCOMPUTER) {
//             auto gba_key = to!int(KEYMAP_BEANCOMPUTER[key]);
//             set_beancomputer_key(cast(ubyte) gba_key, pressed);
//         }
//     }

//     override void notify(Event e) {
//         final switch (e) {
//             case Event.FAST_FORWARD:           break;
//             case Event.UNFAST_FORWARD:         break;
//             case Event.STOP:                   break;
//             case Event.AUDIO_BUFFER_LOW:       break;
//             case Event.AUDIO_BUFFER_SATURATED: break;
//             case Event.POLL_INPUT:             handle_input();
//         }
//     }
// }

// enum KEYMAP_VANILLA = [
//     SDL_Keycode.SDLK_z            : GBAKeyVanilla.A,
//     SDL_Keycode.SDLK_x            : GBAKeyVanilla.B,
//     SDL_Keycode.SDLK_SPACE        : GBAKeyVanilla.SELECT,
//     SDL_Keycode.SDLK_RETURN       : GBAKeyVanilla.START,
//     SDL_Keycode.SDLK_RIGHT        : GBAKeyVanilla.RIGHT,
//     SDL_Keycode.SDLK_LEFT         : GBAKeyVanilla.LEFT,
//     SDL_Keycode.SDLK_UP           : GBAKeyVanilla.UP,
//     SDL_Keycode.SDLK_DOWN         : GBAKeyVanilla.DOWN,
//     SDL_Keycode.SDLK_s            : GBAKeyVanilla.R,
//     SDL_Keycode.SDLK_a            : GBAKeyVanilla.L,
// ];

// enum KEYMAP_BEANCOMPUTER = [
//     SDL_Keycode.SDLK_a            : GBAKeyBeanComputer.A,
//     SDL_Keycode.SDLK_b            : GBAKeyBeanComputer.B,
//     SDL_Keycode.SDLK_c            : GBAKeyBeanComputer.C,
//     SDL_Keycode.SDLK_d            : GBAKeyBeanComputer.D,
//     SDL_Keycode.SDLK_e            : GBAKeyBeanComputer.E,
//     SDL_Keycode.SDLK_f            : GBAKeyBeanComputer.F,
//     SDL_Keycode.SDLK_g            : GBAKeyBeanComputer.G,
//     SDL_Keycode.SDLK_h            : GBAKeyBeanComputer.H,
//     SDL_Keycode.SDLK_i            : GBAKeyBeanComputer.I,
//     SDL_Keycode.SDLK_j            : GBAKeyBeanComputer.J,
//     SDL_Keycode.SDLK_k            : GBAKeyBeanComputer.K,
//     SDL_Keycode.SDLK_l            : GBAKeyBeanComputer.L,
//     SDL_Keycode.SDLK_m            : GBAKeyBeanComputer.M,
//     SDL_Keycode.SDLK_n            : GBAKeyBeanComputer.N,
//     SDL_Keycode.SDLK_o            : GBAKeyBeanComputer.O,
//     SDL_Keycode.SDLK_p            : GBAKeyBeanComputer.P,
//     SDL_Keycode.SDLK_q            : GBAKeyBeanComputer.Q,
//     SDL_Keycode.SDLK_r            : GBAKeyBeanComputer.R,
//     SDL_Keycode.SDLK_s            : GBAKeyBeanComputer.S,
//     SDL_Keycode.SDLK_t            : GBAKeyBeanComputer.T,
//     SDL_Keycode.SDLK_u            : GBAKeyBeanComputer.U,
//     SDL_Keycode.SDLK_v            : GBAKeyBeanComputer.V,
//     SDL_Keycode.SDLK_w            : GBAKeyBeanComputer.W,
//     SDL_Keycode.SDLK_x            : GBAKeyBeanComputer.X,
//     SDL_Keycode.SDLK_y            : GBAKeyBeanComputer.Y,
//     SDL_Keycode.SDLK_z            : GBAKeyBeanComputer.Z,
//     SDL_Keycode.SDLK_LSHIFT       : GBAKeyBeanComputer.SHIFT,
//     SDL_Keycode.SDLK_RSHIFT       : GBAKeyBeanComputer.SHIFT,
//     SDL_Keycode.SDLK_LCTRL        : GBAKeyBeanComputer.CTRL,
//     SDL_Keycode.SDLK_RCTRL        : GBAKeyBeanComputer.CTRL,
//     SDL_Keycode.SDLK_LALT         : GBAKeyBeanComputer.ALT,
//     SDL_Keycode.SDLK_RALT         : GBAKeyBeanComputer.ALT,
//     SDL_Keycode.SDLK_LGUI         : GBAKeyBeanComputer.SUPER,
//     SDL_Keycode.SDLK_ESCAPE       : GBAKeyBeanComputer.ESCAPE,
//     SDL_Keycode.SDLK_0            : GBAKeyBeanComputer.NUMBER_0,
//     SDL_Keycode.SDLK_1            : GBAKeyBeanComputer.NUMBER_1,
//     SDL_Keycode.SDLK_2            : GBAKeyBeanComputer.NUMBER_2,
//     SDL_Keycode.SDLK_3            : GBAKeyBeanComputer.NUMBER_3,
//     SDL_Keycode.SDLK_4            : GBAKeyBeanComputer.NUMBER_4,
//     SDL_Keycode.SDLK_5            : GBAKeyBeanComputer.NUMBER_5,
//     SDL_Keycode.SDLK_6            : GBAKeyBeanComputer.NUMBER_6,
//     SDL_Keycode.SDLK_7            : GBAKeyBeanComputer.NUMBER_7,
//     SDL_Keycode.SDLK_8            : GBAKeyBeanComputer.NUMBER_8,
//     SDL_Keycode.SDLK_9            : GBAKeyBeanComputer.NUMBER_9,
//     SDL_Keycode.SDLK_COMMA        : GBAKeyBeanComputer.COMMA,
//     SDL_Keycode.SDLK_PERIOD       : GBAKeyBeanComputer.PERIOD,
//     SDL_Keycode.SDLK_SLASH        : GBAKeyBeanComputer.SLASH,
//     SDL_Keycode.SDLK_SEMICOLON    : GBAKeyBeanComputer.SEMICOLON,
//     SDL_Keycode.SDLK_QUOTE        : GBAKeyBeanComputer.QUOTE,
//     SDL_Keycode.SDLK_LEFTBRACKET  : GBAKeyBeanComputer.LBRACKET,
//     SDL_Keycode.SDLK_RIGHTBRACKET : GBAKeyBeanComputer.RBRACKET,
//     SDL_Keycode.SDLK_BACKSLASH    : GBAKeyBeanComputer.BACKSLASH,
//     SDL_Keycode.SDLK_MINUS        : GBAKeyBeanComputer.MINUS,
//     SDL_Keycode.SDLK_PLUS         : GBAKeyBeanComputer.PLUS,
//     SDL_Keycode.SDLK_TAB          : GBAKeyBeanComputer.TAB,
//     SDL_Keycode.SDLK_RETURN       : GBAKeyBeanComputer.RETURN,
//     SDL_Keycode.SDLK_BACKSPACE    : GBAKeyBeanComputer.BACKSPACE,
//     SDL_Keycode.SDLK_RIGHT        : GBAKeyBeanComputer.RIGHT,
//     SDL_Keycode.SDLK_LEFT         : GBAKeyBeanComputer.LEFT,
//     SDL_Keycode.SDLK_UP           : GBAKeyBeanComputer.UP,
//     SDL_Keycode.SDLK_DOWN         : GBAKeyBeanComputer.DOWN,
//     SDL_Keycode.SDLK_RIGHT        : GBAKeyBeanComputer.RIGHT,
//     SDL_Keycode.SDLK_LEFT         : GBAKeyBeanComputer.LEFT,
//     SDL_Keycode.SDLK_UP           : GBAKeyBeanComputer.UP,
//     SDL_Keycode.SDLK_DOWN         : GBAKeyBeanComputer.DOWN
// ];