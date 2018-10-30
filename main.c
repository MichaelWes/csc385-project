void go_forward();    
void go_forward_pwm(int speed);
void go_pwm(int speed, int direction);
void setup_interrupts();
    
int main() {

	setup_interrupts();
	//go_forward();
    //go_forward_pwm(speed); 
    //go_pwm(speed, direction); 
	while(1);
    
	return 0;
}
