import std.stdio;
import bindbc.sdl;
import renderer;
import gba;

void main() {
	SDLSupport ret = loadSDL();
	if (ret != sdlSupport) {
		if (ret == SDLSupport.badLibrary) {
			stderr.writeln("bad sdl library");
		} else if (ret == SDLSupport.noLibrary) {
			stderr.writeln("no sdl library");
		}
	}
	writeln("loaded sdl2");

	// TODO: fix GBA loading
	auto mem = new Memory();
	writeln("loaded mem");
	GBA gba = new GBA(mem);
	writeln("loaded gba");

	writeln("running sdl2 renderer");
	auto ren = new GameBeanSDLRenderer(gba);
	ren.init();
	ren.run();
}
