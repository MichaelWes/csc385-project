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
    volatile int * JP1_ptr = (int *) 0xFF200060;  // JP1 port address
    int PS2_data, RVALID;
    int JP1_data;
    int JP1_VALID[2];
    int SENSOR_VAL[2];
    enum mode {STATE = 0, VALUE = 1};
    enum mode mode_bit = STATE;
    // always start in state mode due to setup_interrupts

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
        
        while(1) {
            JP1_data = *(JP1_ptr);
            if(mode_bit = (JP1_data & 0x00200000) >> 21) {
                // value mode => determine crash direction
                // block it in the switch-case.

                // TODO: move this polling into a helper function or two.
                //Enable sensor 0; disable the others.
                *(JP1_ptr) = (JP1_data & (~(1 << 10))) | (0x00055000);
                //Read sensor 0 value.
                while(1) {
                    JP1_data = *(JP1_ptr);
                    JP1_VALID[0] = JP1_data & (1 << 11);
                    if(JP1_VALID[0]) {
                        SENSOR_VAL[0] = (JP1_data & (0x78000000)) >> 27;
                    } else {
                        continue;
                    }
                }
                //Enable sensor 1; disable the others.
                *(JP1_ptr) = (JP1_data & (~(1 << 12))) | (0x00054400);
                //Read sensor 0 value.
                while(1) {
                    JP1_data = *(JP1_ptr);
                    JP1_VALID[0] = JP1_data & (1 << 13);
                    if(JP1_VALID[0]) {
                        SENSOR_VAL[0] = (JP1_data & (0x78000000)) >> 27;
                    } else {
                        continue;
                    }
                }
                
                // check if I can go back to state mode.
                // assume that thresholds dont need to be reloaded

                // This is probably causing some weird race.
                /*
                if(SENSOR_VAL[0] >= 0xB && SENSOR_VAL[1] >= 0xB) {
                    *(JP1_ptr) = 0xFFBFFFFF; 
                    mode_bit = STATE; // update the flag; we are in state mode
                }
                */
            } else {
                // state mode => safe
                break;
            }
        }

        // Dispatch key press to appropriate handler.
        switch (byte3)
        {
            case 0x1D:
            // key 'W', forward.
                if ((mode_bit && (SENSOR_VAL[1] >= 0xB)) || !mode_bit){
                    motor0_fwd();
                }
                break;
            case 0x1B:
            // key 'S', backward.
                if((mode_bit && (SENSOR_VAL[0] >= 0xB)) || !mode_bit) {
                    motor0_bwd();
                }
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
