#include <raylib.h>
#include <stdio.h>

extern unsigned char cpu_display[2048];
extern unsigned char cpu_v[16];
extern unsigned char cpu_ram[4096];
extern unsigned short cpu_i;
extern unsigned short cpu_pc;
extern unsigned short cpu_stack[16];
extern unsigned char cpu_sp;
extern unsigned char cpu_keypad[16];

void _draw_display(void) {
  for (int it = 0; it < 2048; it++) {
    if(cpu_display[it]){
      DrawRectangle((it%64) * 30, (it/64) * 30, 30, 30, WHITE);
    }
  }
}

void _drw_vx_vy_nibble(unsigned char vx, unsigned char vy, unsigned char n) {
  const unsigned char x = cpu_v[vx];
  const unsigned char y = cpu_v[vy];
  cpu_v[0xf] = 0x0;

  for (int it = 0; it < n; it++) {
    const unsigned char sprite = cpu_ram[cpu_i + it];

    for (int jt = 0; jt < 8; jt++) {
      unsigned char bit = 0x80;
      bit >>= jt;

      if((bit & sprite) != 0x0) {
        const unsigned char x_wrap = (x+jt)%64;
        const unsigned char y_wrap = (y+it)%32;
        const unsigned short pos = x_wrap + (y_wrap*64);

        if (cpu_display[pos] == 1)
          cpu_v[0xf] = 1;
        cpu_display[pos] ^= 1;
      }
    }
  }
  cpu_pc += 2;
}

void printMemory(void) {
  printf("\nStack: ");
  for (int it = 0; it<=0xf; it++)
    printf("%03x ", cpu_stack[it]);
  printf("\n");

  printf("Vreg: ");
  for (int it = 0; it<=0xf; it++)
    printf("%d ", cpu_v[it]);
  printf("\n");

  printf("PC: %04x\n", cpu_pc);
  printf("I: %04x\n", cpu_i);
  printf("SP: %d\n", cpu_sp);
}
