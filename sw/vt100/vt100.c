#include <stdio.h>
#include "hl_vt100.h"

void memset(char* ptr, char c, int len)
{
	int i;
	for(i=0; i<len; i++)
		ptr[i] = c;
}

unsigned char* alloc_ptr = (unsigned char*)(1024*1024);
unsigned char* calloc(int u, int sz)
{
	unsigned char* ptr = alloc_ptr;
	memset(ptr,0,sz);
	alloc_ptr += sz+1024;
	return ptr;
}

void free(unsigned char* ptr)
{
}

#define SCREEN_ADDRESS 0x17000000
#define SCREEN_STRIDE 0x200
#define TOP_LINE 8
#define LEFT_COL 1

void write_console_char(unsigned char c, unsigned int x, unsigned int y, unsigned int color)
{
	volatile unsigned int *pscr;
	unsigned int wr;
	wr = (color<<8) | c;
	pscr = (unsigned int*)(SCREEN_ADDRESS + x * 4 + y * SCREEN_STRIDE);
	*pscr = wr;
}

void set_cursor_pos(unsigned int x, unsigned int y)
{
	volatile unsigned int *pscr;
	unsigned int wr;
	wr = ((y+TOP_LINE)<<8) | x+(LEFT_COL);
	pscr = (unsigned int*)(SCREEN_ADDRESS + 0x8000);
	*pscr = wr;
}

int dx=0;
void _write_(int fd, const char* pbuf, int len)
{
	int i;
	for(i=0; i<len; i++)
	{
		_outbyte( pbuf[i] );
		write_console_char( pbuf[i],dx,4,3 );
	}
}

void write_console_str(unsigned char* pstr, unsigned int x, unsigned int y, unsigned int color)
{
	volatile unsigned int *pscr;
	unsigned int wr;
	pscr = (unsigned int*)(SCREEN_ADDRESS + x * 4 + y * SCREEN_STRIDE);
	while(1)
	{
		unsigned char c = *pstr++;
		if(c==0) break;
		wr = (color<<8) | c;
		*pscr++ = wr;
	}
}

unsigned char tohex(unsigned int c)
{
	if(c<10)
		return (c+0x30);
	else
		return (c-10+0x41);
}

void write_console_hex(unsigned char c, unsigned int x, unsigned int y)
{
	volatile unsigned int *pscr;
	unsigned int wr;
	pscr = (unsigned int*)(SCREEN_ADDRESS + x * 4 + y * SCREEN_STRIDE);
	wr = (0x0700) | (tohex(c>>4));
	*pscr++ = wr;
	wr = (0x0700) | (tohex(c&0xF));
	*pscr++ = wr;
	*pscr++ = 0x0720;
}

#define BLEN 16
//serial received buffer
unsigned char _srbuf[BLEN];
//serial write buffer
unsigned char _swbuf[BLEN];
//ps2 received buffer
unsigned char _ps2buf[BLEN];

//put char into fifo and display fifo on screen
void put_buf(unsigned char* pbuf, unsigned char c, int x, int y)
{
	int i,j;
	for(i=BLEN-2; i>=0; i--)
	{
		pbuf[i+1]=pbuf[i];
	}
	pbuf[0]=c;
	for(i=0; i<BLEN; i++)
	{
		j=BLEN-i-1;
		write_console_hex (pbuf[j],x+i*3  ,y+0  );
		write_console_char(pbuf[j],x+i*3+0,y+1,7);
		write_console_char(' '    ,x+i*3+1,y+1,7);
		write_console_char(' '    ,x+i*3+2,y+1,7);
	}
}

unsigned char ps2_keycodes[]=
{
'?','?','?','?', '?','?','?','?', '?','?','?','?', '?',  9,'?','?',
'?','?','?','?', '?','q','1','?', '?','?','z','s', 'a','w','2','?',
'?','c','x','d', 'e','4','3','?', '?',' ','v','f', 't','r','5','?',
'?','n','b','h', 'g','y','6','?', '?','?','m','j', 'u','7','8','?',

',','?','k','i', 'o','0','9','?', '?','.','/','l', ';','p','-','?',
'?','?',' ','?', '[','=',  8,'?', '?','?', 13,']', '?','\\','?','?',
'?','?','?','?', '?','?', 27,'?', '?','?','?','?', '?','?','?','?',
'?','?','?','?', '?','?','?','?', '?','?','?','?', '?','?','?','?',
};

unsigned char ps2_keycodes_[]=
{
'?','?','?','?', '?','?','?','?', '?','?','?','?', '?',  9,'?','?',
'?','?','?','?', '?','Q','!','?', '?','?','Z','S', 'A','W','@','?',
'?','C','X','D', 'E','$','#','?', '?',' ','V','F', 'T','R','%','?',
'?','N','B','H', 'G','Y','^','?', '?','?','M','J', 'U','&','*','?',

'<','?','K','I', 'O',')','(','?', '>','>','?','L', ':','P','_','?',
'?','?',' ','?', '{','+',  8,'?', '?','?', 13,'}', '?','\\','?','?',
'?','?','?','?', '?','?', 27,'?', '?','?','?','?', '?','?','?','?',
'?','?','?','?', '?','?','?','?', '?','?','?','?', '?','?','?','?',
};

unsigned char want_idx = 1;
unsigned int  least_scancode = 0;
unsigned char keycodes[16];
unsigned int  shift_flag = 0;
unsigned int  ctrl_flag = 0;

//PS2 to terminal code translation for F1-f12 keys
unsigned int f_key_table[] = 
{
	0x4f5005,
	0x4f5106,
	0x4f5204,
	0x4f530c,
/*
	0x313105,
	0x313206,
	0x313304,
	0x31340c,
*/
	0x313503,
	0x31370b,
	0x313883,
	0x31390a,

	0x323001,
	0x323109,
	0x323378,
	0x323407
};

//return number of ready keycodes
//keycodes stored at pointer
unsigned int read_ps2(unsigned char* pkeycodes)
{
	int i,j,k,m;
	volatile unsigned int *pscr;
	unsigned int ps2code[4];
	unsigned char* pfifo;
	pscr = (unsigned int*)SCREEN_ADDRESS;
	ps2code[0] =  pscr[0];
	ps2code[1] =  pscr[1];
	ps2code[2] =  pscr[0];
	ps2code[3] =  pscr[1];
	if( ps2code[0] != ps2code[2] ) return 0;
	if( ps2code[1] != ps2code[3] ) return 0;

	k=0;
	for(j=0; j<4; j++)
	{
	 int found = 0;
	 pfifo=(unsigned char*)&ps2code[0];
	 for(i=0; i<4; i++)
	 {
		unsigned char fifo_idx  = pfifo[i*2+1];
		unsigned char fifo_code = pfifo[i*2+0];
		if(fifo_idx==want_idx)
		{
			//get code!
			if( (least_scancode&0xFF)==0xF0)
			{
				//release
				if(fifo_code==0x12)
				{
					shift_flag=0;
					write_console_str("     ",0,2,0x07);
				}
				else
				if(fifo_code==0x14)
				{
					ctrl_flag=0;
					write_console_str("    ",6,2,0x07);
				}
			}
			else
			{
				//make by table
				if(fifo_code!=0xF0 && fifo_code!=0xE0)
				{
					int f_key=0;
					//check for F1-F12 keys
					for(m=0; m<12; m++)
					{
						if( (f_key_table[m]&0xFF)==fifo_code)
						{
							//F-key found
							pkeycodes[k++] = 0x1b;
							pkeycodes[k++] = (f_key_table[m]>>16)&0xFF;
							pkeycodes[k++] = (f_key_table[m]>> 8)&0xFF;
							f_key=1;
							break;
						}
					}
					if(f_key) {}
					else
					if(fifo_code==0x12)
					{
						shift_flag=1;
						write_console_str("SHIFT",0,2,0x07);
					}
					else
					if(fifo_code==0x14)
					{
						ctrl_flag=1;
						write_console_str("CTRL ",6,2,0x07);
					}
					else
					if(fifo_code==0x6b)
					{
						//keypad left
						pkeycodes[k++] = 0x1b;
						pkeycodes[k++] = 0x5b;
						pkeycodes[k++] = 0x44;
					}
					else
					if(fifo_code==0x74)
					{
						//keypad right
						pkeycodes[k++] = 0x1b;
						pkeycodes[k++] = 0x5b;
						pkeycodes[k++] = 0x43;
					}
					else
					if(fifo_code==0x75)
					{
						//keypad up
						pkeycodes[k++] = 0x1b;
						pkeycodes[k++] = 0x5b;
						pkeycodes[k++] = 0x41;
					}
					else
					if(fifo_code==0x72)
					{
						//keypad up
						pkeycodes[k++] = 0x1b;
						pkeycodes[k++] = 0x5b;
						pkeycodes[k++] = 0x42;
					}
					else
					{
						if(shift_flag)
							pkeycodes[k++] = ps2_keycodes_[fifo_code];
						else
						if(ctrl_flag)
						{
							unsigned char cc = ps2_keycodes[fifo_code];
							if(cc>0x60)
								cc = cc - 0x60;
							else
								cc = 0;
							pkeycodes[k++] = cc;
						}
						else
							pkeycodes[k++] = ps2_keycodes[fifo_code];
					}
				}
			}
			least_scancode = (least_scancode<<8) | fifo_code;
			want_idx = (want_idx+1)&0xF;
			found=1;
			//put_buf(_ps2buf,fifo_code,0,4);
			break;
		}
	 }
	 if(found==0)
		break;
	}
	//write_console_char( tohex( (ps2code>>4)&0xF ), 8, 4, 7);
	//write_console_char( tohex( ps2code&0xF ), 9, 4, 7);
	return k;
}

void copy2screen(struct vt100_headless *vt100)
{
    unsigned int x,y;
    char **lines;

    lines = vt100_headless_getlines(vt100);
    for (y = 0; y < vt100->term->height; y++)
    {
	char* pline = lines[y];
	for(x=0; x<vt100->term->width; x++)
	{
		write_console_char(pline[x], x, y+10, 7);
        }
    }
}

#define ADR_AMBER_UART0_DR             0x16000000
#define ADR_AMBER_UART0_FR             0x16000018

//read from serial port
int read_serial_char(unsigned char* pbyte)
{
	volatile unsigned int* pUartDr = ADR_AMBER_UART0_DR;
	volatile unsigned int* pUartFr = ADR_AMBER_UART0_FR;
	if( (*pUartFr) & 0x10 )
	{
		return 0;
	}
	else
	{
		*pbyte = *pUartDr;
		return 1;
	}
}

//translate table (except E with dots)
unsigned char cyrillic_table[] =
{
	0xe0,0xe1,0xe2,0xe3, 0xe4,0xe5,0xe6,0xe7, 0xe8,0xe9,0xea,0xeb, 0xec,0xed,0xee,0xef,
	0x80,0x81,0x82,0x83, 0x84,0x85,0x86,0x87, 0x88,0x89,0x8a,0x8b, 0x8c,0x8d,0x8e,0x8f,
	0x90,0x91,0x92,0x93, 0x94,0x95,0x96,0x97, 0x98,0x99,0x9a,0x9b, 0x9c,0x9d,0x9e,0x9f,
	0xa0,0xa1,0xa2,0xa3, 0xa4,0xa5,0xa6,0xa7, 0xa8,0xa9,0xaa,0xab, 0xac,0xad,0xae,0xaf,
};

unsigned int last_rbytes = 0;
void read_serial2term(struct vt100_headless *vt100)
{
	char c[2]={0,0};
	char cc;
	int r = read_serial_char(&cc);
	c[0]=cc;
	if( r )
	{
		//put_buf(_srbuf,cc,0,2);
		if(
			((cc&0xF0)==0xD0) ||
			 (cc==0xE2) ||
			 ((last_rbytes&0xFF)==0xE2)
		  )
		{
			//it should be UTF-8 prefix char
			//skip it
			last_rbytes=(last_rbytes<<8)|cc;
			return 0;
		}
		if((last_rbytes&0xF0)==0xD0)
		{
			last_rbytes=(last_rbytes<<8)|c[0];
			//current char is part of UTF-8
			//translate it to ASCII
			c[0] = cyrillic_table[ c[0]-0x80 ];
		}
		else
		if((last_rbytes&0xFF00)==0xE200)
		{
			last_rbytes=(last_rbytes<<8)|c[0];
			//current char is part of UTF-8
			//translate it to semi graphics
			c[0] = 0xB0; //c[0]+0x44;
		}
		lw_terminal_vt100_read_str(vt100->term,c);
	}
}

int main(int ac, char **av)
{
	unsigned int num_ps2code,i,cline;
	struct vt100_headless *vt100_headless;
	char **lines;
	write_console_str(" Hello VT100 World!",0,0,7);
	vt100_headless = new_vt100_headless();
	lines = vt100_headless_getlines(vt100_headless);
	cline=0;
	while(1)
	{
		read_serial2term(vt100_headless);
		num_ps2code=read_ps2(keycodes);
		for(i=0; i<num_ps2code; i++)
		{
			//put_buf(_swbuf,keycodes[i],0,6);
			_outbyte(keycodes[i]);
		}

		{
		 unsigned int x;
		 short* pline = (short*)lines[cline];
		 volatile unsigned int *pscr;
		 pscr = (unsigned int*)(SCREEN_ADDRESS +LEFT_COL*4 +(cline+TOP_LINE) * SCREEN_STRIDE);
		 for(x=0; x<vt100_headless->term->width; x++)
		 {
			//write_console_char(pline[x], x, y+10, 7);
			*pscr++ = pline[x] ;
			if( (x&0x3f)==0)
				read_serial2term(vt100_headless);
		 }
		 cline++;
		 if(cline==vt100_headless->term->height)
		 {
			cline=0;
			lines = vt100_headless_getlines(vt100_headless);
		 }
		}
		set_cursor_pos(vt100_headless->term->x,vt100_headless->term->y);
	}
	return 0;
}
