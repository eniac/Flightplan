#include "fecBoosterApi.h"
#include "stdio.h"
#include <stdlib.h>

int main(int argc, char **argv) {
    if (argc == 2) {
        wharf_set_enabled(true);
        if (wharf_load_from_file(argv[1]) != 0) {
            printf("EXITING\n");
            exit(-1);
        }
    } else if (argc != 1) {
        printf("Usage: %s [rules.csv]\n", argv[0]);
        printf("Bad # of arguments (%d). Exiting\n", argc-1);
        exit(-1);
    }
    char buff[2048];
    while (true) {
        char *rtn = fgets(buff, sizeof(buff), stdin);
        if (rtn != NULL && strlen(buff) != 1) {
            rtn[strlen(rtn)-1] = '\0';
            if (wharf_str_call(buff)) {
                printf("ERROR\n");
            }
        }
    }
    return 0;
}

