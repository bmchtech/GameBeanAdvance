import std.stdio;
import bindbc.sdl;
import host.sdl;
import gba;
import commandr;
import util;
import std.conv;

version (gperf) {
	import gperftools_d.profiler;
}

void main(string[] args) {
	auto a = new Program("gamebean-emu", "0.1").summary("GameBean Advance")
			.add(new Flag("v", "verbose", "turns on more verbose output").repeating)
			.add(new Option("s", "scale", "render scale").optional.defaultValue("1"))
			.add(new Argument("rompath", "path to rom file")).parse(args);

	util.verbosity_level = a.occurencesOf("verbose");

	SDLSupport ret = loadSDL();
	if (ret != sdlSupport) {
		if (ret == SDLSupport.badLibrary) {
			stderr.writeln("bad sdl library");
		} else if (ret == SDLSupport.noLibrary) {
			stderr.writeln("no sdl library");
		}
	}
	writeln("loaded sdl2");

	auto mem = new Memory();
	writeln("init mem");
	GBA gba = new GBA(mem);
	writeln("init gba");
	gba.load_rom(a.arg("rompath"));
	writeln("loaded rom");

	writeln("running sdl2 renderer");
	auto host = new GameBeanSDLHost(gba, to!int(a.option("scale")));
	host.init();

	version (gperf) {
		writeln("---- STARTED PROFILER ----");
		ProfilerStart();
	}

	host.run();

	version (gperf) {
		ProfilerStop();
		writeln("---- ENDED PROFILER ----");
	}
}
