/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: John & Jack 
 * DATE CREATED: 2017/11/4
 * FILENAME: probe_def.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 * 		This file is copied from V20170715 directly.
 *--------------------------------------------------------------------*/
#define SPI_READ_REG  0x1f800d00
#define SPI_BUSY_REG  0x1f800d01
#define SPI_WRITE_REG 0x1f800d02
#define SPI_IRQACK_REG 0x1f800d03
#define SPI_CTL_REG  0x1f800d04
#define SPI_DATA_RDY_REG  0x1f800d05
#define SYS_GPIO1_REG 0x1f800706

// EnumApp_enum_data.h 
// Enumeration tables & HID keyboard data
//
const unsigned char DD[]=	// DEVICE Descriptor
        {0x12,	       		// bLength = 18d
        0x01,			// bDescriptorType = Device (1)
        0x00,0x01,		// bcdUSB(L/H) USB spec rev (BCD)
	0x00,0x00,0x00, 	// bDeviceClass, bDeviceSubClass, bDeviceProtocol
	0x40,			// bMaxPacketSize0 EP0 is 64 bytes
	0x6A,0x0B,		// idVendor(L/H)--Maxim is 0B6A
	0x46,0x53,		// idProduct(L/H)--5346
	0x34,0x12,		// bcdDevice--1234
	1,2,3,			// iManufacturer, iProduct, iSerialNumber
	1};			// bNumConfigurations

const unsigned char CD[]=	// CONFIGURATION Descriptor
	{0x09,			// bLength
	0x02,			// bDescriptorType = Config
	0x22,0x00,		// wTotalLength(L/H) = 34 bytes
	0x01,			// bNumInterfaces
	0x01,			// bConfigValue
	0x00,			// iConfiguration
	0xE0,			// bmAttributes. b7=1 b6=self-powered b5=RWU supported
	0x01,			// MaxPower is 2 ma
// INTERFACE Descriptor
	0x09,			// length = 9
	0x04,			// type = IF
	0x00,			// IF #0
	0x00,			// bAlternate Setting
	0x01,			// bNum Endpoints
	0x03,			// bInterfaceClass = HID 03
	0x00,0x00,		// bInterfaceSubClass, bInterfaceProtocol
	0x00,			// iInterface
// HID Descriptor--It's at CD[18]
	0x09,			// bLength
	0x21,			// bDescriptorType = HID 21
	0x10,0x01,		// bcdHID(L/H) Rev 1.1
	0x00,			// bCountryCode (none)
	0x01,			// bNumDescriptors (one report descriptor)
	0x22,			// bDescriptorType	(report)
	43,0,                   // CD[25]: wDescriptorLength(L/H) (report descriptor size is 43 bytes)
// Endpoint Descriptor
	0x07,			// bLength
	0x05,			// bDescriptorType (Endpoint)
	0x83,			// bEndpointAddress (EP3-IN)		
	0x03,			// bmAttributes	(interrupt)
	64,0,                   // wMaxPacketSize (64)
	1};			// bInterval (poll every 10 msec)


const unsigned char RepD[]=   // Report descriptor 
	{
	0x05,0x01,		// Usage Page (generic desktop)
	0x09,0x06,		// Usage (keyboard)
	0xA1,0x01,		// Collection
	0x05,0x07,		//   Usage Page 7 (keyboard/keypad)
	0x19,0xE0,		//   Usage Minimum = 224
	0x29,0xE7,		//   Usage Maximum = 231
	0x15,0x00,		//   Logical Minimum = 0
	0x25,0x01,		//   Logical Maximum = 1
	0x75,0x01,		//   Report Size = 1
	0x95,0x08,		//   Report Count = 8
	0x81,0x02,		//  Input(Data,Variable,Absolute)
	0x95,0x01,		//   Report Count = 1
	0x75,0x08,		//   Report Size = 8
	0x81,0x01,		//  Input(Constant)
	0x19,0x00,		//   Usage Minimum = 0
	0x29,0x65,		//   Usage Maximum = 101
	0x15,0x00,		//   Logical Minimum = 0,
	0x25,0x65,		//   Logical Maximum = 101
	0x75,0x08,		//   Report Size = 8
	0x95,0x01,		//   Report Count = 1
	0x81,0x00,		//  Input(Data,Variable,Array)
	0xC0};			// End Collection 

// STRING descriptors. An array of string arrays

const unsigned char strDesc[][56]= {
// STRING descriptor 0--Language string
{
        0x04,			// bLength
	0x03,			// bDescriptorType = string
	0x09,0x04		// wLANGID(L/H) = English-United Sates
},
// STRING descriptor 1--Manufacturer ID
{
        12,			// bLength
	0x03,			// bDescriptorType = string
	'C',0,'a',0,'m',0,'e',0,'l',0 // text in Unicode
}, 
// STRING descriptor 2 - Product ID
{	20,			// bLength
	0x03,			// bDescriptorType = string
	'C',0,'M',0,'p',0,'r',0,'o',0,'b',0,'e',0,'0',0,'1',0
},

// STRING descriptor 3 - Serial Number ID
{       20,			// bLength
	0x03,			// bDescriptorType = string
	'S',0,				
	'/',0,
	'N',0,
	' ',0,
	'1',0,
	'0',0,
	'0',0,
	'0',0,
        'A',0,
}};


