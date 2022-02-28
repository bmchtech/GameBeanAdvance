module app;

import hw.gba;
import hw.memory;
import hw.keyinput;

import util;

import diag.log;

import std.stdio;
import std.conv;
import std.file;
import std.uri;
import std.algorithm.searching: canFind;
import std.mmfile;
import std.file;
import save;

import core.sync.mutex;

import bindbc.sdl;
import bindbc.opengl;

import ui.device.frontend.rengfrontend;

import ui.device.debugger.debugger;
import ui.device.device;
import ui.device.manager;
import ui.device.runner.runner;

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
	log!(LogSource.INIT)("SDL loaded successfully");


	auto mem = new Memory();

	bool is_beancomputer = a.option("mod").canFind("beancomputer");
	if (is_beancomputer) log!(LogSource.INIT)("BeanComputer enabled");

	KeyInput key_input = new KeyInput(mem);
	auto bios_data = load_rom_as_bytes(a.option("bios"));
	GBA gba = new GBA(mem, key_input, bios_data, is_beancomputer);

	// load rom
	auto rom_path = a.arg("rompath");
	log!(LogSource.INIT)("Loading rom from: %s.", rom_path);

	// check file
	if (uriLength(rom_path) > 0) {
		import std.net.curl : download;
		import std.path: buildPath;
		import std.uuid: randomUUID;

		auto dl_path = buildPath(tempDir(), randomUUID().toString());
		download(rom_path, dl_path);

		auto rom_data = load_rom_as_bytes(dl_path);

		log!(LogSource.INIT)("Downloaded %s bytes as %s", rom_data.length, dl_path);

		gba.load_rom(rom_data);
	} else if (std.file.exists(rom_path)) {
		gba.load_rom(rom_path);
	} else {
		error("rom file does not exist!");
	}

	if (a.flag("bootscreen")) gba.skip_bios_bootscreen();

	MultiMediaDevice frontend = new RengFrontend();
	gba.set_frontend(frontend);

	gba.set_internal_sample_rate(16_780_000 / frontend.get_sample_rate());
	
	auto sample_rate          = frontend.get_sample_rate();
	auto samples_per_callback = frontend.get_samples_per_callback();

	int num_batches        = sample_rate / samples_per_callback;
	enum cycles_per_second = 16_780_000;
	auto cycles_per_batch  = 69; // cycles_per_second / num_batches;
	Runner runner = new Runner(gba, cycles_per_batch, frontend);

	DeviceManager device_manager = new DeviceManager();
	device_manager.add_device(runner);
	device_manager.add_device(frontend);

	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0)
		assert(0, "sdl init failed");

	if (a.flag("pause")) {
		readln();
	}

	Savetype savetype = detect_savetype(gba.memory.rom.get_bytes());
	
	if (savetype != Savetype.NONE && savetype != Savetype.UNKNOWN) {
		Backup save = create_savetype(savetype);
		gba.memory.add_backup(save);

		bool file_exists = "test.beansave".exists;

		if (file_exists) {
			MmFile mm_file = new MmFile("test.beansave", MmFile.Mode.readWrite, save.get_backup_size(), null, 0);
			save.deserialize(cast(ubyte[]) mm_file[]);
			save.set_backup_file(mm_file);
		}
	}

	SDL_PauseAudio(0);
	runner.run();

	version (gperf) {
		log!(LogSource.DEBUG)("Started profiler");
		ProfilerStart();
	}

	version (gperf) {
		ProfilerStop();
		log!(LogSource.DEBUG)("Ended profiler");
	}
}
