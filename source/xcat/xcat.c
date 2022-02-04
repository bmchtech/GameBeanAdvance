/*
xcat (v0.2) - a simple cat clone with xor key

based on Plan9 cat:
https://gist.githubusercontent.com/pete/665971/raw/b0bdaf46ac74703ebbece96eeacdece2e5217fa2/plan9-cat.c
*/

#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/** xor a buffer of length n in-place by a key of length k */
void xor_buf(uint8_t *buf, uint8_t *key, size_t n, size_t key_len) {
    int ki = 0; // key index
    for (int i = 0; i < n; i++) {
        uint8_t k = key[ki];     // active byte of key
        buf[i] = buf[i] ^ k;     // xor
        ki = (ki + 1) % key_len; // cycle through key
    }
}

/** the main xcat program: read from file in chunks, xor, then write to stdout */
void xcat(FILE *f, uint8_t *key, size_t key_len, char *s) {
    uint8_t buf[65536]; // buffer size for read/write chunks
    size_t n;

    while ((n = fread(buf, sizeof(uint8_t), sizeof(buf), f)) > 0) {
        xor_buf(buf, key, n, key_len);
        if (fwrite(buf, sizeof(uint8_t), n, stdout) != n) {
            fprintf(stderr, "write error copying %s: %d", s, errno);
            exit(1);
        }
    }
    if (n < 0) {
        fprintf(stderr, "error reading %s: %d", s, errno);
        exit(1);
    }
}

// https://stackoverflow.com/questions/3408706/hexadecimal-string-to-byte-array-in-c/35452093#35452093
typedef struct HexData {
    uint8_t *data;
    size_t len;
} HexData;
HexData hex2bytes(char *str) {

    if (str == NULL)
        return (HexData){.data = NULL, .len = 0};

    size_t slength = strlen(str);
    if ((slength % 2) != 0) // must be even
        return (HexData){.data = NULL, .len = 0};

    size_t dlength = slength / 2;

    uint8_t *data = malloc(dlength);
    memset(data, 0, dlength);

    size_t index = 0;
    while (index < slength) {
        uint8_t c = str[index];
        int value = 0;
        if (c >= '0' && c <= '9')
            value = (c - '0');
        else if (c >= 'A' && c <= 'F')
            value = (10 + (c - 'A'));
        else if (c >= 'a' && c <= 'f')
            value = (10 + (c - 'a'));
        else {
            free(data);
            return (HexData){.data = NULL, .len = 0};
        }

        data[(index / 2)] += value << (((index + 1) % 2) * 4);

        index++;
    }

    return (HexData){.data = data, .len = dlength};
}

int main(int argc, char *argv[]) {
    int i;
    FILE *f;
    uint8_t *key;
    size_t key_len;

    argv[0] = "xcat";
    if (argc == 1) {
        fprintf(stderr, "Usage: xcat <key> [file]\n  a simple cat clone with xor key");
        exit(2);
    }

    char *keyarg = argv[1];

    // check whether key is '!xxxx' format (hex)
    // otherwise interpret key as '1234' format (uint64)
    if (keyarg[0] == '!') {
        char *hexkey = keyarg + 1;
        if (strlen(hexkey) == 0) {
            fprintf(stderr, "invalid key: empty");
            exit(2);
        }
        HexData hex_data = hex2bytes(hexkey);
        if (hex_data.data == NULL) {
            fprintf(stderr, "invalid key: %s", hexkey);
            exit(2);
        }
        key = hex_data.data;
        key_len = hex_data.len;
    } else {
        const int num_size = 8; // uint64 size
        uint64_t key_num = atol(keyarg);
        key = malloc(num_size);
        key_len = num_size;
        // copy to key buffer
        for (int i = 0; i < num_size; i++) {
            key[num_size - (i + 1)] = (key_num >> (num_size * i)) & 0xff;
        }
    }

    if (argc == 2)
        xcat(stdin, key, key_len, "<stdin>");
    else
        for (i = 2; i < argc; i++) {
            f = fopen(argv[i], "r");
            if (f == NULL) {
                fprintf(stderr, "can't open %s: %d", argv[i], errno);
                exit(1);
            } else {
                xcat(f, key, key_len, argv[i]);
                fclose(f);
            }
        }
    exit(0);
}
