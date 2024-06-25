
typedef unsigned char  byte;
typedef unsigned short dbyte;

// // //
// The Chip-8 language is capable of accessing up to 4KB (4,096 bytes) of RAM,
// from location 0x000 (0) to 0xFFF (4095). The first 512 bytes, from 0x000
// to 0x1FF, are where the original interpreter was located, and should not be
// used by programs.
// 
// Most Chip-8 programs start at location 0x200 (512), but some begin at 0x600 
// (1536). Programs beginning at 0x600 are intended for the ETI 660 computer.
//
// Memory Map:
// +---------------+= 0xFFF (4095) End of Chip-8 RAM
// |               |
// |               |
// |               |
// | 0x200 to 0xFFF|
// |     Chip-8    |
// | Program / Data|
// |     Space     |
// |               |
// |               |
// +- - - - - - - -+= 0x600 (1536) Start of ETI 660 Chip-8 programs
// |               |
// |               |
// |               |
// +---------------+= 0x200 (512) Start of most Chip-8 programs
// | 0x000 to 0x1FF|
// | Reserved for  |
// |  interpreter  |
// +---------------+= 0x000 (0) Start of Chip-8 RAM
// // // 
#define PROG_START     0x200
#define PROG_START_ETI 0x600
static byte ram[4096];

// // //
// Chip-8 has 16 general purpose 8-bit registers, usually referred to as Vx,
// where x is a hexadecimal digit (0 through F). There is also a 16-bit 
// register called I. This register is generally used to store memory addresses,
// so only the lowest (rightmost) 12 bits are usually used.
//
// The VF register should not be used by any program, as it is used as a flag 
// by some instructions. 
//
// Chip-8 also has two special purpose 8-bit registers, for the delay and sound
// timers. When these registers are non-zero, they are automatically 
// decremented at a rate of 60Hz. See the section 2.5, Timers & Sound, for more 
// information on these.
// 
// There are also some "pseudo-registers" which are not accessable from Chip-8
// programs. The program counter (PC) should be 16-bit, and is used to store
// the currently executing address. The stack pointer (SP) can be 8-bit, it is
// used to point to the topmost level of the stack.
//
// The stack is an array of 16 16-bit values, used to store the address that 
// the interpreter shoud return to when finished with a subroutine. Chip-8 
// allows for up to 16 levels of nested subroutines.
// // //
static byte v[16];
static dbyte i;
static byte dt;
static byte st;
static dbyte pc;
static byte sp;
static dbyte stack[16];

// // // 
// The original implementation of the Chip-8 language used a 64x32-pixel 
// monochrome display with this format:
// --------------------
// | (0,0)    (63,0)  |
// | (0,31)   (63,31) |
// --------------------
// // // 
static byte display[2048];

// // //
// Chip-8 draws graphics on screen through the use of sprites. A sprite is a
// group of bytes which are a binary representation of the desired picture.
// Chip-8 sprites may be up to 15 bytes, for a possible sprite size of 8x15.
//
// Programs may also refer to a group of sprites representing the hexadecimal
// digits 0 through F. These sprites are 5 bytes long, or 8x5 pixels. The data
// should be stored in the interpreter area of Chip-8 memory (0x000 to 0x1FF).
// Below is a listing of each character's bytes, in binary and hexadecimal:
// // //
static const byte chars[16][5] = {
  {0xf0, 0x90, 0x90, 0x90, 0xf0}, // 0
  {0x20, 0x60, 0x20, 0x20, 0x70}, // 1
  {0xf0, 0x10, 0xf0, 0x80, 0xf0}, // 2
  {0xf0, 0x10, 0xf0, 0x10, 0xf0}, // 3
  {0x90, 0x90, 0xf0, 0x10, 0x10}, // 4
  {0xf0, 0x80, 0xf0, 0x10, 0x10}, // 5
  {0xf0, 0x80, 0xf0, 0x90, 0xf0}, // 6
  {0xf0, 0x10, 0x20, 0x40, 0x40}, // 7
  {0xf0, 0x90, 0xf0, 0x90, 0x90}, // 8
  {0xf0, 0x90, 0xf0, 0x10, 0xf0}, // 9
  {0xf0, 0x90, 0xf0, 0x90, 0x90}, // A
  {0xe0, 0x90, 0xe0, 0x90, 0xe0}, // B
  {0xf0, 0x80, 0x80, 0x80, 0xf0}, // C
  {0xe0, 0x90, 0x90, 0x90, 0xe0}, // D
  {0xf0, 0x80, 0xf0, 0x80, 0x80}, // E
};

// // //
// The original implementation of the Chip-8 language includes 36 different
// instructions, including math, graphics, and flow control functions.
// Super Chip-48 added an additional 10 instructions, for a total of 46.
// // //

#define CLS_c 0x00e0
static inline void CLS(void) {
  // Clears the screen
  for (dbyte pixel = 0; pixel < 2048; pixel++)
    display[pixel] = 0;
}

#define RET_c 0x00ee
static inline void RET(void) {
  // Return from a subroutine.
  pc = stack[sp--];
}

#define JP_addr_c 0x1000
static inline void JP_addr(dbyte nnn) {
  // Jump to location nnn.
  pc = nnn;
}

#define CALL_addr_c 0x2000
static inline void CALL_addr(dbyte nnn) {
  // Call subroutine at nnn.
  stack[++sp] = pc;
  pc = nnn;
}

#define SE_Vx_byte_c 0x3000
static inline void SE_Vx_byte(byte x, byte kk) {
  // Skip next instruction if Vx = kk.
  if(v[x] == kk)
    pc += 2;
}

#define SNE_Vx_byte_c 0x4000
static inline void SNE_Vx_byte(byte x, byte kk) {
  // Skip next instruction if Vx != kk.
  if (v[x] != kk)
    pc += 2;
}

#define SE_Vx_Vy_c 0x5000
static inline void SE_Vx_Vy(byte x, byte y) {
  // Skip next instruction if Vx = Vy.
  if(v[x] == v[y])
    pc += 2;
}

#define LD_Vx_byte_c 0x6000
static inline void LD_Vx_byte(byte x, byte kk) {
  // Set Vx = kk.
  v[x] = kk;
}

#define ADD_Vx_byte_c 0x7000
static inline void ADD_Vx_byte(byte x, byte kk) {
  // Set Vx = Vx + kk.
  v[x] += kk;
}

#define LD_Vx_Vy_c 0x8000
static inline void LD_Vx_Vy(byte x, byte y) {
  // Set Vx = Vy.
  v[x] = v[y];
} 

#define OR_Vx_Vy_c 0x8001
static inline void OR_Vx_Vy(byte x, byte y) {
  // Set Vx = Vx OR Vy.
  v[x] |= v[y];
} 

#define AND_Vx_Vy_c 0x8002
static inline void AND_Vx_Vy(byte x, byte y) {
  // Set Vx = Vx AND Vy.
  v[x] &= v[y];
} 

#define XOR_Vx_Vy_c 0x8003
static inline void XOR_Vx_Vy(byte x, byte y) {
  // Set Vx = Vx XOR Vy.
  v[x] ^= v[y];
} 

#define ADD_Vx_Vy_c 0x8003
static inline void ADD_Vx_Vy(byte x, byte y) {
  // Set Vx = Vx + Vy, set VF = carry,
  const dbyte res = v[x] + v[y];
  v[0xf] = (res > 255)? 1 : 0;
  v[x] = res & 0xff;
} 


