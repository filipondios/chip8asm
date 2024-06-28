#include "chip8.h"
#include "raylib.h"
#include <stdio.h>

int main(void) {

  cpu_init();
  if(cpu_load_rom("./roms/UFO") == -1) {
    printf("Could not read ROM\n");
    return -1;
  }

  InitWindow(64 * 30, 32 * 30, "Emulator");
  SetTargetFPS(60);

  while (!WindowShouldClose()) {
    cpu_get_pressed_keys();
    cpu_exec_cicle();

    BeginDrawing();
    ClearBackground(BLACK);
    cpu_draw_display();
    EndDrawing();
  }

  CloseWindow();
  return 0;
}
