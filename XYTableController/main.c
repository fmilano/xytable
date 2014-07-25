#include <msp430g2553.h>
#include "main.h"
#include "timer.h"
#include "UART.h"


static unsigned char buffer[2] = {0xCC,0xCC};

void main(void) {

	WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer

	P2DIR = 0xFF;				// Puerto 2 declarado de salida
	P1DIR |= BIT6 + BIT7;		// Pines P1.7 y P1.6 declarados de salida
	//P1DIR |= BIT7 + BIT0;		// LED1 y LED2 activados
	BCSCTL2 = SELM_0 + SELS;

	timer_init();
	UART_Initialize();

	P1OUT &= 0x00;


	__enable_interrupt();
	initialize_motor();
	start();
	//debug_motor();
	//debug_uart2();
}

void start(void)
{
	unsigned char orden = 0;
	unsigned char pasos_H = 0;
	unsigned char pasos_L = 0;
	unsigned int pasos = 0;
	while(1)
	{
		while(UART_get_flag() == 0);	// Espero a que se envíe una orden desde MATLAB
		orden = UART_get_char();		// Leo la orden

		switch(orden)
		{
		case MOTOR1_DERECHA:
			while(UART_get_flag() == 0);
			pasos_H = UART_get_char();		// Leo los pasos high
			while(UART_get_flag() == 0);
			pasos_L = UART_get_char();		// Leo los pasos low

			pasos = pasos_H*255 + pasos_L;
			mover_motor(MOTOR1,DERECHA,pasos,5);
			break;
		case MOTOR1_IZQUIERDA:
			while(UART_get_flag() == 0);
			pasos_H = UART_get_char();		// Leo los pasos high
			while(UART_get_flag() == 0);
			pasos_L = UART_get_char();		// Leo los pasos low

			pasos = pasos_H*255 + pasos_L;
			mover_motor(MOTOR1,IZQUIERDA,pasos,5);
			break;
		case MOTOR2_DERECHA:
			while(UART_get_flag() == 0);
			pasos_H = UART_get_char();		// Leo los pasos high
			while(UART_get_flag() == 0);
			pasos_L = UART_get_char();		// Leo los pasos low

			pasos = pasos_H*255 + pasos_L;
			mover_motor(MOTOR2,DERECHA,pasos,5);
			break;
		case MOTOR2_IZQUIERDA:
			while(UART_get_flag() == 0);
			pasos_H = UART_get_char();		// Leo los pasos high
			while(UART_get_flag() == 0);
			pasos_L = UART_get_char();		// Leo los pasos low

			pasos = pasos_H*255 + pasos_L;
			mover_motor(MOTOR2,IZQUIERDA,pasos,5);
			break;
		}
		delay(500);
		UART_send_char(1);					// Interrumpo al programa de MATLAB
	}
}

void initialize_motor(void)
{
	mover_motor(MOTOR1,DERECHA,2,100);
	mover_motor(MOTOR2,DERECHA,2,100);
}

void debug_timer(void)
{
	P1OUT &= ~BIT0;
	P1OUT &= ~BIT6;
	while(1);
}

void delay(const unsigned int time)
{
	clear_timer_flag(time);
	while(get_timer_flag()==0);
}

void debug_uart2(void)
{
	static unsigned char ch_tx = 0;
	static unsigned char ch_rx = 0;

	delay(1000);
	while(1)
	{
		delay(10);
		UART_send_char(ch_tx++);
		P1OUT ^= BIT6;

		if (UART_get_flag() == 1)
		{
			ch_rx = UART_get_char();
			if (ch_rx == 'a')
			{
				P1OUT ^= BIT0;
			}
		}
	}
}

void debug_uart(void)
{
	static unsigned char ch_tx = 0;
	static unsigned char ch_rx = 0;

	while(1)
	{
		delay(1000);
		UART_send_char(ch_tx++);

		while(UART_get_flag() == 0);
		P1OUT ^= BIT6;

		ch_rx = UART_get_char();

		if (ch_rx < 4)
		{
			P1OUT |= BIT0;
		}
		else
		{
			P1OUT &= ~BIT0;
		}
	}
}

void debug_motor(void)
{
	delay(1000);
	mover_motor(MOTOR1,IZQUIERDA,200,5);

	while(1);
}

/*	Realiza n_steps pasos en el motor especificado, cada delay cantidad de ms	*/
void mover_motor(const unsigned char motor, const unsigned char sentido, const unsigned int n_steps, const unsigned int time)
{
	unsigned int i;

	switch(sentido)
	{
	case DERECHA:
		for (i=0;i<n_steps;i++)
		{
			der_buffer(motor);
			step(motor);
			delay(time);
		}
		break;

	case IZQUIERDA:
		for (i=0;i<n_steps;i++)
		{
			izq_buffer(motor);
			step(motor);
			delay(time);
		}
		break;
	}
}

/*	Mueve al motor indicado	en un paso					*/
void step(const unsigned char motor)
{
	switch(motor)
	{
	case MOTOR1:
		//P1OUT = ((buffer[motor]&BIT7)>>7)&BIT0 | (buffer[motor]&BIT6);			// LED1 y LED2
		P1OUT = (buffer[motor]&BIT7) | (buffer[motor]&BIT6);						// P1.7 y P1.6
		break;
	case MOTOR2:
		P2OUT = ((buffer[motor]&BIT7)>>2)&BIT5 | ((buffer[motor]&BIT6)>>2)&BIT4;	// P2.5 y P2.4
		break;
	}
}

/*	Da un paso a la derecha el buffer del motor			*/
void der_buffer(const unsigned char motor)
{
	// Shift circular a la derecha
	if ((buffer[motor] & BIT0) == 0x00)
	{
		buffer[motor] = buffer[motor]>>1;
	}
	else
	{
		buffer[motor] = buffer[motor]>>1;
		buffer[motor] |= BIT7;
	}
}

/*	Da un paso a la izquierda el buffer del motor		*/
void izq_buffer(const unsigned char motor)
{
	// Shift circular a la izquierda
	if ((buffer[motor] & BIT7) == 0x00)
	{
		buffer[motor] = buffer[motor]<<1;
	}
	else
	{
		buffer[motor] = buffer[motor]<<1;
		buffer[motor] |= BIT0;
	}
}

