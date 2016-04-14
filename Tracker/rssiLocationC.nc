/*  This component provides an interface for an RSSI (recieved signal strength indicator) based 
 *  TriLateration algorithm to calculate the location of an unknown node with the help of 3 beacon nodes. 
 */

#include "RSSI.h" // custom definitions for timing intervals and othe constants. 
#include "debug.h" // custon debug macro - a wrapper around the printf 
#include "math.h"


module rssiLocationC {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;  // PROVIDED BY ActiveMessageC
	    
	    // interfaces used for sending and manipulating packets
	    
	    // interface AMSend as RadioSend[am_id_t id];
	    interface Receive as RadioReceive[am_id_t id];
    	// interface Packet as RadioPacket;
    	interface AMPacket as RadioAMPacket;
    	
    	// used to get the rsi value of the packet
    	interface CC2420Packet;


	}

}

implementation {
	BeaconMsg* msgPayload;

	const int16_t rssi_1m = -50;	// rssi value at 1m distance from the beacon. of the eqn. 
	const double n = 2.2; // pathloss exponent for free space

	am_addr_t beacon_addr[3];	// address of beacon_addr (i.e. node ids)
	double dist_beacon[3];	//array to store the distances from beacon
	uint8_t index;	//used to store the index of recieved beacon signal

	Coord beacon_loc[3];
	Coord currLoc;

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
	
	void printfFloat(float toBePrinted) {
     uint32_t fi, f0, f1, f2;
     char c;
     float f = toBePrinted;

     if (f<0){
       c = '-'; f = -f;
     } else {
       c = ' ';
     }

     // integer portion.
     fi = (uint32_t) f;

     // decimal portion...get index for up to 3 decimal places.
     f = f - ((float) fi);
     f0 = f*10;   f0 %= 10;
     f1 = f*100;  f1 %= 10;
     f2 = f*1000; f2 %= 10;
     debug("%c%ld.%d%d%d", c, fi, (uint8_t) f0, (uint8_t) f1, (uint8_t) f2);
   	}
	
	/* tasks for processng */
	// task void radioSendTask(); // Send Packet on Radio Interface - broadcast to all beacon_addr

  	void distFromRssi() {
  		double log_x = (-1*msgPayload->sigLevel.rssi + rssi_1m)/(10.0 * n);
  		dist_beacon[index] = powf(10,log_x);
  		debug("distance from beacon:%u is ",beacon_addr[index]);
  		printfFloat(dist_beacon[index]);
  		debug("\n");
  	}

  	// task void locate(){  
  	// 	double va = ( (dist_beacon[1]*dist_beacon[1] - dist_beacon[2]*dist_beacon[2]) 
  	// 				- (beacon_loc[1].x*beacon_loc[1].x - beacon_loc[2].x*beacon_loc[2].x) 
  	// 				- (beacon_loc[1].y*beacon_loc[1].y - beacon_loc[2].y*beacon_loc[2].y) ) / 2.0;
  	// 	double vb = ( (dist_beacon[1]*dist_beacon[1] - dist_beacon[0]*dist_beacon[0]) 
  	// 				- (beacon_loc[1].x*beacon_loc[1].x - beacon_loc[0].x*beacon_loc[0].x) 
  	// 				- (beacon_loc[1].y*beacon_loc[1].y - beacon_loc[0].y*beacon_loc[0].y) ) / 2.0;
  	// 	currLoc.y = (vb(beacon_loc[2].x - beacon_loc[1].x) 
  	// 				- va(beacon_loc[0].x - beacon_loc[1].x))/((beacon_loc[0].y - beacon_loc[1].y)*(beacon_loc[2].x - beacon_loc[1].x) 
  	// 														- (beacon_loc[2].y - beacon_loc[1].y)*(beacon_loc[0].x - beacon_loc[1].x));
  		
  	// 	currLoc.x = (va - currLoc.y(beacon_loc[2].y - beacon_loc[1].y))/(beacon_loc[2].x - beacon_loc[1].x);
  	// }

	/* event handlers */
	event void Boot.booted() {
		call RadioControl.start();
		index = 0; // initialize the index to zero
	}   

	event void RadioControl.startDone(error_t error) {
		if (error == SUCCESS) {
			successBlink();
			debug("Radio startDone\n");
		}
	}
  
	event void RadioControl.stopDone(error_t error) {}

	event message_t *RadioReceive.receive[am_id_t id] ( message_t *msg, void *payload, uint8_t len ) {

		am_addr_t dest;
		if (len == sizeof(BeaconMsg)) {
			msgPayload = (BeaconMsg*)payload;
			msgPayload->sigLevel.rssi = getRssi(msg) - 45;
			debug("Rssi = %d\n",msgPayload->sigLevel.rssi);

			beacon_addr[index] = call RadioAMPacket.source(msg);
			distFromRssi();
			// if (index==2) {
			// 	post calcPos();
			// }
			index = (index+1)%3;
		}
		return msg;
  }

}

