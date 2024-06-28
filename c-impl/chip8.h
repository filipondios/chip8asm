#ifndef _CHIP8_H
#define _CHIP8_H

void cpu_init(void);
int cpu_load_rom(const char* path);
void cpu_get_pressed_keys(void);
void cpu_exec_cicle(void);
void cpu_draw_display(void);

#endif // !_CHIP8_H
