configuration BaseStationC {
}
implementation {
  components MainC, BaseStationP, LedsC;
  components ActiveMessageC as Radio, SerialActiveMessageC as Serial;

  components new TimerMilliC() as BaseTimer;
  components new TimerMilliC() as SleepTimer;	
  components new AMSenderC(AM_RSSI) as RadioSender;
  
  MainC.Boot <- BaseStationP;

  BaseStationP.RadioControl -> Radio;
  BaseStationP.SerialControl -> Serial;
  
  BaseStationP.BaseTimer -> BaseTimer;
  BaseStationP.SleepTimer -> SleepTimer;

  BaseStationP.UartSend -> Serial;
  BaseStationP.UartReceive -> Serial.Receive;
  BaseStationP.UartPacket -> Serial;
  BaseStationP.UartAMPacket -> Serial;
  
  BaseStationP.RadioSend -> Radio;
  BaseStationP.RadioReceive -> Radio.Receive;
  BaseStationP.RadioSnoop -> Radio.Snoop;
  BaseStationP.RadioPacket -> Radio;
  BaseStationP.RadioAMPacket -> Radio;

  BaseStationP.AMSend -> RadioSender;
  BaseStationP.Packet -> Radio;

  
  BaseStationP.Leds -> LedsC;
}
