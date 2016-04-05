#ifndef RSSI_H
#define RSSI

enum {
  AM_RSSIMSG = 10
};

typedef nx_struct RssiMsg{
  nx_int16_t rssi;
} RssiMsg;


#endif //RSSI