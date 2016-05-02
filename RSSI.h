#ifndef RSSI_H
#define RSSI_H

#define BASE_STATION_ID 100

#define MAX_TOS_BEACON 4
#define MAX_TOS_TRACKER 1

#define RSSI_DB_CONVERSION 0

enum {

  START_MSG = 1,
  SLEEP_MSG = 2,

  AM_RSSI = 10,
  AM_TRACKERMSG = 11,

  DELAY_INTERVAL_MS = 100,
  DELAY_INTERVAL_MS2 = 10*1000,
  BEACON_SEND_INTERVAL_MS = 250,
  TRACKER_SEND_INTERVAL_MS = 250,
  RSSI_REPEAT = 5
};

// typedef nx_struct RssiMsg{
//   nx_int16_t rssi;
// } RssiMsg;

typedef nx_struct BSMsg {
	nx_uint8_t msg_type;
	nx_uint32_t sleepTime;
}BSMsg;


typedef nx_struct Coord {  //Coord Struct
		nx_float x;
		nx_float y;
}Coord;

typedef nx_struct BeaconMsg { //RSSI Msg
	Coord loc;
	nx_uint8_t quad;
	nx_uint8_t roomId;
}BeaconMsg;

typedef nx_struct TrackerMsg { 
	nx_uint8_t nodeId;
	Coord loc;
	nx_uint8_t roomId;
	nx_uint8_t quad;
}TrackerMsg;


typedef struct RssiStruct{
	Coord loc;
	uint16_t rssi[RSSI_REPEAT];
	int rssiAvg;
	nx_float distance;
	nx_uint8_t roomId;
	nx_uint8_t quad;
}RssiStruct;


#endif //RSSI_H