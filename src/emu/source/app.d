import hw.gba;
import hw.memory;
import hw.keyinput;

import util;

// import save_detector;

import std.stdio;
import std.conv;
import std.file;
import std.uri;
import std.algorithm.searching: canFind;

import bindbc.sdl;
import bindbc.opengl;

import host.sdl;

import commandr;

version (gperf) {
	import gperftools_d.profiler;
}

void main(string[] args) {
	// dfmt off
	auto a = new Program("gamebean-emu", "0.1").summary("GameBean Advance")
		.add(new Flag("v", "verbose", "turns on more verbose output").repeating)
		.add(new Option("s", "scale", "render scale").optional.defaultValue("1"))
		.add(new Argument("rompath", "path to rom file"))
		.add(new Option("b", "bios", "path to bios file").optional.defaultValue("./gba_bios.bin"))
		.add(new Flag("p", "pause", "pause until enter on stdin"))
		.add(new Flag("k", "bootscreen", "skips bios bootscreen and starts the rom directly"))
		.add(new Option("m", "mod", "enable mod/extension"))
		.add(new Option("t", "cputrace", "display cpu trace on crash").optional.defaultValue("0"))
		.parse(args);
	// dfmt on

	util.verbosity_level = a.occurencesOf("verbose");

	auto ret_SDL = loadSDL();
	if (ret_SDL != sdlSupport) {
		if (ret_SDL == SDLSupport.badLibrary) {
			error("bad sdl library");
		} else if (ret_SDL == SDLSupport.noLibrary) {
			error("no sdl library");
		}
	}
	writeln("loaded sdl2");

	auto mem = new Memory();
	writeln("init mem");

	bool is_beancomputer = a.option("mod").canFind("beancomputer");
	if (is_beancomputer) writefln("creating beancomputer");

	KeyInput key_input = new KeyInput(mem);
	auto bios_data = load_rom_as_bytes(a.option("bios"));
	GBA gba = new GBA(mem, key_input, bios_data, is_beancomputer);
	if (a.flag("bootscreen")) gba.skip_bios_bootscreen();
	
	writeln("init gba");

	// load rom
	auto rom_path = a.arg("rompath");
	writefln("loading rom from: %s", rom_path);

	// check file
	if (uriLength(rom_path) > 0) {
		import std.net.curl : download;
		import std.path: buildPath;
		import std.uuid: randomUUID;

		auto dl_path = buildPath(tempDir(), randomUUID().toString());
		download(rom_path, dl_path);

		auto rom_data = load_rom_as_bytes(dl_path);

		writefln("downloaded %s bytes as %s", rom_data.length, dl_path);

		gba.load_rom(rom_data);
	} else if (std.file.exists(rom_path)) {
		gba.load_rom(rom_path);
	} else {
		assert(0, "rom file does not exist!");
	}

	// writefln("UwU: %s", to!string(detect_savetype(gba.memory.rom)));

	writeln("running sdl2 renderer");
	auto host = new GameBeanSDLHost(gba, to!int(a.option("scale")));
	host.init();

	int cpu_trace_length = to!int(a.option("cputrace"));
	if (cpu_trace_length != 0) {
		host.enable_cpu_tracing(cpu_trace_length);
	}

	if (a.flag("pause")) {
		readln();
	}

	version (gperf) {
		writeln("---- STARTED PROFILER ----");
		ProfilerStart();
	}

	host.run();

	version (gperf) {
		ProfilerStop();
		writeln("---- ENDED PROFILER ----");
	}

	scope (failure)
		host.print_trace();
}
