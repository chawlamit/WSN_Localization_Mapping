/*  This component provides an interface for an RSSI (recieved signal strength indicator) based 
 *  TriLateration algorithm to calculate the location of an unknown node with the help of 3 beacon nodes. 
 */

#include "RSSI.h" // custom definitions for timing intervals and othe constants. 
#include "debug.h" // custon debug macro - a wrapper around the printf 
#include "math.h"

// #define INT_MAX 200
#define INT_MIN -300    

#define rssi_1m -5 + RSSI_DB_CONVERSION // rssi value at 1m distance from the beacon. of the eqn. 
#define n 2.2 // pathloss exponent for free space

//Calibration Entities 
#define CAL_10 1.2
#define CAL_20 2.4
#define CAL_30 3.6
#define CAL_40 4.8
#define CAL_50 6.0


module rssiLocationC {
	uses {
		interface Boot;
		interface Leds;
		interface SplitControl as RadioControl;  // PROVIDED BY ActiveMessageC
		
		interface Timer<TMilli> as DelayTimer1; //for rssi msg slots
		interface Timer<TMilli> as DelayTimer2; //for rssi msg slots
		interface Timer<TMilli> as BeaconTimer;
		interface Timer<TMilli> as TrackerTimer;
		interface Timer<TMilli> as SleepTimer;

		// interfaces used for sending and manipulating packets
		
		interface AMSend; //as AMSend;
		// interface Receive;// as Receive;
		interface Receive as RadioReceive[am_id_t id_r];
		interface Packet;// as Packet;
		interface AMPacket;// as AMPacket;
		
		// used to get the rsi value of the packet
		interface CC2420Packet;


	}

}

implementation {
	message_t Tmsg;
	TrackerMsg* payloadPtr;
	nx_uint8_t roomId_global;
	nx_uint8_t quad_global;
	BeaconMsg* msgPayload;
	bool radioBusy;
	uint8_t counter = 0;    

	RssiStruct beacInfo[MAX_TOS_BEACON+1];

	uint8_t index = 0;  //used to store the index of recieved beacon signal


	am_addr_t prevBeaconId = 1; 

	Coord currLoc;

	/* Helper functions */
	void failToggle() { // If a packet Reception over Radio fails, Led2 is toggled
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

	void locate(int,int,int);


	void calcDistance(int i) {
		if (-1*beacInfo[i].rssiAvg<=10)
			beacInfo[i].distance = CAL_10;
		else if (-1*beacInfo[i].rssiAvg<=20)
			beacInfo[i].distance = CAL_20;
		else if (-1*beacInfo[i].rssiAvg<=30)
			beacInfo[i].distance = CAL_30;
		else if (-1*beacInfo[i].rssiAvg<=40)
			beacInfo[i].distance = CAL_40;
		else 
			beacInfo[i].distance = CAL_50;
		//float log_x = (-1 * beacInfo[i].rssiAvg + rssi_1m)/(10.0 * n);
		//beacInfo[i].distance = powf(10,log_x);
		debug("distance from beacon:%u is ",i);
		printfFloat(beacInfo[i].distance);
		debug("\n");
	
	}
		
	/* tasks for processng */
	// task void radioSendTask(); // Send Packet on Radio Interface - broadcast to all beacon_addr

	task void distFromRssi() {

		int maxIndex = -1, medIndex = -1, minIndex=-1; 
		int max = INT_MIN, med=INT_MAX, min=INT_MAX;
		
		int i,j,countDiv;
		for (i=1;i<MAX_TOS_BEACON+1;i++) {
			countDiv = 0;
			for (j=0;j<RSSI_REPEAT;j++) {

				if (beacInfo[i].rssi[j] != 0) {
					beacInfo[i].rssiAvg += beacInfo[i].rssi[j];
					countDiv++;
				}
			}
			beacInfo[i].rssiAvg = beacInfo[i].rssiAvg/countDiv;
			if (beacInfo[i].rssiAvg >= max && beacInfo[i].rssiAvg!=0) {
				min = med;
				minIndex = medIndex;
				
				med = max;
				medIndex = maxIndex;

				max = beacInfo[i].rssiAvg;
				maxIndex = i;

			}
			else {
				if (beacInfo[i].rssiAvg >= med && beacInfo[i].rssiAvg!=0 ) {
					min = med;
					minIndex = medIndex;

					med = beacInfo[i].rssiAvg;
					medIndex = i;
				}
				else {
					if (beacInfo[i].rssiAvg >= min && beacInfo[i].rssiAvg!=0 ) {
						minIndex = i;
						min = beacInfo[i].rssiAvg;

					}
				}   
			}
		}
		roomId_global = beacInfo[maxIndex].roomId;
		quad_global = beacInfo[maxIndex].quad;
		debug("quad = %d",quad_global);

		// calcDistance(maxIndex);
		// calcDistance(medIndex);
		// calcDistance(minIndex);

		// locate(maxIndex,medIndex,minIndex);
	}

	void locate(int maxi, int medi, int mini){  
		float va = ( (beacInfo[medi].distance*beacInfo[medi].distance - beacInfo[mini].distance*beacInfo[mini].distance) 
					- (beacInfo[medi].loc.x*beacInfo[medi].loc.x - beacInfo[mini].loc.x*beacInfo[mini].loc.x) 
					- (beacInfo[medi].loc.y*beacInfo[medi].loc.y - beacInfo[mini].loc.y*beacInfo[mini].loc.y) ) / 2.0;
		float vb = ( (beacInfo[medi].distance*beacInfo[medi].distance - beacInfo[maxi].distance*beacInfo[maxi].distance) 
					- (beacInfo[medi].loc.x*beacInfo[medi].loc.x - beacInfo[maxi].loc.x*beacInfo[maxi].loc.x) 
					- (beacInfo[medi].loc.y*beacInfo[medi].loc.y - beacInfo[maxi].loc.y*beacInfo[maxi].loc.y) ) / 2.0;
		currLoc.y = (vb*(beacInfo[mini].loc.x - beacInfo[medi].loc.x) 
					- va*(beacInfo[maxi].loc.x - beacInfo[medi].loc.x))/(((beacInfo[maxi].loc.y - beacInfo[medi].loc.y)*(beacInfo[mini].loc.x - beacInfo[medi].loc.x)) 
															- ((beacInfo[mini].loc.y - beacInfo[medi].loc.y)*(beacInfo[maxi].loc.x - beacInfo[medi].loc.x)));
		
		currLoc.x = (va - currLoc.y*(beacInfo[mini].loc.y - beacInfo[medi].loc.y))/(beacInfo[mini].loc.x - beacInfo[medi].loc.x);
		debug("I am located @");
		printfFloat(currLoc.x);
		printfFloat(currLoc.y);

	}

	/* event handlers */
	event void Boot.booted() {
		call RadioControl.start();
		index = 0; // initialize the index to zero
	}   

	event void RadioControl.startDone(error_t error) {
		if (error == SUCCESS) {
			call Leds.led1On();
			debug("Radio startDone\n");
			radioBusy = FALSE;
		}
	}
  
	event void RadioControl.stopDone(error_t error) {}

	event message_t* RadioReceive.receive[am_id_t id_r] ( message_t *msg, void *payload, uint8_t len ) {
		BSMsg* buf;
		am_addr_t id;

		if (call AMPacket.source(msg) == BASE_STATION_ID) {
			buf = (BSMsg*)payload;
			if (buf->msg_type == START_MSG) {
				call DelayTimer1.startOneShot(DELAY_INTERVAL_MS);
			}
			else if (buf->msg_type == SLEEP_MSG) {
				//TODO - Sleep Node
				call SleepTimer.startOneShot(buf->sleepTime);
			}
		}

		if (len == sizeof(BeaconMsg)) {
			msgPayload = (BeaconMsg*)payload;

			id = call AMPacket.source(msg);

			beacInfo[id].rssi[index] = getRssi(msg) + RSSI_DB_CONVERSION;
			debug("Rssi : %d from beacon %u\n:",beacInfo[id].rssi[index],id);
			beacInfo[id].loc.x = msgPayload->loc.x;
			beacInfo[id].loc.x = msgPayload->loc.y;
			beacInfo[id].roomId = msgPayload->roomId;
			beacInfo[id].quad = msgPayload->quad;

			if (id == prevBeaconId) {
				index++; //= (index + 1) % RSSI_REPEAT;
			}
			else {
				index = 0;
			}

			prevBeaconId = id;

		}
		return msg;
	}


	event void DelayTimer1.fired() {
		memset(&beacInfo, 0, sizeof(RssiStruct) * MAX_TOS_BEACON);
		call BeaconTimer.startOneShot((BEACON_SEND_INTERVAL_MS) * ( (MAX_TOS_BEACON * RSSI_REPEAT) +1 ) );
		debug(" DelayTimer1 fired\n");
	}
	
	event void BeaconTimer.fired() { 
		call DelayTimer2.startOneShot(DELAY_INTERVAL_MS2);
		post distFromRssi();
		debug("BeaconTimer fired\n");
	}

	event void DelayTimer2.fired() {
		call TrackerTimer.startPeriodic(BEACON_SEND_INTERVAL_MS);
		debug(" DelayTimer2 fired\n");
	}

	event void TrackerTimer.fired(){
		if (counter == (TOS_NODE_ID - 10)) { 
			// send Coord
			call Packet.setPayloadLength(&Tmsg,sizeof(TrackerMsg));
			payloadPtr = call Packet.getPayload(&Tmsg,sizeof(TrackerMsg));
			payloadPtr->loc.x = currLoc.x;
			payloadPtr->loc.y = currLoc.y;
			payloadPtr->nodeId = TOS_NODE_ID;
			payloadPtr->roomId = roomId_global;
			payloadPtr->quad = quad_global;

			call AMSend.send(BASE_STATION_ID, &Tmsg, sizeof(TrackerMsg));
			radioBusy = TRUE;
			successBlink();
			debug("My msg Sent %d\n",counter);
		}
		counter++;

		if (counter==MAX_TOS_TRACKER){
			call TrackerTimer.stop();
			counter = 0;
		}
		debug(" TrackerTimer fired %d\n",counter);

	}   

	event void SleepTimer.fired() {}

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

