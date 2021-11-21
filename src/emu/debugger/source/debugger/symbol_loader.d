module debugger.symbol_loader;

import util;

import std.file;
import std.stdio;

struct Symbol {
    string name;
    string obj_file;

    uint   size;
    uint   start_address;
    uint   end_address;
}

// https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
struct ELFFileHeader(uint format_size) {
    static enum MAGIC_NUMBER = 0x7F454c46;

    static enum IdentClass {
        INVALID,
        FORMAT_32 = 1,
        FORMAT_64 = 2
    }

    static enum Machine {
        ARM = 0x28
    }

    align(1):

    ubyte[4]              e_ident_mag;
    ubyte                 e_ident_class;
    ubyte                 e_ident_data;
    ubyte                 e_ident_version;
    ubyte                 e_ident_abi;
    ubyte                 e_ident_abi_version;
    ubyte[7]              e_ident_pad;
    
    ubyte[2]               e_type;
    ubyte[2]               e_machine;
    ubyte[4]               e_version;
    ubyte[4 * format_size] e_entry;
    ubyte[4 * format_size] e_phoff;
    ubyte[4 * format_size] e_shoff;
    ubyte[4]               e_flags;

    ubyte[2]               e_ehsize;
    ubyte[2]               e_phentsize;
    ubyte[2]               e_phnum;
    ubyte[2]               e_shentsize;
    ubyte[2]               e_shnum;
    ubyte[2]               e_shstrndx;
}

static struct ELFProgramHeader(format_size) {
    enum Type {
        PT_NULL    = 0x0000_0000,
        PT_LOAD    = 0x0000_0001,
        PT_DYNAMIC = 0x0000_0002,
        PT_INTERP  = 0x0000_0003,
        PT_NOTE    = 0x0000_0004,
        PT_SHLIB   = 0x0000_0005,
        PT_PHDR    = 0x0000_0006,
        PT_TLS     = 0x0000_0007,
        PT_LOOS    = 0x6000_0000,
        PT_HIOS    = 0x6FFF_FFFF,
        PT_LOPROC  = 0x7000_0000,
        PT_HIPROC  = 0x7FFF_FFFF,
    }

    ubyte[4]               p_type;

static if (is(format_size == ELFByteFormat.FORMAT_64)) {
    ubyte[4]               p_flags;
}

    ubyte[4 * format_size] p_offset;
    ubyte[4 * format_size] p_vaddr;
    ubyte[4 * format_size] p_paddr;
    ubyte[4 * format_size] p_filesz;
    ubyte[4 * format_size] p_memsz;

static if (is(format_size == ELFByteFormat.FORMAT_32)) {
    ubyte[4]               p_flags;
}

    ubyte[4 * format_size] p_align;
}

struct ELFSectionHeader(format_size = ELFByteFormat) {
    enum Type {
        SHT_NULL          = 0x0000_0000,
        SHT_PROGBITS      = 0x0000_0001,
        SHT_SYMTAB        = 0x0000_0002,
        SHT_STRTAB        = 0x0000_0003,
        SHT_RELA          = 0x0000_0004,
        SHT_HASH          = 0x0000_0005,
        SHT_DYNAMIC       = 0x0000_0006,
        SHT_NOTE          = 0x0000_0007,
        SHT_NOBITS        = 0x0000_0008,
        SHT_REL           = 0x0000_0009,
        SHT_SHLIB         = 0x0000_000A,
        SHT_DYNSYM        = 0x0000_000B,
        SHT_INIT_ARRAY    = 0x0000_000E,
        SHT_FINI_ARRAY    = 0x0000_000F,
        SHT_PREINIT_ARRAY = 0x0000_0010,
        SHT_GROUP         = 0x0000_0011,
        SHT_SYMTAB_SHNDX  = 0x0000_0012,
        SHT_NUM           = 0x0000_0013,
        SHT_LOOS          = 0x6000_0000
    }

    ubyte[4]               sh_name;
    ubyte[4]               sh_type;
    ubyte[4 * format_size] sh_flags;
    ubyte[4 * format_size] sh_addr;
    ubyte[4 * format_size] sh_offest;
    ubyte[4 * format_size] sh_size;
    ubyte[4]               sh_link;
    ubyte[4]               sh_info;
    ubyte[4 * format_size] sh_addralign;
    ubyte[4 * format_size] sh_entsize;
}

void parse_ELF(uint format_size)(ubyte* file_data) {
    auto file_header = cast(ELFFileHeader!format_size*) file_data;
    // writefln("%x %x", file_header.e_machine[0], file_header.e_machine[1]);
}

Symbol[] load_symbols_from_file(string file_name) {
    if (!file_name.exists) error(format("Symbol file %s does not exist!", file_name));

    ubyte* file_data = cast(ubyte*) load_file_as_bytes(file_name);

    auto ident_class = file_data[ELFFileHeader!0.e_ident_class.offsetof];

    ELFFileHeader!0 file_header;
    switch (ident_class) {
        case ELFFileHeader!0.IdentClass.FORMAT_32:
            parse_ELF!32(file_data); break;

        case ELFFileHeader!0.IdentClass.FORMAT_64:
            parse_ELF!64(file_data); break;

        case ELFFileHeader!0.IdentClass.INVALID:
        default:
            error(format("Invalid ident class for symbol file %s", file_name));
    }
    
    return [];
}