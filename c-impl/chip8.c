#include <raylib.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include <time.h>
#include <stdlib.h>
#include "chip8.h"

typedef unsigned char  byte;
typedef unsigned short dbyte;

#define PROG_START  0x200
#define PROG_MAXLEN 0xdfe

static byte ram[4096];
static byte v[16];
static dbyte i;
static byte dt;
static byte st;
static dbyte pc;
static byte sp;
static dbyte stack[16];
static byte keypad[16];
static byte display[2048];

static const byte sprites[80] = {
  0xf0, 0x90, 0x90, 0x90, 0xf0, // 0
  0x20, 0x60, 0x20, 0x20, 0x70, // 1
  0xf0, 0x10, 0xf0, 0x80, 0xf0, // 2
  0xf0, 0x10, 0xf0, 0x10, 0xf0, // 3
  0x90, 0x90, 0xf0, 0x10, 0x10, // 4
  0xf0, 0x80, 0xf0, 0x10, 0xf0, // 5
  0xf0, 0x80, 0xf0, 0x90, 0xf0, // 6
  0xf0, 0x10, 0x20, 0x40, 0x40, // 7
  0xf0, 0x90, 0xf0, 0x90, 0xf0, // 8
  0xf0, 0x90, 0xf0, 0x10, 0xf0, // 9
  0xf0, 0x90, 0xf0, 0x90, 0x90, // A
  0xe0, 0x90, 0xe0, 0x90, 0xe0, // B
  0xf0, 0x80, 0x80, 0x80, 0xf0, // C
  0xe0, 0x90, 0x90, 0x90, 0xe0, // D
  0xf0, 0x80, 0xf0, 0x80, 0xf0, // E
  0xf0, 0x80, 0xf0, 0x80, 0x80, // F
};

/// Keypad mappings to QWERTY keyboard
static const KeyboardKey keys[16] = {
  KEY_X,    KEY_KP_1, KEY_KP_2, KEY_KP_3,
  KEY_Q,    KEY_W,    KEY_E,    KEY_A,
  KEY_S,    KEY_D,    KEY_Z,    KEY_C,
  KEY_KP_4, KEY_R,    KEY_F,    KEY_V,
};


// Clears the 64x32 display buffer
// (0x00e0)
static inline void cls(void) {
  // Clears the screen
  for (int x = 0; x < 2048; x++)
    display[x] = 0;
  pc += 2;
}

// Return from subroutine
// The interpreter sets the program counter to the address at the top of
// the stack, then subtracts 1 from the stack pointer.
// (0x00ee)
static inline void ret(void) {
  pc = stack[sp--] + 2;
}

// Jump to location nnn
// The interpreter sets the program counter to nnn.
// (0x1nnn)
static inline void jp(dbyte nnn) {
  pc = nnn;
}

// Call subroutine at nnn
// The interpreter increments the stack pointer, then puts the current
// PC on the top of the stack. The PC is then set to nnn.
// (0x2nnn)
static inline void call(dbyte nnn) {
  stack[++sp] = pc;
  pc = nnn;
}

// Skip next instruction if Vx = kk
/// The interpreter compares register Vx to kk, and if they are equal,
/// increments the program counter by 2.
/// (0x3xkk)
static inline void se_vx_byte(byte x, byte kk) {
  pc += (v[x] == kk)? 4 : 2; 
}

/// Skip next instruction if Vx != kk.
/// The interpreter compares register Vx to kk, and if they are not equal,
/// increments the program counter by 2.
/// (0x4xkk)
static inline void sne_vx_byte(byte x, byte kk) {
  pc += (v[x] != kk)? 4 : 2;
}

/// Skip next instruction if Vx = Vy.
/// The interpreter compares register Vx to register Vy, and if they are
/// equal, increments the program counter by 2.
/// (0x5xy0)
static inline void se_vx_vy(byte x, byte y) {
  pc += (v[x] == v[y])? 4 : 2;
}

/// Set Vx = kk.
/// The interpreter puts the value kk into register Vx.
/// (0x6xkk)
static inline void ld_vx_byte(byte x, byte kk) {
  v[x] = kk;
  pc += 2;
}

/// Set Vx = Vx + kk.
/// Adds the value kk to the value of register Vx, then stores the
/// result in Vx.
/// (0x7xkk)
static inline void add_vx_byte(byte x, byte kk) {
  v[x] += kk;
  pc += 2;
}

/// Set Vx = Vy.
/// Stores the value of register Vy in register Vx.
/// (0x8xy0)
static inline void ld_vx_vy(byte x, byte y) {
  v[x] = v[y];
  pc += 2;
}

// Set Vx = Vx OR Vy.
/// Performs a bitwise OR on the values of Vx and Vy, then stores
/// the result in Vx.
/// (0x8xy1)
static inline void or_vx_vy(byte x, byte y) {
  v[x] |= v[y];
  pc += 2;
}

/// Set Vx = Vx AND Vy.
/// Performs a bitwise AND on the values of Vx and Vy, then stores
/// the result in Vx.
/// (0x8xy2)
static inline void and_vx_vy(byte x, byte y) {
  v[x] &= v[y];
  pc += 2;
}

/// Set Vx = Vx XOR Vy.
/// Performs a bitwise exclusive OR on the values of Vx and Vy, then
/// stores the result in Vx.
/// (0x8xy3)
static inline void xor_vx_vy(byte x, byte y) {
  v[x] ^= v[y];
  pc += 2; 
}

/// Set Vx = Vx + Vy, set VF = carry.
/// The values of Vx and Vy are added together. If the result is greater
/// than 8 bits (i.e., > 255,) VF is set to 1, otherwise 0. Only the
/// lowest 8 bits of the result are kept, and stored in Vx.
/// (0x8xy4)
static inline void add_vx_vy(byte x, byte y) {
  dbyte sum = v[x] + v[y];
  v[0xf] = (sum > 0xff);
  v[x] = sum & 0xff;
  pc += 2; 
}

/// Set Vx = Vx - Vy, set VF = NOT borrow.
/// If Vx > Vy, then VF is set to 1, otherwise 0. Then Vy is subtracted
/// from Vx, and the results stored in Vx.
/// (0x8xy5)
static inline void sub_vx_vy(byte x, byte y) {
  v[0xf] = (v[x] > v[y]);
  v[x] = (v[x] - v[y]) & 0xff;
  pc += 2;
}

/// Set Vx = Vx SHR 1.
/// If the least-significant bit of Vx is 1, then VF is set to 1,
/// otherwise 0. Then Vx is divided by 2.
/// (0x8xy6)
static inline void shr_vx(byte x) {
  v[0xf] = (v[x] & 0x1);
  v[x] >>= 0x1;
  pc += 2;
}

/// Set Vx = Vy - Vx, set VF = NOT borrow.
/// If Vy > Vx, then VF is set to 1, otherwise 0. Then Vx is subtracted
/// from Vy, and the results stored in Vx.
/// (0x8xy7)
static inline void subn_vx_vy(byte x, byte y) {
  v[0xf] = (v[y] > v[x]);
  v[x] = (v[y] - v[x]) & 0xff;
  pc += 2;
}

/// Set Vx = Vx SHL 1.
/// If the most-significant bit of Vx is 1, then VF is set to 1,
/// otherwise to 0. Then Vx is multiplied by 2.
/// (0x8xye)
static inline void shl_vx(byte x) {
  v[0xf] = (v[x] >> 0x7);
  v[x] <<= 1;
  pc += 2;
}

/// Skip next instruction if Vx != Vy.
/// The values of Vx and Vy are compared, and if they are not equal,
/// the program counter is increased by 2.
/// (0x9xy0)
static inline void sne_vx_vy(byte x, byte y) {
  pc += (v[x] != v[y])? 4 : 2;
}

/// Set I = nnn.
/// The value of register I is set to nnn.
/// (0xannn)
static inline void ld_i_addr(dbyte nnn) {
  i = nnn;
  pc += 2;
}

/// Jump to location nnn + V0.
/// The program counter is set to nnn plus the value of V0.
/// (0xbnnn)
static inline void jp_v0_addr(dbyte nnn) {
  pc = v[0] + nnn;
}

/// Set Vx = random byte AND kk.
/// The interpreter generates a random number from 0 to 255, which is
/// then ANDed with the value kk. The results are stored in Vx.
/// (0xcxkk)
static inline void rnd_vx_byte(byte x, byte kk) {
  v[x] = ((byte)rand()) & kk;
  pc += 2; 
}

/// Display n-byte sprite starting at memory location I at (Vx, Vy),
/// set VF = collision.
/// The interpreter reads n bytes from memory, starting at the address
/// stored in I. These bytes are then displayed as sprites on screen at
/// coordinates (Vx, Vy). Sprites are XORed onto the existing screen. If
/// this causes any pixels to be erased, VF is set to 1, otherwise 0.
/// (0xdxyn)
static inline void drw_vx_vy_nibble(byte vx, byte vy, byte n) {
  const byte x = v[vx];
  const byte y = v[vy];
  v[0xf] = 0x0;

  for (int it = 0; it < n; it++) {
    const byte sprite = ram[i + it]; 

    for (int jt = 0; jt < 8; jt++) {
      byte bit = 0x80; // 10000000
      bit >>= jt;
      
      if((bit & sprite) != 0x0) {
        const byte x_wrap = (x+jt)%64;
        const byte y_wrap = (y+it)%32;
        const dbyte pos = x_wrap + (y_wrap*64); 
        
        if (display[pos] == 1) 
          v[0xf] = 1;
        display[pos] ^= 1;
      }  
    }  
  }
  pc += 2;
}

/// Skip next instruction if key with the value of Vx is pressed.
/// Checks the keyboard, and if the key corresponding to the value of Vx
/// is currently in the down position, PC is increased by 2.
/// (0xex9e)
static inline void skp_vx(byte x) {
  pc += (keypad[v[x]])? 4 : 2;
}

/// Skip next instruction if key with the value of Vx is not pressed.
///  Checks the keyboard, and if the key corresponding to the value of Vx
/// is currently in the up position, PC is increased by 2.
/// (0xexa1)
static inline void skpn_vx(byte x) {
  pc += (!keypad[v[x]])? 4 : 2;
}

/// Set Vx = delay timer value.
/// The value of DT is placed into Vx.
/// (0xfx07)
static inline void ld_vx_dt(byte x) {
  v[x] = dt;
  pc += 2;
}

/// Wait for a key press, store the value of the key in Vx.
/// All execution stops until a key is pressed, then the value of that
/// key is stored in Vx.
/// (0xfx0a)
static inline void ld_vx_k(byte x) {
  for(byte key = 0x0; key <= 0xf; key++) {
    if(keypad[key] == 1) {
      v[x] = key;
      pc += 2;
      break;
    }
  }
}

/// Wait for a key press, store the value of the key in Vx.
/// All execution stops until a key is pressed, then the value of that
/// key is stored in Vx.
/// (0xfx0a)
static inline void ld_dt_vx(byte x) {
  dt = v[x];
  pc += 2;
}

/// Set sound timer = Vx.
/// ST is set equal to the value of Vx.
/// (0xfx18)
static inline void ld_st_vx(byte x) {
  st = v[x];
  pc += 2;
}

/// Set I = I + Vx.
/// The values of I and Vx are added, and the results are stored in I.
/// (0xfx1e)
static inline void add_i_vx(byte x) {
  i += v[x];
  pc += 2;
}

/// Set I = location of sprite for digit Vx.
/// The value of I is set to the location for the hexadecimal sprite
/// corresponding to the value of Vx.
/// (0xfx29)
static inline void ld_f_vx(byte x) {
  i = 5 * v[x];
  pc += 2;
}

/// Store BCD representation of Vx in memory locations I, I+1, and I+2.
/// The interpreter takes the decimal value of Vx, and places the hundreds
/// digit in memory at location in I, the tens digit at location I+1, and
/// the ones digit at location I+2.
/// (0xfx33)
static inline void ld_b_vx(byte x) {
  const byte val = v[x];
  ram[i] = val/100;
  ram[i+1] = (val/10) % 10;
  ram[i+2] = (val%100) % 10;
  pc += 2;  
}

/// Store registers V0 through Vx in memory starting at location I.
/// The interpreter copies the values of registers V0 through Vx into
/// memory, starting at the address in I.
/// (0xfx55)
static inline void ld_i_vx(byte x) {
  for(byte it = 0x0; it <= x; it++)
    ram[i + it] = v[it];
  pc += 2;
}

/// Read registers V0 through Vx from memory starting at location I.
/// The interpreter reads values from memory starting at location I
/// into registers V0 through Vx.
/// (0xfx65)
static inline void ld_vx_i(byte x) {
  for(byte it = 0x0; it <= x; it++)
    v[it] = ram[i + it];
  pc += 2;
}

void cpu_init(void) {
  // Initialize buffers
  for (int it = 0; it < 16; it++) {
    stack[it] = 0;
    v[it] = 0;
    keypad[it] = 0;
  }

  for (int it = 0; it < 4096; it++)
    ram[it] = 0;
  for (int it = 0; it < 2048; it++)
    display[it] = 0;

  // Initialize registers
  pc = PROG_START;
  i = 0x0;
  dt = 0x0;
  st = 0x0;
  sp = 0x0;

  // Copy the sprites to memory
  for (int i = 0; i < 80; i++)
    ram[i] = sprites[i];

  // For rng
  srand(time(NULL));
}

int cpu_load_rom(const char* path) {
  FILE* file;
  long file_size;
  long result;

  file = fopen(path, "rb");
  if(file == NULL)
    return -1;
  
  fseek(file, 0, SEEK_END);
  file_size = ftell(file);
  rewind(file);

  if(file_size > PROG_MAXLEN)
    return -1;

  result = fread(ram+0x200, sizeof(byte), file_size, file);
  if(result != file_size) {
    fclose(file);
    return -1;
  }

  fclose(file);
  return 0;  
}

void cpu_get_pressed_keys(void) {
  for(byte key = 0x0; key <= 0xf; key++)
    keypad[key] = IsKeyDown(keys[key]);
}

void cpu_exec_cicle(void) {
  // Fetch next instruction and its first nibble
  dbyte opcode = (dbyte)ram[pc];
  opcode <<= 8;
  opcode |= (dbyte) ram[pc+1];
  byte nibble = (opcode&0xf000) >> 12;
  
  switch (nibble) {
    case 0: {
      switch (opcode) {
        case 0x00e0: { cls(); return; }
        case 0x00ee: { ret(); return; }
      }
    }
    case 1: { jp((dbyte)(opcode & 0xfff)); return; }    // 0x1nnn
    case 2: { call((dbyte)(opcode & 0x0fff)); return; } // 0x2nnn
    case 3: { /// 0x3xkk
      se_vx_byte(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)(opcode &0x00ff));
      return;
    }
    case 4: { // 0x4xkk
      sne_vx_byte(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)(opcode & 0x00ff));
      return;
    }
    case 5 : { // 0x5xy0
      se_vx_vy(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)(opcode & 0x00f0) >> 4);
      return;
    }
    case 6: { // 0x6xkk
      ld_vx_byte(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)(opcode & 0x00ff));
      return;
    }
    case 7: { // 0x7xkk
      add_vx_byte(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)(opcode & 0x00ff));
      return;
    }
    case 8: {
      // Get last nibble
      nibble = opcode & 0x000f;
      switch (nibble) {
        case 0: { // 0x 8xy0
          ld_vx_vy(
            (byte)((opcode & 0xf00) >> 8),
            (byte)((opcode & 0x0f0) >> 4));
          return;
        }
        case 1: { // 0x8xy1
          or_vx_vy(
            (byte)((opcode & 0x0f00) >> 8),
            (byte)((opcode & 0x00f0) >> 4));
          return;
        }
        case 2 : { // 0x8xy2
          and_vx_vy(
            (byte)((opcode & 0x0f00) >> 8),
            (byte)((opcode & 0x00f0) >> 4));
          return;
        }
        case 3 : { // 0x8xy3
          xor_vx_vy(
            (byte)((opcode & 0x0f00) >> 8),
            (byte)((opcode & 0x00f0) >> 4));
          return;
        }
        case 4 : { // 0x8xy4
          add_vx_vy(
            (byte)((opcode & 0x0f00) >> 8),
            (byte)((opcode & 0x00f0) >> 4));
          return;
        }
        case 5 : { // 0x8xy5
          sub_vx_vy(
            (byte)((opcode & 0x0f00) >> 8),
            (byte)((opcode & 0x00f0) >> 4));
          return;
        }
        case 6 : { // 0x8xy6
          shr_vx((byte)((opcode & 0x0f00) >> 8));
          return;
        }
        case 7 : { // 0x8xy7
          subn_vx_vy(
            (byte)((opcode & 0x0f00) >> 8),
            (byte)((opcode & 0x00f0) >> 4));
          return;
        }
        case 0xe : { // 0x8xye
          shl_vx((byte)((opcode & 0x0f00) >> 8));
          return;  
        }  
      }
    }
    case 9 : { // 0x9xy0
      sne_vx_vy(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)((opcode & 0x00f0) >> 4));
      return;
    }
    case 0xa : { // 0xannn
      ld_i_addr((dbyte)(opcode & 0x0fff));
      return;
    }
    case 0xb : { // 0xbnnn
      jp_v0_addr((dbyte)(opcode & 0x0fff));
      return;
    }
    case 0xc : { // 0xcxkk
      rnd_vx_byte(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)(opcode & 0x00ff));
      return;
    }
    case 0xd : { // 0xdxyn
      drw_vx_vy_nibble(
        (byte)((opcode & 0x0f00) >> 8),
        (byte)((opcode & 0x00f0) >> 4),
        (byte)(opcode & 0x000f));
      return;
    }
    case 0xe : {
      // Get last 2 nibbles
      nibble = opcode & 0x00ff;
      switch (nibble) {
        case 0x9e : { skp_vx((byte)(opcode & 0x0f00));  return; } // 0xex9e
        case 0xa1 : { skpn_vx((byte)(opcode & 0x0f00)); return; } // 0xexa1
      }
    }
    case 0xf : {
      // Get last 2 nibbles
      nibble = opcode & 0x00ff;
      switch (nibble) {
        case 0x07 : { ld_vx_dt((byte)(opcode & 0x0f00)); return; } // 0xfx07
        case 0x0a : { ld_vx_k((byte)(opcode & 0x0f00));  return; } // 0xfx0a
        case 0x15 : { ld_dt_vx((byte)(opcode & 0x0f00)); return; } // 0xfx15
        case 0x18 : { ld_st_vx((byte)(opcode & 0x0f00)); return; } // 0xfx18
        case 0x1e : { add_i_vx((byte)(opcode & 0x0f00)); return; } // 0xfx1e
        case 0x29 : { ld_f_vx((byte)(opcode & 0x0f00));  return; } // 0xfx29
        case 0x33 : { ld_b_vx((byte)(opcode & 0x0f00));  return; } // 0xfx33
        case 0x55 : { ld_i_vx((byte)(opcode & 0x0f00));  return; } // 0xfx55
        case 0x65 : { ld_vx_i((byte)(opcode & 0x0f00));  return; } // 0xfx65
      }
    }
  }  
}

void cpu_draw_display(void) {
  for (int it = 0; it < 2048; it++) {
    if(display[it])
      DrawRectangle((it%64) * 30, (it/64) * 30, 30, 30, WHITE);
  }
}
