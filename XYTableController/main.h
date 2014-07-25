// Constantes del main
#define		MOTOR1		0
#define		MOTOR2		1
#define		DERECHA		0
#define		IZQUIERDA	1

// Constantes de la comunicación
#define		IDLE				0
#define		MOTOR1_DERECHA		1
#define		MOTOR1_IZQUIERDA	2
#define		MOTOR2_DERECHA		3
#define		MOTOR2_IZQUIERDA	4

// Prototipos
void start(void);
void debug_uart(void);
void debug_uart2(void);
void debug_timer(void);
void debug_motor(void);
void der_buffer(const unsigned char motor);
void izq_buffer(const unsigned char motor);
void mover_motor(const unsigned char motor, const unsigned char sentido, const unsigned int n_steps, const unsigned int time);
void step(const unsigned char motor);
void delay(const unsigned int time);
void initialize_motor(void);
