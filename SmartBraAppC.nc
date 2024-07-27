

// Stabile Pietro 10688876 progetto Smart Bracelets IOT agosto 2022



#include "SmartBra.h"


configuration SmartBraAppC {}


implementation {
  components MainC, SmartBraC as App, LedsC;
  
  
  components new AMSenderC(AM_RADIO);
  components new AMReceiverC(AM_RADIO);
  components ActiveMessageC;
  
  components new TimerMilliC() as number1;
  components new TimerMilliC() as number2;
  components new TimerMilliC() as number3;
  components new TimerMilliC() as number4;
  
  components new FakeSensorC();
  
  
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.SplitControl -> ActiveMessageC;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  
  App.PacketAcknowledgements -> ActiveMessageC;
  
  App.FakeSensor -> FakeSensorC;
  
  App.Timer10s -> number1;
  App.Timer260s -> number2;
  App.TimerOn -> number3;
  App.Timer460s -> number4;
}

