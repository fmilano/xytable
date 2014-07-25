#include "timer.h"

static unsigned char timer_flag = 0;
static unsigned int timer_counter=0;
static unsigned int timer_final=100;

void timer_init(void)
{
	TACTL = TASSEL_2 + ID_0 + MC_1;		// SMCLK/1, Upmode, Interrupt enabled
	TACCTL0 = CCIE;
	TACCR0 = 32;						// Delay = 32768/32 = 1.024 KHz -> 1 ms
}


// Timer A0 interrupt service routine
#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer_A (void)
{
    // Aca llego cada 1 ms
	if (timer_flag == 0)
	{
		// Delay (en ms)
		if (++timer_counter == timer_final)
		{
			timer_flag = 1;
		}
	}
}

void clear_timer_flag(const unsigned int delay)
{
	timer_flag = 0;
	timer_counter = 0;
	timer_final = delay;
}

unsigned char get_timer_flag(void)
{
	return timer_flag;
}
