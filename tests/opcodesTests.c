#include<assert.h>
#include <stdint.h>

unsigned char cpu_v[16] = {1, 2, 3,4,5,6,7,8,9,10,11,12,13,14,15, 16};
unsigned char cpu_display[2048];
unsigned char cpu_sp;
unsigned short cpu_pc = 0x230;
unsigned char cpu_draw;
unsigned short cpu_stack[16];
unsigned short cpu_i = 0;
unsigned char cpu_keypad[16] = {0,1,0};
unsigned char cpu_dt = 42;
unsigned char cpu_st = 51;
unsigned char cpu_ram[4096] = {13,11,34,77};

// extern void _cls(void);
// extern void _ret(void);
// extern void _jp_addr(unsigned short);
// extern void _call_addr(unsigned short);
// extern void _se_vx_byte(unsigned char, unsigned char);
// extern void _sne_vx_byte(unsigned char, unsigned char);
// extern void _se_vx_vy(unsigned char, unsigned char);
// extern void _ld_vx_byte(unsigned char, unsigned char);
// extern void _add_vx_byte(unsigned char, unsigned char);
// extern void _ld_vx_vy(unsigned char, unsigned char);
// extern void _or_vx_xy(unsigned char, unsigned char);
// extern void _and_vx_xy(unsigned char, unsigned char);
// extern void _xor_vx_xy(unsigned char, unsigned char);
// extern void _add_vx_vy(unsigned char, unsigned char);
// extern void _sub_vx_vy(unsigned char, unsigned char);
// extern void _shr_vx(unsigned char);
// extern void _subn_vx_vy(unsigned char, unsigned char);
// extern void _shl_vx(unsigned char);
// extern void _sne_vx_vy(unsigned char, unsigned char);
// extern void _ld_i_addr(unsigned short);
// extern void _jp_v0_addr(unsigned short);
// extern void _rnd_vx_byte(unsigned char, unsigned char);
// extern void _drw_vx_vy_nibble(unsigned char, unsigned char, unsigned char);
// extern void _skp_vx(unsigned char);
// extern void _sknp_vx(unsigned char);
// extern void _ld_vx_dt(unsigned char);
// extern void _ld_vx_k(unsigned char);
// extern void _ld_dt_vx(unsigned char);
// extern void _ld_st_vx(unsigned char);
// extern void _add_i_vx(unsigned char);
// extern void _ld_f_vx(unsigned char);
// extern void _ld_b_vx(unsigned char);
//extern void _ld_i_vx(unsigned char);
// extern void _ld_vx_i(unsigned char);

#define TEST(func) void test_##func(void)
#define RUN_TEST(func) test_##func();

int main() {
  return 0;
}
