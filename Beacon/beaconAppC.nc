#include "RSSI.h"
#include "debug.h"
// #include "message.h"

configuration beaconAppC{
} implementation {
	components MainC, LedsC;
	
	components new TimerMilliC() as InterruptTimer;
	
	components ActiveMessageC;
	
	components new AMSenderC(AM_RSSIMSG) as RadioSender;
	
	components beaconC as App;
	
	components PrintfC;
  	components SerialStartC;

	App.Boot -> MainC.Boot;
	App.Leds -> LedsC.Leds;

	App.InterruptTimer -> InterruptTimer;

	App.RadioControl -> ActiveMessageC;
	App.AMPacket -> ActiveMessageC;
	App.Packet -> ActiveMessageC;
	App.AMSend -> RadioSender;

}