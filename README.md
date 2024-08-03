<h1 align="center">
      <img src="https://github.com/dpv927/chip8asm/assets/113710742/8a5c14ea-02cf-479d-b442-98cfc772d235" height="200">
</h1>

<!-- Project Description -->
<h4 align="center">A <a href="https://en.wikipedia.org/wiki/CHIP-8">CHIP-8</a> interpreter written written in x64 Linux <a href="https://www.nasm.us/">NASM</a> assembly and <a href="https://www.raylib.com/">Raylib</a></h4>

<!-- Quick links -->
<p align="center">
  <a href="#about">About</a> •
  <a href="#features">Features</a> •
  <a href="#running">Running</a> •
  <a href="#compiling">Compiling</a> •
  <a href="#todo">TODO</a> •
  <a href="#license">License</a>
</p><br>

## About

This project is a fully-functional interpreter for the CHIP-8 programming 
language, meticulously crafted in assembly language. CHIP-8, originally 
designed in the 1970s, is a simple, "low-level" programming language used for 
creating games on early computer systems. The goal of this interpreter is to 
bring back the nostalgia and charm of CHIP-8, providing a modern implementation
while preserving the essence of the original.

## Features

This interpreter is based on well-documented references, such as 
[Cowgod's Chip-8 Technical Reference] and [Mastering CHIP-8]. In addition to 
faithfully reproducing the CHIP-8 instruction set, several enhancements have 
been made to improve performance:

- **Program termination**: If the stack pointer is at 0 (bottom of the stack) 
and a return operation is executed, the program terminates.

- **Timing**: Raylib has been configured to aim for 60 cycles of the main loop
per second. This ensures that timers update at their correct frequency (60Hz), 
though more instructions per second are executed compared to an original CHIP-8 
machine, offering a smoother experience.

## Running

In order to run a ROM file that contains a CHIP-8 program, you need the 
chip8asm executable to run it. You can obtain it via [compiling](#compiling) 
the project, from the [executable] from any branch of this repository or from 
any of the releases at the [releases page]. After that, you can run CHIP-8 
compatible ROMs using this interpreter. Some sources for ROMs are:

- [kripod/chip8-roms](https://github.com/kripod/chip8-roms)
- [pdroms](https://www.zophar.net/pdroms/chip8.html)
- [chipo](https://chipo.ber.gp)
- [johnearnest/chip8Archive](https://johnearnest.github.io/chip8Archive)

> [!WARNING]  
> Some ROMs from this sites can contain null codes (0x0000) or other unknown 
> ones that for some reason don't exist in any of the references and people 
> count with them. This might cause the program to crash or to freeze itself.

To run a ROM, use the following command, where the parameter is the path to
the ROM file:

```bash
./chip8asm some/directory/to/rom
```

> [!IMPORTANT]
> The program does not care about the file extension (some sites may use 
> *.c8*, *.ch8*, etc), but it checks if the file size is small enough to fit
> inside the read-only segment of the CHIP-8 memory (The maximum file size is
> **3584 (0xE00) bytes**, given by the addresses 0x200 - 0xFFF).

## Compiling

Ensure you have [raylib] installed on your system, either statically or 
dynamically (the latter requiring manual configuration). To compile the 
interpreter, navigate to the src directory and run the following commands:

```bash
git clone https://github.com/dpv927/chip8asm.git
cd chip8asm/src/
make
```

## TODO

See the [TODO file] which contans the current tasks and maybe future features.
The symbol *'x'* at the beggining of a line means that a task is finished. 
*'(A)'*, '*'(B)'*,... means the priority of the task (in alphabetical order),
and *'@'* gives a hint about the task's topic.

## License

Stockfish is free and distributed under the [GNU General Public License version
3 (GPL v3)]. Essentially, this means you are free to do almost exactly what you
want with the program, including distributing it among your friends, making it
available for download from your website, selling it (either by itself or as
part of some bigger software package), or using it as the starting point for a
software project of your own.

The only real limitation is that whenever you distribute Stockfish in some way,
you MUST always include the license and the full source code (or a pointer to
where the source code can be found) to generate the exact binary you are
distributing. If you make any changes to the source code, these changes must 
also be made available under GPL v3.


[Cowgod's Chip-8 Technical Reference]: http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#0.1
[Mastering CHIP-8]: https://github.com/mattmikolay/chip-8/wiki/Mastering-CHIP%E2%80%908
[compiling]: #compile
[executable]: bin/chip8asm
[releases page]: https://github.com/dpv927/chip8asm/releases
[raylib]: https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux
[TODO file]: TODO.txt
[GNU General Public License version 3 (GPL v3)]: LICENSE
