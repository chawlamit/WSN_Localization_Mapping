#ifndef NEW_PRINTF_SEMANTICS
#define NEW_PRINTF_SEMANTICS
#endif
#include "printf.h" // printf is used for debugging

#ifndef debugging
#define debugging
#endif

#ifdef debugging
	#define serialPrint 1
#else
	#define serialPrint 0
#endif

#define debug(fmt, args...) do { if (serialPrint) { printf(fmt, ##args); printfflush();} } while (0)
