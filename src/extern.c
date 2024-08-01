#include <raylib.h>

#ifdef INSTALLED
/* This path is only used when the purpose of the 
 * compilation is to install the program. */
#define SOUND_PATH "/usr/share/chip8asm/beep.wav"
#else
#define SOUND_PATH "./resources/beep.wav"
#endif

extern unsigned char cpu_st;
extern unsigned char cpu_dt;
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
	PlaySound(beep_sound);
	CloseAudioDevice();
}

void updateST(void) {
	// Update sound timer
	if(cpu_st) { 
		cpu_st--;
		PlaySound(beep_sound);
	}
}

void updateDT(void) {
	// Update Delay Timer
	if(cpu_dt) 
		cpu_dt--;	
}

/*
void manageTimers(void) {
	// One process will update the timers (delay and
	// sound timers) at a 60Hz frequency.
	// We will use the child process to do so.
	const double freq = (double)1.0/60;

	struct timespec ts;
	ts.tv_sec = freq;
	ts.tv_nsec = (long)((freq - ts.tv_sec)*1e9);

	while(1) {
		if(cpu_dt) { cpu_dt--; }	
		if(cpu_st) { cpu_st--; PlaySound(beep_sound); }
		nanosleep(&ts, NULL);
	}
}*/
