//#include <ap_int.h>
#include "MemHLS.h"
#include "MemHLS_hash.h"

extern "C" {
    uint16_t int64_hash(uint64_t Data) {
        return hash(ap_uint<MEM_AXI_BUS_WIDTH>(Data));
    }

    uint16_t str_hash(char *str, size_t len) {
        size_t new_len = len + len % 8 == 0 ? 0 : (8 - len % 8);
        char new_str[new_len];
        bzero(new_str, new_len);
        memcpy(new_str, str, len);

        uint16_t h = 0;
        for (int i=0; i < new_len; i+= 8) {
            char backwards[8];
            for (int j=0; j < 8; j++) {
                backwards[j] = new_str[i + 7 - j];
            }
            h ^= int64_hash(*(uint64_t*)backwards);
        }
        return h;
    }

}
