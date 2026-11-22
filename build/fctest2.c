#include <fontconfig/fontconfig.h>
#include <stdint.h>
static volatile intptr_t ref;
int main(void){ ref = (intptr_t) FcInit; return 0; }
