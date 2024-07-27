
// Stabile Pietro 10688876 progetto Smart Bracelets IOT agosto 2022

#include <stdio.h>
generic module FakeSensorP() {

	provides interface Read<info_msg_t>;
	

}



implementation 

{
	uint8_t probability[10] = {1,1,1,2,2,2,4,3,3,3};
	task void readDone();

	
	command error_t Read.read(){
		post readDone();
		return SUCCESS;
	}

	
	
	task void readDone() {
	  
	  info_msg_t place;

	  int index = 0 + rand() % 9;
	  
	  place.status = probability[index];
		
		
	  place.X = 0 + rand() % 100;
	  place.Y = 0 + rand() % 100;
	  signal Read.readDone( SUCCESS, place);

	}
}  
