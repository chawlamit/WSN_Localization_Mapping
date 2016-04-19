#include "RSSI.h"
#define X 1
#define Y 1

module beaconC{
	uses {
		interface Boot;
		interface Leds;
		interface Timer<TMilli> as DelayTimer; //for rssi msg slots
		interface Timer<TMilli> as BeaconTimer;
		interface Timer<TMilli> as SleepTimer;



		interface SplitControl as RadioControl;
		interface AMSend;
		interface AMPacket;
		interface Packet;

	    interface Receive;
	
	    interface PacketTimeStamp<TMilli,uint32_t>;
	    interface TimeSyncPacket<TMilli,uint32_t>;
	    interface TimeSyncAMSend<TMilli,uint32_t> as TimeAMSend;
	    interface LocalTime<TMilli>;    


	}
} implementation {
		message_t msg;
		BeaconMsg* payloadPtr;

		uint8_t counter = 0;
		bool radioBusy; 

		/* helper functions */
	void failToggle() { // If a packet Reception over Radio fails, Led2 is toggled
		call Leds.led2Toggle();
	}

	void successBlink() { 
		call Leds.led1Toggle();
	}

		/* event handlers*/
  	event void Boot.booted(){
    	call RadioControl.start();
  	}
	
	event void RadioControl.startDone(error_t result){
		debug("Radio started");
		radioBusy = FALSE;
    	// call Timer1.startPeriodic(BEACON_SEND_INTERVAL_MS * (uint16_t)myId);  //Test typecasting might not work;
  	}

	event void RadioControl.stopDone(error_t result){}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) { 
		BSMsg* buf;
		if (call AMPacket.source(msg) == BASE_STATION_ID) {
			buf = (BSMsg*)payload;
			if (buf->msg_type == START_MSG) {
				Timer1.startOneShot(DELAY_INTERVAL_MS);
			}
			else if (buf->msg_type == END_MSG) {
				//TODO - Sleep Node
			}
		}

		return msg;
	}

	event void DelayTimer.fired)() {
		call BeaconTimer.startPeriodic(BEACON_SEND_INTERVAL_MS);
	}
	
	event void BeaconTimer.fired)() {
		if (counter < TOS_NODE_ID*5 && count >= (TOS_NODE_ID - 1)*5) { 
			// send Coord
  			call Packet.setPayloadLength(&msg,sizeof(BeaconMsg));
  			payloadPtr = Packet.getPayload(&msg,sizeof(BeaconMsg));
  			payloadPtr->Coord.x = X;
  			payloadPtr->Coord.y = Y;
	  		call AMSend.send(AM_BROADCAST_ADDR, &msg, sizeof(BeaconMsg));
	  		radioBusy = TRUE;
	 	 	successBlink();
		}
		counter++;

		if (counter==MAX_TOS_BEACON*5){
			BeaconTimer.stop();
			counter = 0;
		}
	}

	event void AMSend.sendDone(message_t *m, error_t error){
		if (error == SUCCESS) {
			radioBusy = FALSE;
			successBlink();
		}
		else {
			failToggle();
		}
	}


	
}
