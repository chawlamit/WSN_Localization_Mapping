#ifndef NEW_PRINTF_SEMANTICS
#define NEW_PRINTF_SEMANTICS
#endif
#include "printf.h"

#include "message.h"


configuration rssiLocationAppC {
} implementation {
	components MainC, LedsC; 

	components ActiveMessageC as Radio;
	
	components CC2420ActiveMessageC;

	components rssiLocationC as App;

	components PrintfC;
  	components SerialStartC;

	App.Boot -> MainC.Boot;
	App.Leds -> LedsC.Leds;

	App.RadioControl -> Radio;

	// App.RadioSend -> Radio;
	App.RadioReceive -> Radio.Receive;
	// App.RadioPacket -> Radio;
 	// App.RadioAMPacket -> Radio;

 	App.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;

}