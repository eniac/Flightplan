#include "fecBoosterApi.h"
#include "stdio.h"

int main(int argc, char **argv) {
    char buff[2048];
    while (true) {
        char *rtn = fgets(buff, sizeof(buff), stdin);
        if (rtn != NULL) {
            rtn[strlen(rtn)-1] = '\0';
            if (wharf_str_call(buff)) {
                printf("ERROR\n");
            }
        }
    }
    return 0;
}

