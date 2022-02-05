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

import bindbc.sdl;
import bindbc.opengl;

import ui.video.sdl.sdldevice;
import ui.audio.sdl.sdldevice;

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


    SDLAudioDevice audio_device;
    SDLVideoDevice video_device;

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

		log!(LogSource.INIT)("DownloaDed %s bytes as %s", rom_data.length, dl_path);

		gba.load_rom(rom_data);
	} else if (std.file.exists(rom_path)) {
		gba.load_rom(rom_path);
	} else {
		error("rom file does not exist!");
	}

	if (a.flag("bootscreen")) gba.skip_bios_bootscreen();
	

	audio_device = new SDLAudioDevice();

	gba.set_internal_sample_rate(16_780_000 / audio_device.spec.freq);
	gba.set_audio_device(audio_device);
	
	auto sample_rate      = audio_device.spec.freq;
	auto samples_per_callback = audio_device.spec.samples;

	video_device = new SDLVideoDevice();
	gba.set_video_device(video_device);

		
	// auto host = new GameBeanSDLHost(gba, to!int(a.option("scale")));

	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0)
		assert(0, "sdl init failed");



	// int cpu_trace_length = to!int(a.option("cputrace"));
	// if (cpu_trace_length != 0) {
	// 	host.enable_cpu_tracing(cpu_trace_length);
	// }

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

	bool running = true;

	int num_batches       = sample_rate / samples_per_callback;
	enum cycles_per_second = 16_780_000;
	auto cycles_per_batch  = cycles_per_second / num_batches;

	SDL_PauseAudio(0);

	// // 16.6666 ms
	enum nsec_per_frame = 16_666_660;
	enum msec_per_frame = 16;

	auto stopwatch = new NSStopwatch();
	// long clockfor_cycle = 0;
	long clockfor_frame = 0;
	// auto total_cycles = 0;

	enum sec_per_log = 1;
	enum nsec_per_log = sec_per_log * 1_000_000_000;
	enum msec_per_log = sec_per_log * 1_000;
	enum cycles_per_log = cycles_per_second * sec_per_log;
	long clockfor_log = 0;
	ulong cycles_since_last_log = 0;

	ulong cycle_timestamp = 0;

	ulong start_timestamp = SDL_GetTicks();

	while (running) {
		ulong end_timestamp = SDL_GetTicks();
		ulong elapsed = end_timestamp - start_timestamp;
		start_timestamp = end_timestamp;

		clockfor_log   += elapsed;
		clockfor_frame += elapsed;

		if (gba.enabled) {
			// if (!fast_forward) {
				while (samples_per_callback * 2 > audio_buffer_offset) {
					gba.cycle_at_least_n_times(cycles_per_batch);
				}
			// } else {
				// gba.cycle_at_least_n_times(cycles_per_batch);
			// }
		} else {
			// TODO: figure out wtf to do here
			// video_device.();
		}
		// frame();

		// if (clockfor_log > msec_per_log) {
		// 	ulong cycles_elapsed = gba.scheduler.get_current_time() - cycle_timestamp;
		// 	cycle_timestamp = gba.scheduler.get_current_time();
		// 	double speed = ((cast(double) cycles_elapsed) / (cast(double) cycles_per_second));
		// 	SDL_SetWindowTitle(window, cast(char*) ("FPS: " ~ format("%d", fps)));
		// 	// SDL_SetWindowTitle(window, cast(char*) format("Speed: %f", speed));
		// 	clockfor_log = 0;
		// 	cycles_since_last_log = 0;
		// 	fps = 0;
		// }
	}

	version (gperf) {
		log!(LogSource.DEBUG)("Started profiler");
		ProfilerStart();
	}

	version (gperf) {
		ProfilerStop();
		log!(LogSource.DEBUG)("Ended profiler");
	}

	// scope (failure)
	// 	host.print_trace();
}
