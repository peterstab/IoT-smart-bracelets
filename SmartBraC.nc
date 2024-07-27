
 
 // Stabile Pietro 10688876 progetto Smart Bracelets IOT agosto 2022
 

#include "Timer.h"
#include "SmartBra.h"
#include <stdio.h>


module SmartBraC @safe() {
  uses {
    
    interface Boot;
    
    interface Packet;
    interface AMPacket;
    interface AMSend;
    interface SplitControl;
    interface Receive;
    interface PacketAcknowledgements;
    
    
    interface Timer<TMilli> as Timer10s;
    interface Timer<TMilli> as Timer260s;
    interface Timer<TMilli> as Timer460s;
    interface Timer<TMilli> as TimerOn;
    
    
    interface Read<info_msg_t> as FakeSensor;
  }
}
implementation {

  message_t packet;
 bool locked = FALSE;
 bool ACK;
 uint8_t PHASE = PAIRING_PHASE;
 uint8_t ROLE;
 uint8_t TIMERGO = 0;
 uint16_t ID = 0;
 uint8_t counter = 0;
 uint8_t WAITING = 0;
 uint8_t x;
 uint8_t y;
 uint64_t vect[4] = {'mjiyrloinmailorintlo', 'mjiyrloinmailorintlo', 'wsxmkiuytaliopjhgeil', 'wsxmkiuytaliopjhgeil'};
 // array with keys of bracelets
 uint8_t pairings[4] = {0, 0, 0, 0};
 // array where I save pairings for every node
 info_msg_t fake;
 
 void sendKey();
 void sendPair();
 void sendInfo();
 
 
 void sendKey(){
  	  if (locked) {
  	  	return;}
  	  	
  	  else {
	  
	  my_key_t* rcm = (my_key_t*) call Packet.getPayload(&packet, sizeof(my_key_t));
	  if (rcm == NULL) {
		return;
	  }
	  rcm->key = vect[TOS_NODE_ID-1];
	  rcm->sender = TOS_NODE_ID;
	 
	  
	  if(call AMSend.send(AM_BROADCAST_ADDR, &packet,sizeof(my_key_t)) == SUCCESS){
	  	 locked = TRUE;
		 }
  }
  
}
  
  
  void sendPair(){
  	  if (locked) {
  	  	return;}
  	  	
  	  else {
	  
	  pair_msg_t* rcm2 = (pair_msg_t*) call Packet.getPayload(&packet, sizeof(pair_msg_t));
	  
	  if (rcm2 == NULL) {
		return;
	  }
	  
	  rcm2->sender = TOS_NODE_ID;
	  call PacketAcknowledgements.requestAck(&packet);
	  if(call AMSend.send(pairings[TOS_NODE_ID-1], &packet ,sizeof(pair_msg_t)) == SUCCESS){
	  	 locked = TRUE;
	     }}
  
  }

  
  void sendInfo(){
  	  
  	  if (locked) {
  	  	return;}
  	  	
  	  else {
	  info_msg_t* info = (info_msg_t*) call Packet.getPayload(&packet, sizeof(info_msg_t));
	  ID++;
	  if (info == NULL) {
		return;
	  }
	 
	  info->IDmessage = ID;
	  info->sender = TOS_NODE_ID;
	  info->X = fake.X;
	  info->Y = fake.Y;
	  info->status = fake.status;
	  
	  
	  call PacketAcknowledgements.requestAck(&packet);
	  if(call AMSend.send(pairings[TOS_NODE_ID-1], &packet,sizeof(info_msg_t)) == SUCCESS){
	  	 locked = TRUE;}
  
  }
}
  
  
  
  event void Boot.booted() {
  	  
      dbg("radio","Application booted on node %u.\n", AM_RADIO);
      
      call SplitControl.start();
  }

 
 
  event void SplitControl.startDone(error_t err) {
    
    if(err == SUCCESS) {
    	if(TOS_NODE_ID == 1){
    		
    		ROLE = CHILD;
    		}
    	
    	if(TOS_NODE_ID == 2){
    		
    		ROLE = PARENT;
    		
    		}
    	
    	if(TOS_NODE_ID == 3){
    		
    		ROLE = CHILD;
    		
    		}
    		
    	if(TOS_NODE_ID == 4){
    		
    		ROLE = PARENT;
}
    
        dbg("radiokey", "First Broadcast message sent by %d!\n", TOS_NODE_ID);
        
        
        call TimerOn.startPeriodic(1000);
        call Timer10s.startPeriodic(10000);
  
    		
    	
    }

  }
 
 
 
  event void SplitControl.stopDone(error_t err){}
  
 
  event void TimerOn.fired() {
 	if ( PHASE == PAIRING_PHASE){
	sendKey();
	}
} 
 
 

 event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
	
	
	
    if (len == sizeof(my_key_t)) {
    	my_key_t* rcm = (my_key_t*)payload;
    	
    	dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
    	dbg("radio_rec", "Received my_key packet by %d from %d\n", TOS_NODE_ID, rcm->sender);
    	
    	
    	if (vect[TOS_NODE_ID-1] == rcm->key) {
    		pairings[TOS_NODE_ID-1] = rcm->sender;
    		dbg("radio_pair", "DEVICE %d IS PAIRED WITH %d !\n", TOS_NODE_ID, rcm->sender);
    		
    		PHASE = OPERATION_MODE;
    		call TimerOn.stop();
    		dbg("radio_pair", "FOR %d Phase is %d \n", TOS_NODE_ID, PHASE );
    		
    		sendPair();
	  	     
	  	    }
	  	}
	
	if (len == sizeof(pair_msg_t)){
		pair_msg_t* rcm2 = (pair_msg_t*)payload;
		dbg("radio_pair", "message PAIR ricevuto by %d from %d\n", TOS_NODE_ID, rcm2->sender);
		
		}
	
	
	if (len == sizeof(info_msg_t)){
		info_msg_t* rcm3 = (info_msg_t*)payload;
		dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
		
		PHASE = OPERATION_MODE;
		
		x = rcm3->X;
		y = rcm3->Y;
		
		// I used the variable TIMERGO to only turn it on the first time. For the following times I first turn it off and then turn it on.
		if( TOS_NODE_ID == 2){
			if( TIMERGO == 1){
				call Timer260s.stop();}
			
			call Timer260s.startPeriodic(60000);
		
			TIMERGO = 1;}
			
		if( TOS_NODE_ID == 4){
			if( TIMERGO == 1){
				call Timer460s.stop();}
			
			call Timer460s.startPeriodic(60000);
		
			TIMERGO = 1;}
			

		if (rcm3->status == STANDING){
		dbg("radio_info", "Your child is Standing  in %u and %u !\n",rcm3->X, rcm3->Y);
		}
		
		if (rcm3->status == WALKING){
		dbg("radio_info", "Your child is Walking  in %u and %u !\n",rcm3->X, rcm3->Y);
		}
		
		if (rcm3->status == RUNNING){
		dbg("radio_info", "Your child is Running  in %u and %u !\n",rcm3->X, rcm3->Y);
		}
		
		if(rcm3->status == FALLING){
		dbg("radio_alert", "BE CAREFUL: Child %d has fallen in %u ,%u !\n", rcm3->sender, rcm3->X, rcm3->Y);
		PHASE = ALERT_MODE;
		}
			
			
		}
		
	
	return bufPtr;
}
      
      
 event void FakeSensor.readDone(error_t result, info_msg_t info_f) {
  	fake = info_f;
    
    sendInfo();
  }
  
	
  	

	event void Timer10s.fired() {
	
	counter++;
	//Because I had some troubles stopping a node in Python file, I used a counter to stop sending from child 3 after 9 messages, when I simulate
	// that a child goes too far
  	if ( PHASE == OPERATION_MODE && ROLE == CHILD && TOS_NODE_ID == 3 && counter<10) {
  		call FakeSensor.read() ;}
  		
  	if ( PHASE == OPERATION_MODE && ROLE == CHILD && TOS_NODE_ID == 1) {
  		call FakeSensor.read()  ;}
  		
  		
  	
}

	event void Timer260s.fired() {
	if (TOS_NODE_ID == 2){
		dbg("radio_alert", " BE CAREFUL Your Child is gone\n");
		dbg("radio_alert", "Last position is %d and %d\n", x, y);
		PHASE = OPERATION_MODE;
		}
	
}

	event void Timer460s.fired() {
	if (TOS_NODE_ID == 4){
		dbg("radio_alert", "BE CAREFUL Your Child is gone\n");
		dbg("radio_alert", "Last position is %d and %d\n", x, y);
		PHASE = OPERATION_MODE;
	    }
	
}

	  	        		
  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr && error == SUCCESS ) {
      locked = FALSE;
      
      ACK = call PacketAcknowledgements.wasAcked(bufPtr);
      //To distinguish two cases, I used ID of messages. When ID is 0, none of info messages have been sent so I am still sending pair messages
      //sendKey does not have to be verified because I periodically send the key by timerOn until the device is paired 
      
      if (PHASE != PAIRING_PHASE && ID == 0 && ACK == FALSE){
      	dbg ("radio", "MESSAGE pair NOT received\n");
      	sendPair();
      	}
      	
      	
      if (PHASE != PAIRING_PHASE && ID > 0 && ACK == FALSE){
      	dbg ("radio", "MESSAGE info NOT received\n");
      	sendInfo();
      	}
      
      }


}

}
  
  


