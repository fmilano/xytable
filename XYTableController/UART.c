#include <msp430g2553.h>

static unsigned char data_received=0;
static unsigned char data;

void UART_Initialize() {

	P1DIR |= BIT1 + BIT2;

    //Selección de Pines UART
    P1SEL |= BIT1 + BIT2;                       // P1.1 = TX, P1.2 = RX
    P1SEL2 |= BIT1 + BIT2;                       // P1.1 = TX, P1.2 = RX

    //Seteo de CLK
    UCA0CTL1 |= UCSWRST;                        // **Put state machine in reset**
    UCA0CTL1 |= UCSSEL_1;                       // CLK = ACLK (32kHz)
//  UCA0CTL1 |= UCSSEL_2;                       // CLK = SMCLK (1 /MHz)

    //Seteo Caracteristicas de palabra a enviar: Paridad, Little/Big Endian, Tamaño de Dato, Modo UART, Synch/Asynch
    UCA0CTL0 = 0x00;                            // No Parity, but set as Odd. LSB First, 8-bit data, 1 Stop Bit, UART Mode, Asynchronous
//  UCA0CTL0=UCPEN+UCPAR+UC7BIT;                // Even Parity, LSB First, 7-bit Data, 1 Stop Bit ...
//  UCA0CTL0=UC7BIT;                            // ... , 7 bit data, ...
//  UCA0CTL0=UCSPB;                             //... , 2 stop bits, ...

    //Seteo Baud Rate (ver Tabla 34.4 y tener en cuenta la frecuencia de clock elegida)
    UCA0BR0 = 3;                                // 32kHz/9600=3.41 (see User's Guide)
    UCA0BR1 = 0x00;                             //

    UCA0MCTL = UCBRS_3 + UCBRF_0;               // Modulation UCBRSx=3, UCBRFx=0
    UCA0CTL1 &= ~UCSWRST;                       // **Initialize USCI state machine**
    UC0IE |= UCA0RXIE;                           	// Enable USCI_A0 RX interrupt

}

void UART_send_char(unsigned char character) {
    while (!(UC0IFG & UCA0TXIFG))
        ;                                       // Espero a que se desocupe el transmit data buffer (UCTXIFG is set when UCAxTXBUF empty)
    UCA0TXBUF = character;                      // Escribo en el transmit data buffer (Writing the transmit data buffer clears UCTXIFG)
}

unsigned char UART_get_char() {
                                                // UCRXIFG is set when UCAxRXBUF has received a complete character (Alredy done in USCI0RX_ISR)
    data_received = 0;
    return data;                           		// Reading UCAxRXBUF resets the receive-error bits, the UCADDR or UCIDLE bit, and UCRXIFG
}

void UART_shutdown() {
    IE2 &= ~(UCA0RXIE | UCA0TXIE);               // Transmit interrupt disabled, Receive interrupt disabled
    UCA0CTL1 = UCSWRST;                         // Software reset enabled
}

void UART_print_string(unsigned char* string) {

    unsigned int i = 0;

    while (string[i++] != '\0') {

        UART_send_char(string[i]);
    }
}

#pragma vector = USCIAB0RX_VECTOR
__interrupt void USCI0RX_ISR(void)
{
    while (!(UC0IFG & UCA0TXIFG))
    	;   	              		// USCI_A0 TX buffer ready?
	data_received = 1;
	data = UCA0RXBUF;
}

/*  Si vale 1 es que hay un dato para leer en el buffer de RX */
unsigned char UART_get_flag(void)
{
	return data_received;
}
