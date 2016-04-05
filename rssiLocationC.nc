/*  This component provides an interface for an RSSI (recieved signal strength indicator) based 
 *  TriLateration algorithm to calculate the location of an unknown node with the help of 3 beacon nodes. 
 */

#include "RSSI.h" // custom definitions for timing intervals and othe constants. 
#include "printf.h" // printf is used for debugging

#ifndef debugging
#define debugging
#endif

module rssiLocationC {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;  // PROVIDED BY ActiveMessageC
	    
	    // interfaces used for sending and manipulating packets
	    
	    // interface AMSend as RadioSend[am_id_t id];
	    interface Receive as RadioReceive[am_id_t id];
    	// interface Packet as RadioPacket;
    	// interface AMPacket as RadioAMPacket;
    	
    	// used to get the rsi value of the packet
    	interface CC2420Packet;


	}

}

implementation {
	// Radio Queue implementation if required // to be ananlyzed later

	message_t* receiveMsg;
	RssiMsg* msgPayload;

	// task void radioSendTask(); // Send Packet on Radio Interface - broadcast to all beacons
	
	/* Helper functions */
	void failBlink() { // If a packet Reception over Radio fails, Led2 is toggled
		call Leds.led2Toggle();
	}

	void successBlink() { // If a packet Reception over Radio fails, Led2 is toggled
		call Leds.led1Toggle();
	}

	uint16_t getRssi(message_t *msg){
    	return (uint16_t) call CC2420Packet.getRssi(msg);
  	}

  	/* event handlers */
	event void Boot.booted() {
		call RadioControl.start();
	}   

	event void RadioControl.startDone(error_t error) {
		if (error == SUCCESS) {
			successBlink();
			#ifdef debugging
			printf("Radio startDone\n");
			printfflush();
			#endif
		}
	}
  
	event void RadioControl.stopDone(error_t error) {}

	event message_t *RadioReceive.receive[am_id_t id] ( message_t *msg, void *payload, uint8_t len ) {
	// event message_t *RadioReceive.receive( message_t *msg, void *payload, uint8_t len ) {
		if (len == sizeof(RssiMsg)) {
			msgPayload = (RssiMsg*)payload;
			msgPayload->rssi = getRssi(msg);
			#ifdef debugging
			printf("Rssi = %d\n",msgPayload->rssi);
			printfflush();
			#endif
		}
		return msg;
  }

}

