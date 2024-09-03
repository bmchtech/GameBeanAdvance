module ui.reng.console;

import std.format;
import std.stdio;
import std.algorithm;

import re.core;
import re.ng.diag.console;

import hw.gba;

class EmuConsole {
    GBA gba;

    void register() {
        Core.inspector_overlay.console.reset();

        // get the gba instance
        gba = Core.jar.resolve!GBA().get;

        // add emu commands
        Core.inspector_overlay.console.add_command(ConsoleCommand("gamebean", &cmd_gamebean, "gamebean"));

        version (coverage) {
            // add coverage commands
            Core.inspector_overlay.console.add_command(ConsoleCommand("cov_start", &cmd_cov_start, "begin coverage trace"));
            Core.inspector_overlay.console.add_command(ConsoleCommand("cov_end", &cmd_cov_end, "end coverage trace"));
            Core.inspector_overlay.console.add_command(ConsoleCommand("cov_save", &cmd_cov_save, "cov_save <base>, save coverage traces"));
        }
    }

    void unregister() {
        Core.inspector_overlay.console.reset();
    }

    void cmd_gamebean(string[] args) {
        Core.log.info("GameBeanAdvance Emulator Console");
        Core.log.info("GBA: %s", gba);
    }

    version (coverage) {
        void cmd_cov_start(string[] args) {
            Core.log.info("startning coverage trace");
            gba.cpu.coverage.new_trace();
            gba.cpu.coverage.start_tracing();
        }

        void cmd_cov_end(string[] args) {
            Core.log.info("ending coverage trace");

            auto curr_trace = gba.cpu.coverage.curr_trace;
            gba.cpu.coverage.stop_tracing();
            gba.cpu.coverage.commit_trace();

            // get statistics about the coverage
            auto n_blocks = curr_trace.block_hits.length;
            auto n_total_hits = curr_trace.block_hits.reduce!((a, b) => a + b);
            Core.log.info("  %d blocks hit %d times", n_blocks, n_total_hits);
        }

        void cmd_cov_save(string[] args) {
            if (args.length != 1) {
                Core.log.error("usage: cov_save <base>");
                return;
            }

            auto traces = gba.cpu.coverage.get_traces();
            auto save_base = args[0];

            Core.log.info("saving %d traces to %s.*.cov", traces.length, save_base);

            // coverages will be saved as <save_base>.<trace_index>.cov
            foreach (i, trace; traces) {
                auto save_path = format("%s.%s.cov", save_base, i);
                auto file = File(save_path, "w");

                Core.log.info("  saving cov#%d to %s", i, save_path);

                // write out the coverage to the file
                foreach (block_addr, n_hits; trace.block_hits) {
                    file.writefln("%08x %d", block_addr, n_hits);
                }
            }
        }
    }
}
