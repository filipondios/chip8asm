#include<assert.h>
#include <stdio.h>
#include <string.h>

unsigned char cpu_v[16];
unsigned char cpu_display[2048];
unsigned char cpu_sp;
unsigned short cpu_pc;
unsigned char cpu_draw;
unsigned short cpu_stack[16];
unsigned short cpu_i;
unsigned char cpu_keypad[16];
unsigned char cpu_dt;
unsigned char cpu_st;
unsigned char cpu_ram[4096];

static const unsigned char sprites[80] = {
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

extern void _cls(void);
extern void _ret(void);
extern void _jp_addr(unsigned short);
extern void _call_addr(unsigned short);
extern void _se_vx_byte(unsigned char, unsigned char);
extern void _sne_vx_byte(unsigned char, unsigned char);
extern void _se_vx_vy(unsigned char, unsigned char);
extern void _ld_vx_byte(unsigned char, unsigned char);
extern void _add_vx_byte(unsigned char, unsigned char);
extern void _ld_vx_vy(unsigned char, unsigned char);
extern void _or_vx_vy(unsigned char, unsigned char);
extern void _and_vx_vy(unsigned char, unsigned char);
extern void _xor_vx_vy(unsigned char, unsigned char);
extern void _add_vx_vy(unsigned char, unsigned char);
extern void _sub_vx_vy(unsigned char, unsigned char);
extern void _shr_vx(unsigned char);
extern void _subn_vx_vy(unsigned char, unsigned char);
extern void _shl_vx(unsigned char);
extern void _sne_vx_vy(unsigned char, unsigned char);
extern void _ld_i_addr(unsigned short);
extern void _jp_v0_addr(unsigned short);
extern void _rnd_vx_byte(unsigned char, unsigned char);
extern void _drw_vx_vy_nibble(unsigned char, unsigned char, unsigned char);
extern void _skp_vx(unsigned char);
extern void _sknp_vx(unsigned char);
extern void _ld_vx_dt(unsigned char);
extern void _ld_vx_k(unsigned char);
extern void _ld_dt_vx(unsigned char);
extern void _ld_st_vx(unsigned char);
extern void _add_i_vx(unsigned char);
extern void _ld_f_vx(unsigned char);
extern void _ld_b_vx(unsigned char);
extern void _ld_i_vx(unsigned char);
extern void _ld_vx_i(unsigned char);

#define TEST(func) void test_##func(void)
#define RUN_TEST(func) test_##func();

TEST(cls) {
  unsigned char buff[2048];
  memset(buff, 0, sizeof(buff));
  memset(cpu_display, 33, sizeof(cpu_display));

  cpu_pc = 0x202;
  cpu_draw = 0;
  _cls();

  assert(memcmp(cpu_display, buff, 2048) == 0);
  assert(cpu_draw != 0);
  assert(cpu_pc == (0x202 + 2));
}

TEST(ret) {
  memset(cpu_stack, 0, sizeof(cpu_stack));
  cpu_pc = 0x220;
  cpu_sp = 2;
  cpu_stack[0] = 0x310;
  
  _ret();
  assert(cpu_pc == (0x310 + 2));
  assert(cpu_sp == 0);
}

TEST(jp_addr) {
  cpu_pc = 0x310;
  _jp_addr(0x512);
  assert(cpu_pc == 0x512);
}

TEST(call_addr) {
  memset(cpu_stack, 0, sizeof(cpu_stack));
  cpu_pc = 0x412;
  cpu_sp = 4;

  _call_addr(0x210);
  assert(cpu_stack[2] == 0x412);
  assert(cpu_sp == 6);
  assert(cpu_pc == 0x210);
}

TEST(se_vx_byte) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x214;
  cpu_v[2] = 21;

  _se_vx_byte(2, 21);
  assert(cpu_pc == (0x214 + 4));
  cpu_pc = 0x214;

  _se_vx_byte(1, 13);
  assert(cpu_pc == (0x214 + 2));  
}

TEST(sne_vx_byte) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x214;
  cpu_v[2] = 21;

  _sne_vx_byte(2, 21);
  assert(cpu_pc == (0x214 + 2));
  cpu_pc = 0x214;

  _sne_vx_byte(1, 13);
  assert(cpu_pc == (0x214 + 4)); 
}

TEST(se_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x214;
  cpu_v[0] = 13;
  cpu_v[1] = 13;

  _se_vx_vy(0, 1);
  assert(cpu_pc == (0x214 + 4));
  cpu_pc = 0x214;

  _se_vx_vy(0, 6);
  assert(cpu_pc == (0x214 + 2));
}

TEST(ld_vx_byte) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x222;
  cpu_v[11] = 21;
  
  _ld_vx_byte(11, 0x13);
  assert(cpu_v[11] == 0x13);
  assert(cpu_pc == (0x222 + 2)); 
}

TEST(add_vx_byte) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x314;
  cpu_v[9] = 33;

  _add_vx_byte(9, 134);
  assert(cpu_v[9] == 167);
  assert(cpu_pc == (0x314 + 2));

  _add_vx_byte(9, 100);
  // Try overflow
  assert(cpu_v[9] == 11);
}

TEST(ld_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x222;
  cpu_v[2] = 98;
  cpu_v[5] = 67;

  _ld_vx_vy(2,5);
  assert(cpu_v[2] == 67);
  assert(cpu_pc == (0x222 + 2));
}

TEST(or_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x314;
  cpu_v[0] = 12;
  cpu_v[1] = 111;
  cpu_v[0xf] = 1;

  _or_vx_vy(0, 1);
  assert(cpu_v[0] == (12|111));
  assert(cpu_v[0xf] == 0);
  assert(cpu_pc == (0x314 + 2));
}

TEST(and_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x314;
  cpu_v[0] = 12;
  cpu_v[1] = 111;
  cpu_v[0xf] = 1;

  _and_vx_vy(0, 1);
  assert(cpu_v[0] == (12&111));
  assert(cpu_v[0xf] == 0);
  assert(cpu_pc == (0x314 + 2));
}

TEST(xor_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x314;
  cpu_v[0] = 12;
  cpu_v[1] = 111;
  cpu_v[0xf] = 1;

  _xor_vx_vy(0, 1);
  assert(cpu_v[0] == (12^111));
  assert(cpu_v[0xf] == 0);
  assert(cpu_pc == (0x314 + 2));
}

TEST(add_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x422;
  cpu_v[0] = 89;
  cpu_v[1] = 200;

  _add_vx_vy(0, 1);
  // Try overflow
  assert(cpu_v[0] == 33);
  assert(cpu_v[0xf] == 1);
  assert(cpu_pc == (0x422 + 2));

  cpu_v[0] = 55;
  cpu_v[1] = 14;

  _add_vx_vy(0, 1);
  assert(cpu_v[0] == 69);
  assert(cpu_v[0xf] == 0);
}

TEST(sub_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x422;
  cpu_v[0] = 89;
  cpu_v[1] = 200;

  _sub_vx_vy(0, 1);
  // Try overflow
  assert(cpu_v[0] == (unsigned char)(89-200));
  assert(cpu_v[0xf] == 1);
  assert(cpu_pc == (0x422 + 2));

  cpu_v[0] = 55;
  cpu_v[1] = 14;

  _sub_vx_vy(0, 1);
  assert(cpu_v[0] == 41);
  assert(cpu_v[0xf] == 0);
}

TEST(shr_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x232;
  cpu_v[0] = 12;

  _shr_vx(0);
  assert(cpu_v[0] == 6);

  cpu_v[0] = 1;
  _shr_vx(0);
  assert(cpu_v[0] == 0);
}

TEST(subn_vx_vy) {
    memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x422;
  cpu_v[0] = 200;
  cpu_v[1] = 89;

  _subn_vx_vy(0, 1);
  // Try overflow
  assert(cpu_v[0] == (unsigned char)(89-200));
  assert(cpu_v[0xf] == 0);
  assert(cpu_pc == (0x422 + 2));

  cpu_v[0] = 14;
  cpu_v[1] = 55;

  _subn_vx_vy(0, 1);
  assert(cpu_v[0] == 41);
  assert(cpu_v[0xf] == 1);
}

TEST(shl_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x232;
  cpu_v[0] = 12;

  _shl_vx(0);
  assert(cpu_v[0] == 24);

  cpu_v[0] = 128;
  _shl_vx(0);
  assert(cpu_v[0] == 0);
}

TEST(sne_vx_vy) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x214;
  cpu_v[0] = 13;
  cpu_v[1] = 13;

  _sne_vx_vy(0, 1);
  assert(cpu_pc == (0x214 + 2));
  cpu_pc = 0x214;

  _sne_vx_vy(0, 6);
  assert(cpu_pc == (0x214 + 4));
}

TEST(ld_i_addr) {
  cpu_i = 0x212;
  cpu_pc = 0x112;

  _ld_i_addr(0x442);
  assert(cpu_i == 0x442);
  assert(cpu_pc == (0x112 + 2));
}

TEST(jp_v0_addr) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_v[0] = 12;
  cpu_pc = 0x204;

  _jp_v0_addr(0x212);
  assert(cpu_pc == (0x212 + 12));
}

TEST(rnd_vx_byte) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x332;

  _rnd_vx_byte(0, 111);
  // cant predict random
  assert(cpu_pc == (0x332 + 2));
}

TEST(drw_vx_vy_nibble) {
  memcpy(cpu_ram, sprites, sizeof(sprites));
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x222;
  cpu_draw = 0;
  cpu_i = 0x0;

  _drw_vx_vy_nibble(3,3,5);
  for(int i=0; i < 2048; i++){
    if((i % 64 == 0) && (i != 0))
      printf("\n");
    printf("%d", cpu_display[i]);
  }
  printf("\n\n");

  _drw_vx_vy_nibble(3,3,5);
  for(int i=0; i < 2048; i++){
    if((i % 64 == 0) && (i != 0))
      printf("\n");
    printf("%d", cpu_display[i]);
  }

  printf("\n");
  assert(cpu_v[0xf] == 1);
  assert(cpu_pc == (0x222 + 4));
}

TEST(skp_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  memset(cpu_keypad, 0, sizeof(cpu_keypad));
  cpu_pc = 0x112;
  cpu_v[2] = 0xe;
  cpu_keypad[0xe] = 1;

  _skp_vx(2);
  assert(cpu_pc == (0x112 + 4));
  _skp_vx(4);
  assert(cpu_pc == (0x112 + 6));
}

TEST(sknp_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  memset(cpu_keypad, 0, sizeof(cpu_keypad));
  cpu_pc = 0x112;
  cpu_v[2] = 0xe;
  cpu_keypad[0xe] = 1;

  _sknp_vx(2);
  assert(cpu_pc == (0x112 + 2));
  _sknp_vx(4);
  assert(cpu_pc == (0x112 + 6));

}

TEST(ld_vx_dt) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_pc = 0x210;
  cpu_dt = 90;

  _ld_vx_dt(0);
  assert(cpu_v[0] == 90);
  assert(cpu_pc == (0x210 + 2));
}

TEST(ld_vx_k) {
  memset(cpu_v, 0, sizeof(cpu_v));
  memset(cpu_keypad, 0, sizeof(cpu_keypad));
  cpu_v[0] = 36;
  cpu_pc = 0x212;

  _ld_vx_k(0);
  assert(cpu_v[0] == 36);
  assert(cpu_pc == 0x212);

  cpu_keypad[3] = 1;
  _ld_vx_k(0);
  assert(cpu_v[0] == 3);
  assert(cpu_pc == (0x212 + 2));
}

TEST(ld_dt_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_dt = 212;
  cpu_v[0] = 78;
  cpu_pc = 0x364;

  _ld_dt_vx(0);
  assert(cpu_dt == 78);
  assert(cpu_pc == (0x364 + 2));  
}

TEST(ld_st_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_st = 212;
  cpu_v[0] = 22;
  cpu_v[10] = 11;
	cpu_pc = 0x312;

  _ld_st_vx(0);
  assert(cpu_st == 22);
  assert(cpu_pc == (0x312 + 2));  

	_ld_st_vx(10);
	assert(cpu_st == 11);
  assert(cpu_pc == (0x312 + 4));  
}

TEST(add_i_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_v[5] = 134;
  cpu_i = 0xff1;
  cpu_pc = 0x222;

  _add_i_vx(5);
  assert(cpu_i == (unsigned short)(0xff1+134));
  assert(cpu_v[0xf] == 1);
  assert(cpu_pc == (0x222 + 2));

  cpu_i = 234;
  _add_i_vx(0);
  assert(cpu_i == 234);
  assert(cpu_v[0xf] == 0);
}

TEST(ld_f_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  cpu_v[4] = 0xc;
  cpu_pc = 0x222;
  cpu_i = 0x112;

  _ld_f_vx(4);
  assert(cpu_i == (0xc * 5));
  assert(cpu_pc == (0x222 + 2));
}

TEST(ld_b_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  memset(cpu_ram, 0, sizeof(cpu_ram));
  cpu_v[2] = 123;
  cpu_pc = 0x452;
  cpu_i = 258;

  _ld_b_vx(2);
  assert(cpu_ram[258] == 1);
  assert(cpu_ram[259] == 2);
  assert(cpu_ram[260] == 3);
  assert(cpu_pc == (0x452 + 2));
}

TEST(ld_i_vx) {
  memset(cpu_v, 0, sizeof(cpu_v));
  memset(cpu_ram, 0, sizeof(cpu_ram));
  cpu_i = 0x212;
  
  for (int i = 0x212, j =0; i <= 0x212+5; i++, j++)
    cpu_ram[i] = j;  

  _ld_i_vx(5);
  assert(memcmp(cpu_v, cpu_ram+0x212, 5) == 0);
}

TEST(ld_vx_i) {
  memset(cpu_v, 0, sizeof(cpu_v));
  memset(cpu_ram, 0, sizeof(cpu_ram));
  cpu_i = 0x290;
  
  for (int i = 0; i < 5; i++)
    cpu_v[i] = i;  

  _ld_vx_i(5);
  assert(memcmp(cpu_v, cpu_ram+0x290, 5) == 0);
}

int main() {
  RUN_TEST(cls);
  RUN_TEST(ret);
  RUN_TEST(jp_addr);
  RUN_TEST(call_addr);
  RUN_TEST(se_vx_byte);
  RUN_TEST(sne_vx_byte);
  RUN_TEST(se_vx_vy);
  RUN_TEST(ld_vx_byte);
  RUN_TEST(add_vx_byte);
  RUN_TEST(ld_vx_vy);
  RUN_TEST(or_vx_vy);
  RUN_TEST(and_vx_vy);
  RUN_TEST(xor_vx_vy);
  RUN_TEST(add_vx_vy);
  RUN_TEST(sub_vx_vy);
  RUN_TEST(shr_vx);
  RUN_TEST(subn_vx_vy);
  RUN_TEST(shl_vx);
  RUN_TEST(sne_vx_vy);
  RUN_TEST(ld_i_addr);
  RUN_TEST(jp_v0_addr);
  RUN_TEST(rnd_vx_byte);
  RUN_TEST(drw_vx_vy_nibble);
  RUN_TEST(skp_vx);
  RUN_TEST(sknp_vx);
  RUN_TEST(ld_vx_dt);
  RUN_TEST(ld_vx_k);
  RUN_TEST(ld_dt_vx);
  RUN_TEST(ld_st_vx);
  RUN_TEST(add_i_vx);
  RUN_TEST(ld_f_vx);
  RUN_TEST(ld_b_vx);
  RUN_TEST(ld_i_vx);
  RUN_TEST(ld_vx_i);
  printf("All tests passed.");
  return 0;
}
