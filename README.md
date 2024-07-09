<h1 align="center">
      <img src="https://github.com/dpv927/chip8asm/assets/113710742/8a5c14ea-02cf-479d-b442-98cfc772d235" height="250">
</h1>

<!-- Project Description -->
<h4 align="center">A <a href="https://en.wikipedia.org/wiki/CHIP-8">CHIP-8</a> interpreter written written in x64 Linux <a href="https://www.nasm.us/">NASM</a> assembly and <a href="https://www.raylib.com/">Raylib</a></h4>

<!-- Quick links -->
<p align="center">
  <a href="#about">About</a> •
  <a href="#features">Features</a> •
  <a href="#features">Compile</a> •
  <a href="#Run">Run</a>
  <a href="#todo-list">TODO List</a>
</p><br>

## About

This project is a fully-functional interpreter for the CHIP-8 programming language, meticulously crafted in assembly language. CHIP-8, originally designed in the 1970s, is a simple, "low-level" programming language used for creating games on early computer systems. The goal of this interpreter is to bring back the nostalgia and charm of CHIP-8.

## Features

Reference articles have been followed, such as <a href="http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#0.1">Cowgod's Chip-8 Technical Reference</a> and <a href="https://github.com/mattmikolay/chip-8/wiki/Mastering-CHIP%E2%80%908">Mastering CHIP‐8</a>. However, some extra things have been implemented that improve performance. These are:

- When the value of the stack pointer is 0 (bottom of the stack) and a return operation is performed, the program terminates.

- Although it is not the most correct way, I have tried to make Raylib do 60 cycles of the main loop per second, so the timers would be updated at their correct frequency (60Hz) but more instructions will be executed per second.
  (which would not be as realistic on a CHIP machine).

## Compile

Make sure you have <a href="https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux">raylib</a> installed on your system statically or dynamically (the second option should be configured manually by the user in order to compile chip8asm).
The interpreter is located in the src directory, so just run the following commands:

```bash
cd src/
make
```

## Run

After this, the chip8asm file should have been generated. Now you can run binary files containing programs compatible with the CHIP-8 instruction set.
with the CHIP-8 instruction set. Some sites to obtain ROMs are:

- <a href="https://github.com/kripod/chip8-roms">kripod/chip8-roms</a>
- <a href="https://www.zophar.net/pdroms/chip8.html">pdroms</a>
- <a href="https://chipo.ber.gp/">chipo</a>
- <a href="https://johnearnest.github.io/chip8Archive/">johnearnest/chip8Archive</a>

The chip8asm program takes only one parameter, which is the relative or absolute path to the ROM file you want to run. An example
command would be:

```bash
./chip8asm ./some-directory/rom.ch8
```
