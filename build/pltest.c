#include <libplacebo/vulkan.h>
#include <libplacebo/compositor.h>
#include <stdint.h>
static volatile intptr_t ref;
int main(void){ ref = (intptr_t) pl_vulkan_create; ref = (intptr_t) pl_queue_set_status; return 0; }
