import std.stdio;
import bindbc.sdl;
import gui.window;

void main() {
	writeln("Hello, world!");

	/* This version attempts to load the SDL shared library using well-known variations
	of the library name for the host system.
	*/
	SDLSupport ret = loadSDL();
	if (ret != sdlSupport) {
		// Handle error. For most use cases, this is enough. The error handling API in
		// bindbc-loader can be used for error messages. If necessary, it's  possible
		// to determine the primary cause programmtically:

		if (ret == SDLSupport.noLibrary) {
			// SDL shared library failed to load
		} else if (SDLSupport.badLibrary) {
			// One or more symbols failed to load. The likely cause is that the
			// shared library is for a lower version than bindbc-sdl was configured
			// to load (via SDL_201, SDL_202, etc.)
		}
	}

	auto win = new GameBeanWindow();
	win.run();
}
