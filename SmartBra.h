

// Stabile Pietro 10688876 progetto Smart Bracelets IOT agosto 2022


#ifndef SMART_BRA_H
#define SMART_BRA_H

#define PAIRING_PHASE 1
#define OPERATION_MODE 2
#define ALERT_MODE 3

#define STANDING 1
#define WALKING 2
#define RUNNING 3
#define FALLING 4

#define CHILD 1
#define PARENT 2



typedef nx_struct my_key {
	nx_uint64_t key;
	nx_uint8_t sender;
} my_key_t;

typedef nx_struct pair_msg {
	nx_uint8_t sender;
} pair_msg_t;

typedef nx_struct info_msg {
	nx_uint16_t IDmessage;
	nx_uint8_t sender;
	nx_uint8_t X;
	nx_uint8_t Y;
	nx_uint8_t status;
} info_msg_t;




enum {
  AM_RADIO = 6,
  };

#endif
