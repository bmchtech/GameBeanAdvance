module debugger.gdbstub;

version (gdbstub) {
    import gdbstub_cpp;

    import hw.gba;
    import hw.cpu;
    import hw.memory.memory : SIZE_BIOS, SIZE_WRAM_BOARD, SIZE_WRAM_CHIP, SIZE_PALETTE_RAM,
        SIZE_VRAM, SIZE_OAM, SIZE_ROM;
    import abstracthw.cpu : pc, CpuMode, Flag, MODE_FIQ, MODE_IRQ, MODE_SUPERVISOR, MODE_ABORT, MODE_UNDEFINED;
    import abstracthw.memory : Region;

    import core.atomic : atomicLoad, atomicStore;
    import core.sync.mutex : Mutex;
    import core.thread : Thread;
    import core.time : dur;

    import std.array : appender, Appender;
    import std.conv : to;
    import std.exception : enforce;
    import std.typecons : Nullable, nullable;

    private enum string CORE_FEATURE = "org.gnu.gdb.arm.core";
    private enum string EXTRA_FEATURE = "org.gnu.gdb.arm.gamebean";
    private enum string OSABI = "bare";
    private enum string XML_ARCH = "armv4t";
    private enum ulong MAIN_THREAD_ID = 1;
    private enum int SIGTRAP = 5;
    private enum int SIGINT = 2;
    private enum int REG_SIZE_BYTES = 4;
    private enum string TARGET_TRIPLE = "armv4t-unknown-elf";
    private enum string HOSTNAME = "gamebean";
    private enum ulong IO_REGION_SIZE = 0x400;
    private enum ulong SIZE_SRAM = 0x10000;
    private enum uint ROM_HALFWORD_MASK = 0x00FF_FFFF;

    enum RegKind {
        core,
        cpsr,
        spsr,
        bankedReg,
        bankedSpsr,
    }

    struct RegDesc {
        string name;
        Nullable!string altName;
        Nullable!string generic;
        string setName;
        string typeName;
        RegKind kind;
        int reg;
        CpuMode mode;
        bool coreFeature;
    }

    private final class NotifierState {
        private Mutex mutex;
        private StopNotifier notifier;

        this() {
            mutex = new Mutex();
        }

        void set(StopNotifier notifier) {
            mutex.lock();
            scope (exit) mutex.unlock();
            this.notifier = notifier;
        }

        void notify(StopReason reason) {
            StopNotifier current;
            mutex.lock();
            scope (exit) mutex.unlock();
            current = notifier;
            if (current.isValid()) {
                current.notify(reason);
            }
        }
    }

    private final class StopState {
        private Mutex mutex;
        private Nullable!StopReason last;

        this() {
            mutex = new Mutex();
            last = Nullable!StopReason.init;
        }

        void set(StopReason reason) {
            mutex.lock();
            scope (exit) mutex.unlock();
            last = nullable(reason);
        }

        Nullable!StopReason get() {
            mutex.lock();
            scope (exit) mutex.unlock();
            return last;
        }
    }

    private final class BreakpointTable {
        private Mutex mutex;
        private bool[ulong] entries;

        this() {
            mutex = new Mutex();
        }

        bool has(ulong addr) {
            mutex.lock();
            scope (exit) mutex.unlock();
            return (addr in entries) !is null;
        }

        void add(ulong addr) {
            mutex.lock();
            scope (exit) mutex.unlock();
            entries[addr] = true;
        }

        void remove(ulong addr) {
            mutex.lock();
            scope (exit) mutex.unlock();
            entries.remove(addr);
        }
    }

    final class GdbStubController {
        private GBA gba;
        private RegDesc[] regs;
        private MemoryRegion[] memoryMapCache;
        private Target target;
        private Server server;
        private Thread serverThread;
        private NotifierState notifier;
        private BreakpointTable breakpoints;
        private StopState stopState;

        private shared bool running;
        private shared bool stopRequested;
        private shared uint stepPending;
        private shared bool skipBreakpointOnce;
        private shared ulong skipBreakpointAddr;

        this(GBA gba, string address) {
            this.gba = gba;
            regs = buildRegDescs();
            memoryMapCache = buildMemoryMap();
            notifier = new NotifierState();
            breakpoints = new BreakpointTable();
            stopState = new StopState();

            auto callbacks = buildCallbacks();
            target = new Target(callbacks);

            auto arch = buildArchSpec();

            auto transport = new TransportTcp();
            server = new Server(target, arch, transport);
            enforce(server.listen(address), "failed to listen for gdbstub");

            running = false;
            stopRequested = false;
            stepPending = 0;
            skipBreakpointOnce = false;
            skipBreakpointAddr = 0;

            serverThread = new Thread({
                if (!server.waitForConnection()) {
                    return;
                }
                while (server.hasConnection()) {
                    server.poll(5);
                    Thread.sleep(dur!"msecs"(1));
                }
            });
            serverThread.start();
        }

        void stop() {
            server.stop();
            if (serverThread !is null && serverThread.isRunning()) {
                serverThread.join();
            }
        }

        bool shouldRun() const {
            return atomicLoad(running);
        }

        bool maybeStopBeforeInstruction(ARM7TDMI cpu) {
            if (!atomicLoad(running)) {
                return true;
            }

            auto pcInfo = getPcState(cpu);
            if (atomicLoad(stopRequested)) {
                auto reason = makeStopReason(StopKind.signal, SIGINT, pcInfo.client);
                requestStop(reason);
                return true;
            }

            ulong pcValue = cast(ulong)pcInfo.raw;
            if (shouldSkipBreakpoint(pcValue)) {
                return false;
            }

            if (hasBreakpoint(pcValue)) {
                auto reason = makeStopReason(StopKind.swBreak, SIGTRAP, pcInfo.client);
                requestStop(reason);
                return true;
            }

            return false;
        }

        bool maybeStopAfterInstruction(ARM7TDMI cpu) {
            if (atomicLoad(stepPending) == 0) {
                return false;
            }

            atomicStore(stepPending, 0);
            auto pcInfo = getPcState(cpu);
            auto reason = makeStopReason(StopKind.signal, SIGTRAP, pcInfo.client);
            requestStop(reason);
            return true;
        }

    private:
        TargetCallbacks buildCallbacks() {
            TargetCallbacks callbacks;
            callbacks.regs = RegsCallbacks(&regSize, &readReg, &writeReg);
            callbacks.mem = MemCallbacks(&readMem, &writeMem);
            callbacks.run = RunCallbacks(&resume, &interrupt, null, &setStopNotifier);
            callbacks.breakpoints = BreakpointsCallbacks(&setBreakpoint, &removeBreakpoint);
            callbacks.memoryLayout = MemoryLayoutCallbacks(&regionInfo, &memoryMap);
            callbacks.threads = ThreadsCallbacks(
                &threadIds,
                &currentThread,
                &setCurrentThread,
                &threadPc,
                &threadName,
                &threadStopReason
            );
            callbacks.host = HostInfoCallbacks(&hostInfo);
            callbacks.process = ProcessInfoCallbacks(&processInfo);
            callbacks.registerInfo = RegisterInfoCallbacks(&registerInfo);
            return callbacks;
        }

        ArchSpec buildArchSpec() {
            ArchSpec arch;
            arch.targetXml = buildTargetXml(regs);
            arch.xmlArchName = XML_ARCH;
            arch.osabi = OSABI;
            arch.regCount = cast(int)regs.length;
            arch.pcRegNum = 15;
            arch.addressBits = nullable(32);
            return arch;
        }

        bool hasBreakpoint(ulong addr) {
            return breakpoints.has(normalizeBreakpointAddr(addr));
        }

        bool shouldSkipBreakpoint(ulong addr) {
            if (!atomicLoad(skipBreakpointOnce)) {
                return false;
            }

            if (atomicLoad(skipBreakpointAddr) != normalizeBreakpointAddr(addr)) {
                return false;
            }

            atomicStore(skipBreakpointOnce, false);
            return true;
        }

        void requestStop(StopReason reason) {
            atomicStore(running, false);
            atomicStore(stopRequested, false);
            stopState.set(reason);
            notifier.notify(reason);
        }

        Nullable!StopReason getLastStop() {
            return stopState.get();
        }

        StopReason makeStopReason(StopKind kind, int signal, ulong addr) {
            StopReason reason;
            reason.kind = kind;
            reason.signal = signal;
            reason.addr = addr;
            reason.threadId = nullable(MAIN_THREAD_ID);
            return reason;
        }

        struct PcState {
            uint raw;
            uint client;
        }

        PcState getPcState(ARM7TDMI cpu) {
            PcState state;
            uint pcValue = cpu.get_reg(pc);
            uint delta = cpu.get_instruction_set() == InstructionSet.ARM ? 4u : 2u;
            state.raw = pcValue < delta ? 0u : pcValue - delta;
            state.client = state.raw;
            if (cpu.get_instruction_set() == InstructionSet.THUMB) {
                state.client |= 1;
            }
            return state;
        }

        ulong normalizeBreakpointAddr(ulong addr) {
            return addr & ~1UL;
        }

        uint readU32Le(const(ubyte)[] data) {
            return cast(uint)data[0]
                | (cast(uint)data[1] << 8)
                | (cast(uint)data[2] << 16)
                | (cast(uint)data[3] << 24);
        }

        void writeU32Le(ubyte[] buffer, uint value) {
            buffer[0] = cast(ubyte)(value & 0xFF);
            buffer[1] = cast(ubyte)((value >> 8) & 0xFF);
            buffer[2] = cast(ubyte)((value >> 16) & 0xFF);
            buffer[3] = cast(ubyte)((value >> 24) & 0xFF);
        }

        size_t regSize(int regno) {
            if (regno < 0 || regno >= regs.length) {
                return 0;
            }
            return REG_SIZE_BYTES;
        }

        TargetStatus readReg(int regno, ubyte[] buffer) {
            if (regno < 0 || regno >= regs.length || buffer.length < REG_SIZE_BYTES) {
                return TargetStatus.invalid;
            }

            auto value = readRegValue(regs[regno]);
            writeU32Le(buffer[0 .. REG_SIZE_BYTES], value);
            return TargetStatus.ok;
        }

        TargetStatus writeReg(int regno, const(ubyte)[] data) {
            if (regno < 0 || regno >= regs.length || data.length < REG_SIZE_BYTES) {
                return TargetStatus.invalid;
            }

            uint value = readU32Le(data);

            writeRegValue(regs[regno], value);
            return TargetStatus.ok;
        }

        uint readRegValue(RegDesc desc) {
            auto cpu = gba.cpu;
            final switch (desc.kind) {
                case RegKind.core:
                    if (desc.reg == pc) {
                        return getPcState(cpu).client;
                    }
                    return cpu.get_reg(desc.reg);
                case RegKind.cpsr:
                    return cpu.get_cpsr();
                case RegKind.spsr:
                    return cpu.get_spsr();
                case RegKind.bankedReg:
                    return cpu.get_reg(desc.reg, desc.mode);
                case RegKind.bankedSpsr:
                    return cpu.get_reg(17, desc.mode);
            }
        }

        void writeRegValue(RegDesc desc, uint value) {
            auto cpu = gba.cpu;
            final switch (desc.kind) {
                case RegKind.core:
                    cpu.set_reg(desc.reg, value);
                    break;
                case RegKind.cpsr:
                    cpu.set_cpsr(value);
                    cpu.update_mode();
                    break;
                case RegKind.spsr:
                    cpu.set_spsr(value);
                    break;
                case RegKind.bankedReg:
                    cpu.set_reg(desc.reg, value, desc.mode);
                    break;
                case RegKind.bankedSpsr:
                    cpu.set_reg(17, value, desc.mode);
                    break;
            }
        }

        TargetStatus readMem(ulong addr, ubyte[] buffer) {
            if (addr > uint.max) {
                return TargetStatus.fault;
            }

            uint address = cast(uint)addr;
            for (size_t i = 0; i < buffer.length; ++i) {
                ubyte value;
                if (!readByte(address + cast(uint)i, value)) {
                    return TargetStatus.fault;
                }
                buffer[i] = value;
            }
            return TargetStatus.ok;
        }

        TargetStatus writeMem(ulong addr, const(ubyte)[] data) {
            if (addr > uint.max) {
                return TargetStatus.fault;
            }

            uint address = cast(uint)addr;
            for (size_t i = 0; i < data.length; ++i) {
                if (!writeByte(address + cast(uint)i, data[i])) {
                    return TargetStatus.fault;
                }
            }
            return TargetStatus.ok;
        }

        uint vramOffset(uint address) {
            uint wrapped = address & (SIZE_VRAM - 1);
            if (wrapped >= 0x18000) {
                wrapped -= 0x8000;
            }
            return wrapped;
        }

        uint romHalfwordIndex(uint address) {
            return (address >> 1) & ROM_HALFWORD_MASK;
        }

        bool readByte(uint address, out ubyte value) {
            auto region = gba.memory.get_region(address);
            switch (region) {
                case Region.BIOS:
                    if (address >= SIZE_BIOS) {
                        return false;
                    }
                    value = gba.memory.bios[address & (SIZE_BIOS - 1)];
                    return true;
                case Region.WRAM_BOARD:
                    value = gba.memory.wram_board[address & (SIZE_WRAM_BOARD - 1)];
                    return true;
                case Region.WRAM_CHIP:
                    value = gba.memory.wram_chip[address & (SIZE_WRAM_CHIP - 1)];
                    return true;
                case Region.IO_REGISTERS:
                    if (gba.memory.mmio is null) {
                        return false;
                    }
                    value = gba.memory.mmio.read(address);
                    return true;
                case Region.PALETTE_RAM:
                    value = gba.memory.palette_ram[address & (SIZE_PALETTE_RAM - 1)];
                    return true;
                case Region.VRAM: {
                    value = gba.memory.vram[vramOffset(address)];
                    return true;
                }
                case Region.OAM:
                    value = gba.memory.oam[address & (SIZE_OAM - 1)];
                    return true;
                case Region.ROM_WAITSTATE_0_L:
                case Region.ROM_WAITSTATE_0_H:
                case Region.ROM_WAITSTATE_1_L:
                case Region.ROM_WAITSTATE_1_H:
                case Region.ROM_WAITSTATE_2_L:
                case Region.ROM_WAITSTATE_2_H: {
                    if (gba.memory.rom is null) {
                        return false;
                    }
                    ushort half = gba.memory.rom.read(romHalfwordIndex(address));
                    value = cast(ubyte)((address & 1) == 0 ? (half & 0xFF) : (half >> 8));
                    return true;
                }
                case Region.ROM_SRAM_L:
                case Region.ROM_SRAM_H:
                    if (!gba.memory.backup_enabled) {
                        return false;
                    }
                    value = gba.memory.backup.read_byte(address);
                    return true;
                default:
                    return false;
            }
        }

        bool writeByte(uint address, ubyte value) {
            auto region = gba.memory.get_region(address);
            switch (region) {
                case Region.WRAM_BOARD:
                    gba.memory.wram_board[address & (SIZE_WRAM_BOARD - 1)] = value;
                    return true;
                case Region.WRAM_CHIP:
                    gba.memory.wram_chip[address & (SIZE_WRAM_CHIP - 1)] = value;
                    return true;
                case Region.IO_REGISTERS:
                    if (gba.memory.mmio is null) {
                        return false;
                    }
                    gba.memory.mmio.write(address, value);
                    return true;
                case Region.PALETTE_RAM:
                    gba.memory.palette_ram[address & (SIZE_PALETTE_RAM - 1)] = value;
                    return true;
                case Region.VRAM: {
                    gba.memory.vram[vramOffset(address)] = value;
                    return true;
                }
                case Region.OAM:
                    gba.memory.oam[address & (SIZE_OAM - 1)] = value;
                    return true;
                case Region.ROM_SRAM_L:
                case Region.ROM_SRAM_H:
                    if (!gba.memory.backup_enabled) {
                        return false;
                    }
                    gba.memory.backup.write_byte(address, value);
                    return true;
                default:
                    return false;
            }
        }

        ResumeResult resume(ResumeRequest request) {
            if (!request.addr.isNull) {
                uint targetPc = cast(uint)request.addr.get;
                bool thumb = (targetPc & 1) != 0;
                gba.cpu.set_flag(Flag.T, thumb);
                gba.cpu.set_reg(pc, targetPc & ~1u);
            }

            if (request.action == ResumeAction.step) {
                atomicStore(stepPending, 1);
            } else {
                atomicStore(stepPending, 0);
            }

            auto last = getLastStop();
            if (!last.isNull && last.get.kind == StopKind.swBreak) {
                atomicStore(skipBreakpointAddr, normalizeBreakpointAddr(last.get.addr));
                atomicStore(skipBreakpointOnce, true);
            }

            atomicStore(stopRequested, false);
            atomicStore(running, true);

            ResumeResult result;
            result.state = ResumeState.running;
            return result;
        }

        void interrupt() {
            atomicStore(stopRequested, true);
        }

        void setStopNotifier(StopNotifier notifier) {
            this.notifier.set(notifier);
        }

        TargetStatus setBreakpoint(BreakpointSpec spec) {
            if (spec.type == BreakpointType.watchRead ||
                spec.type == BreakpointType.watchWrite ||
                spec.type == BreakpointType.watchAccess) {
                return TargetStatus.unsupported;
            }

            breakpoints.add(normalizeBreakpointAddr(spec.addr));
            return TargetStatus.ok;
        }

        TargetStatus removeBreakpoint(BreakpointSpec spec) {
            breakpoints.remove(normalizeBreakpointAddr(spec.addr));
            return TargetStatus.ok;
        }

        MemoryRegion[] memoryMap() {
            return memoryMapCache;
        }

        Nullable!MemoryRegionInfo regionInfo(ulong addr) {
            foreach (region; memoryMapCache) {
                if (addr >= region.start && addr < region.start + region.size) {
                    MemoryRegionInfo info;
                    info.start = region.start;
                    info.size = region.size;
                    info.mapped = true;
                    info.perms = region.perms;
                    info.name = region.name;
                    info.types = region.types;
                    return nullable(info);
                }
            }
            return Nullable!MemoryRegionInfo.init;
        }

        ulong[] threadIds() {
            return [MAIN_THREAD_ID];
        }

        ulong currentThread() {
            return MAIN_THREAD_ID;
        }

        TargetStatus setCurrentThread(ulong tid) {
            return tid == MAIN_THREAD_ID ? TargetStatus.ok : TargetStatus.invalid;
        }

        Nullable!ulong threadPc(ulong tid) {
            if (tid != MAIN_THREAD_ID) {
                return Nullable!ulong.init;
            }
            return nullable(cast(ulong)getPcState(gba.cpu).client);
        }

        Nullable!string threadName(ulong tid) {
            if (tid != MAIN_THREAD_ID) {
                return Nullable!string.init;
            }
            return nullable("main");
        }

        Nullable!StopReason threadStopReason(ulong tid) {
            if (tid != MAIN_THREAD_ID) {
                return Nullable!StopReason.init;
            }
            return getLastStop();
        }

        Nullable!HostInfo hostInfo() {
            HostInfo info;
            info.triple = TARGET_TRIPLE;
            info.endian = "little";
            info.ptrSize = 4;
            info.hostname = HOSTNAME;
            info.addressingBits = nullable(32);
            return nullable(info);
        }

        Nullable!ProcessInfo processInfo() {
            ProcessInfo info;
            info.pid = 1;
            info.triple = TARGET_TRIPLE;
            info.endian = "little";
            info.ptrSize = 4;
            info.ostype = "bare";
            return nullable(info);
        }

        Nullable!RegisterInfo registerInfo(int regno) {
            if (regno < 0 || regno >= regs.length) {
                return Nullable!RegisterInfo.init;
            }

            auto desc = regs[regno];
            RegisterInfo info;
            info.name = desc.name;
            info.altName = desc.altName;
            info.bitsize = REG_SIZE_BYTES * 8;
            info.encoding = "uint";
            info.format = "hex";
            info.set = nullable(desc.setName);
            info.gccRegnum = desc.coreFeature ? nullable(regno) : Nullable!int.init;
            info.dwarfRegnum = desc.coreFeature ? nullable(regno) : Nullable!int.init;
            info.generic = desc.generic;
            return nullable(info);
        }
    }

    __gshared GdbStubController gdbstub;

    void start_gdbstub(GBA gba, string address) {
        gdbstub = new GdbStubController(gba, address);
    }

    bool is_active() {
        return gdbstub !is null;
    }

    bool should_run() {
        return gdbstub !is null && gdbstub.shouldRun();
    }

    bool maybe_stop_before(ARM7TDMI cpu) {
        return gdbstub !is null && gdbstub.maybeStopBeforeInstruction(cpu);
    }

    bool maybe_stop_after(ARM7TDMI cpu) {
        return gdbstub !is null && gdbstub.maybeStopAfterInstruction(cpu);
    }

    void shutdown_gdbstub() {
        if (gdbstub is null) {
            return;
        }
        gdbstub.stop();
        gdbstub = null;
    }

    private RegDesc[] buildRegDescs() {
        RegDesc[] descs;

        foreach (i; 0 .. 13) {
            descs ~= makeCoreReg("r" ~ to!string(i), i, "general", "uint32");
        }

        descs ~= makeCoreReg("sp", 13, "general", "data_ptr", nullable("r13"), nullable("sp"));
        descs ~= makeCoreReg("lr", 14, "general", "uint32", nullable("r14"));
        descs ~= makeCoreReg("pc", 15, "general", "code_ptr", nullable("r15"), nullable("pc"));

        descs ~= makeStatusReg("cpsr", RegKind.cpsr, "status", true, nullable("flags"));
        descs ~= makeStatusReg("spsr", RegKind.spsr, "status", false);

        addBankedRegs(descs, MODE_FIQ, "fiq", [8, 9, 10, 11, 12, 13, 14]);
        addBankedRegs(descs, MODE_IRQ, "irq", [13, 14]);
        addBankedRegs(descs, MODE_SUPERVISOR, "svc", [13, 14]);
        addBankedRegs(descs, MODE_ABORT, "abt", [13, 14]);
        addBankedRegs(descs, MODE_UNDEFINED, "und", [13, 14]);

        return descs;
    }

    private RegDesc makeCoreReg(
        string name,
        int reg,
        string setName,
        string typeName,
        Nullable!string altName = Nullable!string.init,
        Nullable!string generic = Nullable!string.init
    ) {
        RegDesc desc;
        desc.name = name;
        desc.altName = altName;
        desc.generic = generic;
        desc.setName = setName;
        desc.typeName = typeName;
        desc.kind = RegKind.core;
        desc.reg = reg;
        desc.coreFeature = true;
        return desc;
    }

    private RegDesc makeStatusReg(
        string name,
        RegKind kind,
        string setName,
        bool coreFeature,
        Nullable!string generic = Nullable!string.init
    ) {
        RegDesc desc;
        desc.name = name;
        desc.generic = generic;
        desc.setName = setName;
        desc.typeName = "uint32";
        desc.kind = kind;
        desc.coreFeature = coreFeature;
        return desc;
    }

    private RegDesc makeBankedReg(string name, int reg, CpuMode mode) {
        RegDesc desc;
        desc.name = name;
        desc.setName = "banked";
        desc.typeName = "uint32";
        desc.kind = RegKind.bankedReg;
        desc.reg = reg;
        desc.mode = mode;
        return desc;
    }

    private RegDesc makeBankedSpsr(string name, CpuMode mode) {
        RegDesc desc;
        desc.name = name;
        desc.setName = "banked";
        desc.typeName = "uint32";
        desc.kind = RegKind.bankedSpsr;
        desc.mode = mode;
        return desc;
    }

    private void addBankedRegs(ref RegDesc[] descs, CpuMode mode, string suffix, int[] regs) {
        foreach (reg; regs) {
            descs ~= makeBankedReg("r" ~ to!string(reg) ~ "_" ~ suffix, reg, mode);
        }
        descs ~= makeBankedSpsr("spsr_" ~ suffix, mode);
    }

    private string buildTargetXml(RegDesc[] regs) {
        auto xml = appender!string();
        xml.put("<target version=\"1.0\">");
        xml.put("<architecture>" ~ XML_ARCH ~ "</architecture>");
        xml.put("<feature name=\"" ~ CORE_FEATURE ~ "\">");
        foreach (i, desc; regs) {
            if (!desc.coreFeature) {
                continue;
            }
            appendRegXml(xml, desc, cast(int)i);
        }
        xml.put("</feature>");
        xml.put("<feature name=\"" ~ EXTRA_FEATURE ~ "\">");
        foreach (i, desc; regs) {
            if (desc.coreFeature) {
                continue;
            }
            appendRegXml(xml, desc, cast(int)i);
        }
        xml.put("</feature>");
        xml.put("</target>");
        return xml.data;
    }

    private void appendRegXml(ref Appender!string xml, RegDesc desc, int regnum) {
        xml.put("<reg name=\"");
        xml.put(desc.name);
        xml.put("\" bitsize=\"32\" type=\"");
        xml.put(desc.typeName);
        xml.put("\" regnum=\"");
        xml.put(to!string(regnum));
        xml.put("\"");
        if (!desc.altName.isNull) {
            xml.put(" altname=\"");
            xml.put(desc.altName.get);
            xml.put("\"");
        }
        if (!desc.generic.isNull) {
            xml.put(" generic=\"");
            xml.put(desc.generic.get);
            xml.put("\"");
        }
        xml.put("/>");
    }

    private MemoryRegion[] buildMemoryMap() {
        MemoryRegion[] regions;
        regions ~= makeRegion("bios", 0x00000000, SIZE_BIOS, permsReadExec(), ["rom", "bios"]);
        regions ~= makeRegion("wram-board", 0x02000000, SIZE_WRAM_BOARD, permsReadWriteExec(), ["ram"]);
        regions ~= makeRegion("wram-chip", 0x03000000, SIZE_WRAM_CHIP, permsReadWriteExec(), ["ram"]);
        regions ~= makeRegion("io", 0x04000000, IO_REGION_SIZE, permsReadWrite(), ["io"]);
        regions ~= makeRegion("palette", 0x05000000, SIZE_PALETTE_RAM, permsReadWrite(), ["ram"]);
        regions ~= makeRegion("vram", 0x06000000, SIZE_VRAM, permsReadWrite(), ["ram"]);
        regions ~= makeRegion("oam", 0x07000000, SIZE_OAM, permsReadWrite(), ["ram"]);
        regions ~= makeRegion("rom-0", 0x08000000, SIZE_ROM, permsReadExec(), ["rom"]);
        regions ~= makeRegion("rom-1", 0x0A000000, SIZE_ROM, permsReadExec(), ["rom"]);
        regions ~= makeRegion("rom-2", 0x0C000000, SIZE_ROM, permsReadExec(), ["rom"]);
        regions ~= makeRegion("sram", 0x0E000000, SIZE_SRAM, permsReadWrite(), ["ram"]);
        return regions;
    }

    private MemoryRegion makeRegion(string name, ulong start, ulong size, MemPerm perms, string[] types) {
        MemoryRegion region;
        region.start = start;
        region.size = size;
        region.perms = perms;
        region.name = nullable(name);
        region.types = types;
        return region;
    }

    private MemPerm permsReadWrite() {
        return cast(MemPerm)(MemPerm.read | MemPerm.write);
    }

    private MemPerm permsReadExec() {
        return cast(MemPerm)(MemPerm.read | MemPerm.exec);
    }

    private MemPerm permsReadWriteExec() {
        return cast(MemPerm)(MemPerm.read | MemPerm.write | MemPerm.exec);
    }
}
