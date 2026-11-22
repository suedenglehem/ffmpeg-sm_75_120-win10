#include <aribb24/aribb24.h>
#include <stdint.h>
static volatile intptr_t ref;
int main(void){ ref = (intptr_t) arib_instance_new; return 0; }
