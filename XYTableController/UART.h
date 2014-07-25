void UART_Initialize(void);
void UART_send_char(unsigned char character);
unsigned char UART_get_char();
void UART_shutdown(void);
void UART_print_string(unsigned char* string);
unsigned char UART_get_flag(void);
