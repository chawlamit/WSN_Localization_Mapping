#include "RSSI.h"

module beaconC{
	uses {
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as InterruptTimer;

		interface SplitControl as RadioControl;
		interface AMSend;
		interface AMPacket;
		interface Packet;
	}
} implementation {
		message_t msg;
		BeaconMsg *payload;
		
		am_addr_t myId;  // Id of the beacon as set while installing
		bool radioBusy; 

		/* helper functions */
	void failBlink() { // If a packet Reception over Radio fails, Led2 is toggled
		call Leds.led2Toggle();
	}

	void successBlink() { 
		call Leds.led1Toggle();
	}

		/* event handlers*/
  	event void Boot.booted(){
    	myId = call AMPacket.address();
    	call RadioControl.start();
  	}
	
	event void RadioControl.startDone(error_t result){
		debug("Radio started");
		radioBusy = FALSE;
    	call InterruptTimer.startPeriodic(BEACON_SEND_INTERVAL_MS * (uint16_t)myId);  //Test typecasting might not work;
  	}

	event void RadioControl.stopDone(error_t result){}


  	event void InterruptTimer.fired() {
  		call Packet.setPayloadLength(&msg,sizeof(BeaconMsg));
  		payload = call Packet.getPayload(&msg,sizeof(BeaconMsg));
  		payload->loc.x = 1;		// Id, harcoded for now, TODO - set from makefile or bash some script
  		payload->loc.y = 1;
  		call AMSend.send(AM_BROADCAST_ADDR, &msg, sizeof(BeaconMsg));
  		radioBusy = TRUE;
  		successBlink();
  	}
	
	event void AMSend.sendDone(message_t *m, error_t error){
		if (error == SUCCESS) {
			radioBusy = FALSE;
			successBlink();
		}
		else {
			failBlink();
		}
	}
	
}
