typedef unsigned char BYTE;     // these save typing
typedef unsigned short WORD;

extern BYTE connected;         // usb is connected to host or not
void initialize_MAX(void);
void probe_setup();
void CMProbe(unsigned char addr, unsigned long val);


