#include <msp430g2553.h>

void timer_init(void);
void clear_timer_flag(const unsigned int delay);
unsigned char get_timer_flag(void);
