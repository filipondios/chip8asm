#include<assert.h>

unsigned char cpu_v[16];
unsigned char cpu_display[2048];
unsigned char cpu_sp; 
unsigned short cpu_pc;
unsigned char cpu_draw;
unsigned short cpu_stack[16];

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
extern void _or_vx_xy(unsigned char, unsigned char);
extern void _and_vx_xy(unsigned char, unsigned char);
extern void _xor_vx_xy(unsigned char, unsigned char);
extern void _add_vx_vy(unsigned char, unsigned char);
extern void _sub_vx_vy(unsigned char, unsigned char);
extern void _shr_vx(unsigned char);
extern void _subn_vx_vy(unsigned char, unsigned char);
extern void _shl_vx(unsigned char);

#define TEST(func) void test_##func(void)
#define RUN_TEST(func) test_##func();

TEST(cls) {
  for (int i = 0; i < 2048; i++)
    cpu_display[i] = 33;
  _cls();
  for (int i = 0; i < 2048; i++)
    assert(cpu_display[i] == 0);
}

TEST(ret){}
TEST(jp_addr){}
TEST(call_addr){}
TEST(se_vx_byte){}
TEST(sne_vx_byte){}
TEST(se_vx_vy){}
TEST(ld_vx_byte){}
TEST(add_vx_byte){}
TEST(ld_vx_vy){}
TEST(or_vx_xy){}
TEST(and_vx_xy){}
TEST(xor_vx_xy){}
TEST(add_vx_vy){}
TEST(sub_vx_vy){}
TEST(shr_vx){}
TEST(subn_vx_vy){}
TEST(shl_vx){}

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
  RUN_TEST(or_vx_xy);
  RUN_TEST(and_vx_xy);
  RUN_TEST(xor_vx_xy);
  RUN_TEST(add_vx_vy);
  RUN_TEST(sub_vx_vy);
  RUN_TEST(shr_vx);
  RUN_TEST(subn_vx_vy);
  RUN_TEST(shl_vx);
  return 0;
}
