#include "RSSI.h"
#include "debug.h"
// #include "message.h"

configuration beaconAppC{
} implementation {
	components MainC, LedsC;
	
	components new TimerMilliC() as DelayTimer;
	components new TimerMilliC() as BeaconTimer;
	components new TimerMilliC() as SleepTimer;
	
	components ActiveMessageC as Radio;
	
	components new AMSenderC(AM_RSSI) as RadioSender;
	
	components beaconC as App;
	
	components PrintfC;
  	components SerialStartC;

	App.Boot -> MainC.Boot;
	App.Leds -> LedsC.Leds;

	App.DelayTimer -> DelayTimer;
	App.BeaconTimer -> BeaconTimer;
	App.SleepTimer -> SleepTimer;

	App.RadioControl -> Radio;
	App.AMPacket -> Radio;
	App.Packet -> Radio;
	App.AMSend -> RadioSender;

	App.RadioReceive -> Radio.Receive;

}