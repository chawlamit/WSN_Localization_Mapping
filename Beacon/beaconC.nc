#include "RSSI.h"
#include "AM.h"
#define X 3
#define Y 3

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

	    // interface Receive;
	    interface Receive as RadioReceive[am_id_t id];
	
	    // interface PacketTimeStamp<TMilli,uint32_t>;
	    // interface TimeSyncPacket<TMilli,uint32_t>;
	    // interface TimeSyncAMSend<TMilli,uint32_t> as TimeAMSend;
	    // interface LocalTime<TMilli>;    
	}
} implementation {
		message_t RSSImsg;
		BeaconMsg* payloadPtr;

		uint8_t counter = 0;
		bool radioBusy; 

		/* helper functions */
	void failToggle() { // If a packet Reception over Radio fails, Led2 is toggled
		call Leds.led1Toggle();
	}

	void successBlink() { 
		call Leds.led2Toggle();
	}

		/* event handlers*/
  	event void Boot.booted(){
    	call RadioControl.start();
    	call Leds.led0On(); 
  	}
	
	event void RadioControl.startDone(error_t result){
		debug("Radio started\n");
		radioBusy = FALSE;
    	// call Timer1.startPeriodic(BEACON_SEND_INTERVAL_MS * (uint16_t)myId);  //Test typecasting might not work;
  	}

	event void RadioControl.stopDone(error_t result){}

	event message_t* RadioReceive.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) { 
		BSMsg* buf;
		if (call AMPacket.source(msg) == BASE_STATION_ID) {
			buf = (BSMsg*)payload;
			if (buf->msg_type == START_MSG) {
				call DelayTimer.startOneShot(DELAY_INTERVAL_MS);
				// call Leds.led1On();
				debug("Start Message Recieved\n");

			}
			else if (buf->msg_type == SLEEP_MSG) {
				//TODO - Sleep Node
				call SleepTimer.startOneShot(buf->sleepTime);
				debug("Sleep Message Recieved\n");

			}
		}

		return msg;
	}

	event void DelayTimer.fired() {
		call BeaconTimer.startPeriodic(BEACON_SEND_INTERVAL_MS);
		debug("DelayTimer Fired");
	}
	
	event void BeaconTimer.fired() {
		if (counter < TOS_NODE_ID*RSSI_REPEAT && counter >= (TOS_NODE_ID - 1)*RSSI_REPEAT) { 
			// send Coord
  			call Packet.setPayloadLength(&RSSImsg,sizeof(BeaconMsg));
  			payloadPtr = call Packet.getPayload(&RSSImsg,sizeof(BeaconMsg));
  			payloadPtr->loc.x = X;
  			payloadPtr->loc.y = Y;
	  		call AMSend.send(AM_BROADCAST_ADDR, &RSSImsg, sizeof(BeaconMsg));
	  		radioBusy = TRUE;
	 	 	successBlink();
 			debug("Beacon msg : %d\n",counter);

		}
		counter++;

		if (counter==MAX_TOS_BEACON*RSSI_REPEAT){
			call BeaconTimer.stop();
			// call Leds.led1On();
			counter = 0;
		}
		debug("Beacon Timer Fired: %d\n",counter);
	}

	event void SleepTimer.fired() {
		debug("Sleep Timer fired\n");
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
