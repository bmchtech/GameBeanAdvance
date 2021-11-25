module debugger.loaders.symbol_loader;

import util;

import std.file;
import std.stdio;
import std.conv;
import std.typecons;

struct Symbol {
    string name;
    string obj_file;

    uint   size;
    uint   start_address;
    uint   end_address;
}

class ELFFileParser {
    enum ELF_MAGIC_NUMBER = 0x464C457F;

    enum IdentClass {
        INVALID,
        FORMAT_32 = 1,
        FORMAT_64 = 2
    }

    enum IdentData {
        LITTLEENDIAN = 1,
        BIGENDIAN    = 2
    }

    enum SectionType {
        SHT_NULL          = 0x0,
        SHT_PROGBITS      = 0x1,
        SHT_SYMTAB        = 0x2,
        SHT_STRTAB        = 0x3,
        SHT_RELA          = 0x4,
        SHT_HASH          = 0x5,
        SHT_DYNAMIC       = 0x6,
        SHT_NOTE          = 0x7,
        SHT_NOBITS        = 0x8,
        SHT_REL           = 0x9,
        SHT_SHLIB         = 0xA,
        SHT_DYNSYM        = 0xB,
        SHT_INIT_ARRAY    = 0xE,
        SHT_FINI_ARRAY    = 0xF,
        SHT_PREINIT_ARRAY = 0x10,
        SHT_GROUP         = 0x11,
        SHT_SYMTAB_SHNDX  = 0x12,
        SHT_NUM           = 0x13,
        SHT_LOOS          = 0x60000000
    }

    static enum Machine {
        ARM = 0x28
    }

    struct ELFHeader {
        uint   e_phoff;
        uint   e_shoff;
        ushort e_phentsize;
        ushort e_phnum;
        ushort e_shentsize;
        ushort e_shnum;
        ushort e_shstrndx;
    }

    struct SectionHeader {
        uint sh_name;
        uint sh_type;
        uint sh_addr;
        uint sh_offset;
        uint sh_size;
        uint sh_entsize;
    }

    struct SymbolTableEntry {
        uint   st_name;
        uint   st_value;
        uint   st_size;
        ubyte  st_info;
        ubyte  st_other;
        ushort st_shndx;
    }

    ulong  file_pointer;
    ubyte* file_data;

    public this(ubyte* file_data) {
        this.file_data  = file_data;
    }

    public Symbol[] parse() {
        ELFHeader elf_header = parse_elf_header();
        SectionHeader* section_headers = collect_section_headers(elf_header);

        // let's collect the useful sections
        auto section_shstrtab  = section_headers[elf_header.e_shstrndx];
        auto section_strtab    = get_section_header_with_name__assert(elf_header, section_headers, section_shstrtab, ".strtab",
            "No section .strsymtab found in ELF file. Are you sure you turned on debug symbols?");
        auto section_symtab    = get_section_header_with_name__assert(elf_header, section_headers, section_shstrtab, ".symtab",
            "No section .symtab found in ELF file. Are you sure you turned on debug symbols?");

        SymbolTableEntry* symbol_table_entries = collect_symbol_table_entries(elf_header, section_symtab);
        uint num_entries = section_symtab.sh_size / section_symtab.sh_entsize;
        for (int i = 0; i < num_entries; i++) {
            this.file_pointer =  section_strtab.sh_offset;
            this.file_pointer += symbol_table_entries[i].st_name;
            writefln("%08x ~ %08x: %s", symbol_table_entries[i].st_value, symbol_table_entries[i].st_value + symbol_table_entries[i].st_size, to!string(cast(char*) (this.file_data + this.file_pointer)));
        }

        return [];
    }

    private ELFHeader parse_elf_header() {
        // parse the header
        auto magic_number = read!uint();
        if (magic_number != ELF_MAGIC_NUMBER) error(format("Are you sure this is an ELF file?"));

        auto byte_format = read!ubyte();
        if (byte_format != IdentClass.FORMAT_32) error("ELF file has an incompatible format. Only 32-bit is supported.");

        auto byte_endianness = read!ubyte();
        if (byte_endianness != IdentData.LITTLEENDIAN) error("ELF file has an incompatible format. Only little endian is supported");

        advance_pointer(1); // skip elf version
        advance_pointer(1); // skip OS abi
        advance_pointer(1); // skip OS abi supplement
        advance_pointer(7); // should be zeros
        advance_pointer(2); // skip object file type

        auto machine = read!ushort();
        if (machine != Machine.ARM) error("ELF file's target ISA does not seem to be ARM.");

        advance_pointer(4); // skip elf version... again

        auto entry_point = read!uint();
        if (entry_point != 0x0800_0000) error(format("ELF file specifies a bad entry point! (%x)", entry_point));

        // finally, the stuff we actually want
        ELFHeader elf_header;

        elf_header.e_phoff     = read!uint();
        elf_header.e_shoff     = read!uint();
        advance_pointer(4); // skip target architecture specific stuffs. they seem to be unused on arm7tdmi anyway
        advance_pointer(2); // skip header size, it's basically static
        elf_header.e_phentsize = read!ushort();
        elf_header.e_phnum     = read!ushort();
        elf_header.e_shentsize = read!ushort();
        elf_header.e_shnum     = read!ushort();
        elf_header.e_shstrndx  = read!ushort();

        return elf_header;
    }

    private SectionHeader parse_section_header() {
        SectionHeader section_header;

        section_header.sh_name    = read!uint();
        section_header.sh_type    = read!uint();
        advance_pointer(4); // skip the section flags
        section_header.sh_addr    = read!uint();
        section_header.sh_offset  = read!uint();
        section_header.sh_size    = read!uint();
        // writefln("%x", read!uint());
        advance_pointer(4); // skip the section link
        advance_pointer(4); // skip the section info
        advance_pointer(4); // skip the section address alignment
        section_header.sh_entsize = read!uint();

        return section_header;
    }

    private SymbolTableEntry parse_symbol_table_entry() {
        SymbolTableEntry symbol_table_entry;

        symbol_table_entry.st_name  = read!uint();
        symbol_table_entry.st_value = read!uint();
        symbol_table_entry.st_size  = read!uint();
        symbol_table_entry.st_info  = read!ubyte();
        symbol_table_entry.st_other = read!ubyte();
        symbol_table_entry.st_shndx = read!ushort();

        return symbol_table_entry;
    }

    private SectionHeader* collect_section_headers(ELFHeader elf_header) {
        SectionHeader[] section_headers = new SectionHeader[elf_header.e_shoff];

        for (int section = 0; section < elf_header.e_shnum; section++) {
            this.file_pointer = elf_header.e_shoff + section * elf_header.e_shentsize;
            section_headers[section] = parse_section_header();
            // writefln("Found section: %x %x", section_headers[section].sh_type, section_headers[section].sh_offset);
        }

        return cast(SectionHeader*) section_headers;
    }

    private SectionHeader get_section_header_with_name__assert(ELFHeader elf_header, SectionHeader* section_headers, SectionHeader str_header, string name, string error_message) {
        auto result = get_section_header_with_name(elf_header, section_headers, str_header, name);
        if (result.isNull) error(error_message);
        return result.get;
    }

    private Nullable!SectionHeader get_section_header_with_name(ELFHeader elf_header, SectionHeader* section_headers, SectionHeader str_header, string name) {
        for (int i = 0; i < elf_header.e_shnum; i++) {
            if (get_section_name(elf_header, section_headers[i], str_header) == name) return Nullable!SectionHeader(section_headers[i]);
        }

        return Nullable!SectionHeader();
    }

    private string get_section_name(ELFHeader elf_header, SectionHeader section_header, SectionHeader str_header) {
        this.file_pointer =  str_header.sh_offset;
        this.file_pointer += section_header.sh_name;
        return to!string(cast(char*) (this.file_data + this.file_pointer));
    }

    private SymbolTableEntry* collect_symbol_table_entries(ELFHeader elf_header, SectionHeader section_header) {
        uint num_entries = section_header.sh_size / section_header.sh_entsize;
        SymbolTableEntry[] symbol_table_entries = new SymbolTableEntry[num_entries];

        for (int entry = 0; entry < num_entries; entry++) {
            this.file_pointer = section_header.sh_offset + entry * section_header.sh_entsize;
            symbol_table_entries[entry] = parse_symbol_table_entry();
        }

        return cast(SymbolTableEntry*) symbol_table_entries;
    }

    private void advance_pointer(ulong n) {
        this.file_pointer += n;
    }

    private T read(T)() {
        T read_value = *(cast(T*) (this.file_data + this.file_pointer));
        this.advance_pointer(T.sizeof);
        return read_value;
    }
}