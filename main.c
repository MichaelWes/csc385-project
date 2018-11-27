#define RLEDs ((volatile long *) 0xFF200000)

void setup_interrupts();
    
int main() {
	unsigned char byte1 = 0;
	unsigned char byte2 = 0;
	unsigned char byte3 = 0;
	
  	volatile int * PS2_ptr = (int *) 0xFF200100;  // PS/2 port address
    int PS2_data, RVALID;

    setup_interrupts();
    while(1) {
        PS2_data = *(PS2_ptr);	// read the Data register in the PS/2 port
	RVALID = (PS2_data & 0x8000);	// extract the RVALID field
	if (RVALID != 0)
	{
	     /* always save the last three bytes received */
	     byte1 = byte2;
	     byte2 = byte3;
	     byte3 = PS2_data & 0xFF;
	}
	if (byte3 == 0xAA)
	{
	     // mouse inserted; initialize sending of data
	     *(PS2_ptr) = 0xF4;
	}
	// Display last byte on Red LEDs
	*RLEDs = byte3;


	initialize_timer();
	start_timer_once();
	initialize_timer1();
	start_timer1_continuous();
	    
	switch (byte3)
	{
		case 0x1C:
			motor0_fwd();
			break;
		case 0x23:
			motor1_fwd();
			break;
		case 0x1D:
			motor1_bwd();
			break;
		case 0x1B:
			motor0_bwd();
			break;
		case 0xF0:
			motors_off();
			break;
	}
	   
    }

    return 0;
}
