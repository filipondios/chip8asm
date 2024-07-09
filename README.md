<h1 align="center">
      <img src="https://github.com/dpv927/chip8asm/assets/113710742/8a5c14ea-02cf-479d-b442-98cfc772d235" height="200">
</h1>

<!-- Project Description -->
<h4 align="center">A <a href="https://en.wikipedia.org/wiki/CHIP-8">CHIP-8</a> interpreter written written in x64 Linux <a href="https://www.nasm.us/">NASM</a> assembly and <a href="https://www.raylib.com/">Raylib</a></h4>

<!-- Quick links -->
<p align="center">
  <a href="#about">About</a> •
  <a href="#features">Features</a> •
  <a href="#features">Compile</a> •
  <a href="#run">Run</a> •
  <a href="#todo-list">TODO List</a>
</p><br>

## About

This project is a fully-functional interpreter for the CHIP-8 programming language,
meticulously crafted in assembly language. CHIP-8, originally designed in the 1970s,
is a simple, "low-level" programming language used for creating games on early
computer systems. The goal of this interpreter is to bring back the nostalgia 
and charm of CHIP-8, providing a modern implementation while preserving the 
essence of the original.

## Features

This interpreter is based on well-documented references, such as 
<a href="http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#0.1">Cowgod's Chip-8 Technical Reference</a>
and <a href="https://github.com/mattmikolay/chip-8/wiki/Mastering-CHIP%E2%80%908">Mastering CHIP‐8</a>.
In addition to faithfully reproducing the CHIP-8 instruction set, several 
enhancements have been made to improve performance:

- Program termination: If the stack pointer is at 0 (bottom of the stack) and a 
return operation is executed, the program terminates.

- Timing: Raylib has been configured to aim for 60 cycles of the main loop per 
second. This ensures that timers update at their correct frequency (60Hz), 
though more instructions per second are executed compared to an original CHIP-8 
machine, offering a smoother experience.

## Compile

Ensure you have <a href="https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux">Raylib</a>
installed on your system, either statically or dynamically (the latter requiring 
manual configuration). To compile the interpreter, navigate to the src directory 
and run the following commands:

```bash
cd src/
make
```

## Run

After compilation, the `chip8asm` executable will be generated. You can run CHIP-8
compatible ROMs using this interpreter. Some sources for ROMs are:

- <a href="https://github.com/kripod/chip8-roms">kripod/chip8-roms</a>
- <a href="https://www.zophar.net/pdroms/chip8.html">pdroms</a>
- <a href="https://chipo.ber.gp/">chipo</a>
- <a href="https://johnearnest.github.io/chip8Archive/">johnearnest/chip8Archive</a>

To run a ROM, use the following command, where the parameter is the path to
the ROM file:

```bash
./chip8asm ./some-directory/rom.ch8
```

## TODO List

There are some features missing at the current program:

- "Beep" sound implementation when the sound timer is activated.
- Improvement of the instruction decoding/execution.
- Develop a graphical user interface for easier ROM selection and execution.
