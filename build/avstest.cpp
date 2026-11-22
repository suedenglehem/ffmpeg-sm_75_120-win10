#include <avisynth/avisynth_c.h>
#include <avisynth/avs/version.h>
#if !(AVS_MAJOR_VER >= 3 && AVS_MINOR_VER >= 7 && AVS_BUGFIX_VER >= 3 || AVS_MAJOR_VER >= 3 && AVS_MINOR_VER > 7 || AVS_MAJOR_VER > 3)
#error version gate failed
#endif
int main(){ return 0; }
