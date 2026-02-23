/*
 * Copyright (c) 2026 Project CHIP Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <ctype.h>
#include <errno.h>
#include <endian.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

static void log_error(char const *what) {
    fprintf(stderr, "%s failed: %s\n", what, strerror(errno));
}

// Parse a uint32_t in decimal, octal, or hex
static int parse_uint32(char const *str, uint32_t *out) {
    if (!isdigit(*str)) {
        return 1;
    }
    errno = 0;
    char *endptr;
    unsigned long value = strtoul(str, &endptr, 0);
    if (errno != 0 || *endptr != '\0' || value > UINT32_MAX) {
        return 1;
    }
    *out = value;
    return 0;
}

// Perform a "1200 baud touch" to reset the given device
static int reset(char const *device) {
    int fd = open(device, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        log_error("open");
        return 2;
    }

    struct termios tio;
    if (tcgetattr(fd, &tio) < 0) {
        log_error("tcgetattr");
        goto failed;
    }

    cfsetispeed(&tio, B1200);
    cfsetospeed(&tio, B1200);

    if (tcsetattr(fd, TCSAFLUSH, &tio) < 0) {
        log_error("tcsetattr");
        goto failed;
    }

    usleep(10000); // allow a moment for the device to notice the change
    close(fd);
    return 0;

failed:
    close(fd);
    return 2;
}

struct uf2_block {
    uint32_t magic_start0;
    uint32_t magic_start1;
    uint32_t flags;
    uint32_t target_addr;
    uint32_t payload_size;
    uint32_t block_no;
    uint32_t num_blocks;
    uint32_t file_size_or_family_id;
    uint8_t data[476];
    uint32_t magic_end;
} __attribute__((packed));

// Convert a binary file to UF2 and write to an output file or stdout
static int convert(uint32_t family, uint32_t base, char const *bin, char const *uf2) {
    int status = 2;
    FILE *fbin = NULL, *fuf2 = NULL;

    if (!(fbin = fopen(bin, "rb"))) {
        log_error("fopen (input)");
        goto failed;
    }
    if (fseek(fbin, 0, SEEK_END) < 0) {
        log_error("fseek");
        goto failed;
    }
    long file_size = ftell(fbin);
    if (file_size < 0) {
        log_error("ftell");
        goto failed;
    }
    rewind(fbin);

    FILE *fout = stdout;
    if (uf2 && !(fout = fuf2 = fopen(uf2, "wb"))) {
        log_error("fopen (output)");
        goto failed;
    }

    const uint32_t chunk_size = 256;
    uint32_t num_blocks = (file_size + chunk_size - 1) / chunk_size;

    struct uf2_block block = { 0 };
    block.magic_start0 = htole32(0x0A324655);
    block.magic_start1 = htole32(0x9E5D5157);
    block.magic_end = htole32(0x0AB16F30);
    block.flags = htole32(0x00002000); // Family ID Present
    block.file_size_or_family_id = htole32(family);
    block.num_blocks = htole32(num_blocks);
    block.payload_size = htole32(chunk_size); // same for all chunks (may implicitly pad the last chunk)

    long bytes_remaining = file_size;
    for (uint32_t block_no = 0; block_no < num_blocks; block_no++) {
        block.block_no = htole32(block_no);
        block.target_addr = htole32(base + (block_no * chunk_size));

        size_t read_size = bytes_remaining < chunk_size ? bytes_remaining : chunk_size;
        size_t bytes_read = fread(block.data, 1, read_size, fbin);
        if (bytes_read != read_size) {
            log_error("fread");
            goto failed;
        }

        bytes_remaining -= bytes_read;
        if (bytes_read < chunk_size) {
            memset(block.data + bytes_read, 0, chunk_size - bytes_read);
        }

        if (fwrite(&block, 1, sizeof(block), fout) != sizeof(block)) {
            log_error("fwrite");
            goto failed;
        }
    }

    if (fflush(fout)) {
        log_error("fflush");
        goto failed;
    }

    // Best-effort fdatasync; usually fails when flashing because the
    // bootloader will already disconnect while the kernel is still trying
    // to write meta-data. Will also fail if the output is not a file.
    (void)fdatasync(fileno(fout));
    status = 0; // success

failed:
    if (fbin) {
        fclose(fbin);
    }
    if (fuf2) {
        fclose(fuf2);
    }
    return status;
}

int main(int argc, char *argv[]) {
    if (argc == 3 && !strcmp(argv[1], "reset")) {
        return reset(argv[2]);
    }
    uint32_t family, base;
    if ((argc == 5 || argc == 6) && !strcmp(argv[1], "convert") &&
        !parse_uint32(argv[2], &family) &&
        !parse_uint32(argv[3], &base)) {
        return convert(family, base, argv[4], (argc == 6) ? argv[5] : NULL);
    }
    fprintf(stderr, "Usage: %s { reset TTY | convert 0xFAMILY 0xBASE BINFILE [UF2FILE] }\n", argv[0]);
    return 1;
}
