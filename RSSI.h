#ifndef RSSI_H
#define RSSI_H

#define BASE_STATION_ID 100
#define MAX_TOS_BEACON 3



enum {

  START_MSG = 1,
  SLEEP_MSG = 2,

  AM_RSSIMSG = 10,

  DELAY_INTERVAL_MS = 100,
  BEACON_SEND_INTERVAL_MS = 250
};

// typedef nx_struct RssiMsg{
//   nx_int16_t rssi;
// } RssiMsg;

typedef nx_struct BSMsg {
	nx_uint8_t msg_type;
	nx_uint32_t sleepTime;
}BSMsg;


typedef nx_struct Coord {  //Coord Struct
	nx_uint16_t x;
	nx_uint16_t y;
}Coord;

typedef nx_struct BeaconMsg { //RSSI Msg
	Coord loc;
}BeaconMsg;

typedef nx_struct TrackerMsg { 
	Coord loc;
}TrackerMsg;



#endif //RSSI_H