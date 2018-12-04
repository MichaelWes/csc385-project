#define RLEDs ((volatile long *) 0xFF200000)

void setup_interrupts();
void initialize_timer();
void start_timer_once();
void motor0_bwd();
void motor1_bwd();
void motor0_fwd();
void motor1_fwd();
void motors_off();
    
int main() {
	unsigned char byte1 = 0;
	unsigned char byte2 = 0;
	unsigned char byte3 = 0;
	
  	volatile int * PS2_ptr = (int *) 0xFF200100;  // PS/2 port address
    int PS2_data, RVALID;

    setup_interrupts();
    initialize_timer();
    //initialize_timer1();
    
    while(1) {
        PS2_data = *(PS2_ptr);	// read the Data register in the PS/2 port
        RVALID = (PS2_data & 0x8000);	// extract the RVALID field
        if (RVALID != 0)
        {
            /* always save the last three bytes received */
            byte1 = byte2;
            byte2 = byte3;
            byte3 = PS2_data & 0xFF;
            
            if (byte2 == 0xF0) {
                motors_off();
                PS2_data = *(PS2_ptr);
                RVALID = (PS2_data & 0x8000);
                if(RVALID != 0) {
                    byte1 = byte2;
                    byte2 = byte3;
                    byte3 = PS2_data & 0xFF;
                } else {
                    continue;
                }
            }
            
        } else {
            continue;
        }
        /*
        if (byte3 == 0xAA)
        {
            // keyboard inserted; initialize sending of data
            *(PS2_ptr) = 0xF4;
        }
        */
        // Display last byte on Red LEDs
        *RLEDs = byte3;

        //start_timer_once();
        //start_timer1_continuous();
            
        // Dispatch key press to appropriate handler.
        switch (byte3)
        {
            case 0x1D:
            // key 'W', forward.
                motor0_bwd();
                break;
            case 0x1B:
            // key 'S', backward.
                motor0_fwd();
                break;
            case 0x1C:
                // key 'A', left.
                motor1_bwd();
                break;
            case 0x23:
            // key 'D', right.
                motor1_fwd();
                break;
        }
        /*	   
        switch (byte2) {
            case 0xF0:
                motors_off();
                break;
        }*/
    }

    return 0;
}
