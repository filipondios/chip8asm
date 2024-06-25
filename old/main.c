#include <stdio.h>

unsigned char display[20];


extern void _cls(unsigned char*);



int main(void) {
  
  _cls(display);
  _ret(void);

  for (int i=0; i<20; i++) {
    printf("%d\n", display[i]);
  }
  return 0;
}

