#ifndef RSSI_H
#define RSSI_H

enum {
  AM_RSSIMSG = 10,
  BEACON_SEND_INTERVAL_MS = 250
};

typedef nx_struct RssiMsg{
  nx_int16_t rssi;
} RssiMsg;

typedef nx_struct Coord {
	nx_uint16_t x;
	nx_uint16_t y;
}Coord;

typedef nx_struct BeaconMsg {
	RssiMsg sigLevel;
	Coord loc;
}BeaconMsg;

#endif //RSSI_H