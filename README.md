# Chip8ASM

This project is a fully-functional interpreter for the [CHIP-8](https://en.wikipedia.org/wiki/CHIP-8) 
programming language, written in x64 Linux [NASM](https://www.nasm.us/) assembly and using 
[Raylib](https://www.raylib.com/) to render the CHIP-8's screen. CHIP-8, originally designed in the 
1970s, is a simple, "low-level" programming language used for creating games on early computer systems.

## Features

This interpreter is based on well-documented references, such as 
[Cowgod's Chip-8 Technical Reference] and [Mastering CHIP-8]. For testing, 
several [test files] have been created for the basic functionality of the
iterpreter and the opcodes. In addition, we have run and passed all the 
tests of the [chip8-test-suite], which do a more exhaustive testing of the
opcodes. Also, a few enhancements have been made to provide a better experience:

- ``Timing``: Raylib has been configured to aim for 200 FPS, which means that
200 instructions are executed per second, but also managing to update timers
update at their correct frequency (60Hz). This is done with the intention of
providing a smoother user experience.

- ``Sound``: This interpreter has sound support for programs that use the delay
timer to play the CHIP-8 *beep* sound. This sound has been generated thanks to
[onlinetonegenerator.com] using a 440Hz frequency and a square wave.

## Run CHIP-8 ROMs

In order to run a ROM file that contains a CHIP-8 program, you need the 
chip8asm executable to run it. You can obtain it via [compiling](#compile) 
the project and [installing](#install) it, or from any of the releases at the 
[releases page]. After that, you can run CHIP-8 compatible ROMs using this
interpreter. Some sources for ROMs are: [kripod/chip8-roms](https://github.com/kripod/chip8-roms),
[pdroms](https://www.zophar.net/pdroms/chip8.html), [chipo](https://chipo.ber.gp) and
[johnearnest/chip8Archive](https://johnearnest.github.io/chip8Archive)

To run a ROM, use the following command, where the parameter is the path to
the ROM file:

```bash
./chip8asm some/path/to/rom # Relative path (not installed)
chip8asm some/path/to/rom   # Global path (installed)
```

> [!IMPORTANT]
> The program does not care about the file extension (some sites may use 
> *.c8*, *.ch8*, etc), but it checks if the file size is small enough to fit
> inside the read-only segment of the CHIP-8 memory (The maximum file size is
> **3584 (0xE00) bytes**, given by the addresses 0x200 - 0xFFF).

## How to compile this project

Ensure you have [raylib] and [nasm] installed on your system, either statically or 
dynamically (the last one requires manual configuration). To compile the 
interpreter, follow the commands below:

```bash
git clone https://github.com/dpv927/chip8asm.git
cd chip8asm/src/
make target
```

> [!NOTE]  
> You can now run the executable. However, if you move it to another directory, you'll
> need to relocate the resources folder to the same directory as the executable to ensure
> sound functionality. To avoid this hassle, consider [installing](#install) the program.

## How to install chip8asm

If you compiled the project, now you just have to run one command:
```bash
sudo make install
```

If you downloaded the interpreter from some of the releases, you just need to move the
necessary files to the system path (This assumes that you are inside of the downloaded
release folder):
```bash
sudo cp -f chip8asm /usr/local/bin
sudo chmod 755 /usr/local/bin/chip8asm
sudo mkdir -p /usr/share/chip8asm
sudo cp -f resources/beep.wav /usr/share/chip8asm
```

## How to uninstall chip8asm 
Of course, you can remove the project from the system path. Just undo the steps 
from the [installation](#install) guide:
```bash
sudo rm /local/bin/chip8asm
sudo rm -rf /usr/share/chip8asm
```

## TODO

See the [TODO file] which contans the current tasks and maybe future features.
The symbol *'x'* at the beggining of a line means that a task is finished. 
*'(A)'*, *'(B)'*,... means the priority of the task (in alphabetical order),
and *'@'* gives a hint about the task's topic.

## License

Chip8asm is free and distributed under the [GNU General Public License version
3 (GPL v3)]. Essentially, this means you are free to do almost exactly what you
want with the program, including distributing it among your friends, making it
available for download from your website, selling it (either by itself or as
part of some bigger software package), or using it as the starting point for a
software project of your own.

The only real limitation is that whenever you distribute Chip8asm in some way,
you MUST always include the license and the full source code (or a pointer to
where the source code can be found) to generate the exact binary you are
distributing. If you make any changes to the source code, these changes must 
also be made available under GPL v3.


[Cowgod's Chip-8 Technical Reference]: http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#0.1
[Mastering CHIP-8]: https://github.com/mattmikolay/chip-8/wiki/Mastering-CHIP%E2%80%908
[test files]: src/tests
[chip8-test-suite]: https://github.com/Timendus/chip8-test-suite
[onlinetonegenerator.com]: https://onlinetonegenerator.com
[executable]: bin/chip8asm
[releases page]: https://github.com/dpv927/chip8asm/releases
[raylib]: https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux
[nasm]: https://www.nasm.us/
[beep sound file]: src/resources/beep.wav
[TODO file]: TODO.txt
[GNU General Public License version 3 (GPL v3)]: LICENSE
