#include "RSSI.h"
#include "debug.h"
// #include "message.h"


configuration rssiLocationAppC {
} implementation {
	components MainC, LedsC; 

	components ActiveMessageC as Radio;
	components new AMSenderC(AM_RSSIMSG) as RadioSender;
	
	components CC2420ActiveMessageC;

	components new TimerMilliC() as DelayTimer1;
	components new TimerMilliC() as DelayTimer2;
	components new TimerMilliC() as BeaconTimer;
	components new TimerMilliC() as SleepTimer;	
	components new TimerMilliC() as TrackerTimer;
	
	components rssiLocationC as App;

	components PrintfC;
  	components SerialStartC;

	App.Boot -> MainC.Boot;
	App.Leds -> LedsC.Leds;

	App.RadioControl -> Radio;

	App.AMSend -> RadioSender;
	App.Receive ->	Radio.Receive[AM_RSSIMSG];
	App.Packet -> Radio;
 	App.AMPacket -> Radio;

 	App.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;

 	App.DelayTimer1 -> DelayTimer1;	
 	App.DelayTimer2 -> DelayTimer2;
 	App.BeaconTimer -> BeaconTimer;	
 	App.SleepTimer -> SleepTimer;	
 	App.TrackerTimer -> TrackerTimer;	

}