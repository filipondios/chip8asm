#include <float.h>
#include <raylib.h>
#include <time.h>

#ifdef INSTALL
/* This path is only used when the purpose of the 
 * compilation is to install the program. */
#define SOUND_PATH "/usr/share/chip8asm/beep.wav"
#else
#define SOUND_PATH "./resources/beep.wav"
#endif

#ifdef DEBUG
#include <stdio.h>
extern unsigned char cpu_display[2048];
extern unsigned short cpu_stack[16];
extern unsigned char cpu_v[16];
extern unsigned short cpu_i;
extern unsigned short cpu_pc;
extern unsigned char cpu_sp;
#endif
extern unsigned char cpu_dt;
extern unsigned char cpu_st;
extern unsigned int win_fps;
double updateCounter = 0;
Sound beep_sound;

void loadBeepSound(void) {
  // Because LoadSound returns the struct as a value and
  // not a pointer, its worse to handle its return value 
  // in assembly. Thats because we do this silly 'interface'
  // in c. Maybe in future versions this is solved.
  InitAudioDevice();
  beep_sound = LoadSound(SOUND_PATH);
}

void unloadBeepSound(void) {
  // More struct value as parameter
  UnloadSound(beep_sound);
  CloseAudioDevice();
}

void updateTimers(void) {
  updateCounter++;

  // Try to update at a 60Hz rate
  if(updateCounter >= (win_fps/60.0)){
    // Update sound timer
    if(cpu_st) { 
      cpu_st--;
      if(!IsSoundPlaying(beep_sound))
        PlaySound(beep_sound);
    } else {
      if(IsSoundPlaying(beep_sound))
        StopSound(beep_sound);
    }
    // Update Delay Timer
    if(cpu_dt > 0) 
      cpu_dt--;
    // Reset counter
    updateCounter = 0;
  }
}

void adaptScaleToScreen(void) {
  const int monitor = GetCurrentMonitor();
  const int m_width = GetMonitorWidth(monitor);
  const int m_height = GetMonitorHeight(monitor);
  int scale = 1;
  
  // Adjust the scale to fit the half
  // of the screen.
  const int max_width = m_width >> 1;
  while(scale * 64 < max_width)
    scale++;
  
  // Set window the new scale and center it
  int win_w, win_h;
  SetWindowSize(win_w = 64 * scale, win_h = 32 * scale);
  SetWindowPosition((m_width - win_w)/2, (m_height - win_h)/2);    
}

#ifdef DEBUG
void printMemory(void) {
  printf("\n\nDisplay:\n");
  for(int i=0; i < 2048; i++){
    if((i % 64 == 0) && (i != 0))
      printf("\n");
    printf("%d", cpu_display[i]);
  }

  printf("\nStack: ");
  for(int i = 0; i < 16; i++)
    printf("0x%0x4 ", cpu_stack[i]);

  printf("\nRegisters: ");
  for(int i = 0; i < 16; i++)
    printf("%d ", cpu_v[i]);

  printf("\ni:  %0x4", cpu_i);
  printf("\ndt: %d", cpu_dt);
  printf("\nst: %d", cpu_st);
  printf("\npc: %0x4", cpu_pc);
  printf("\nsp: %d", cpu_sp);
}
#endif
