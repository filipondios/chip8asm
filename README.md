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

Se han seguido articulos de referencia como <a href="http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#0.1">Cowgod's Chip-8 Technical Reference</a> and <a href="https://github.com/mattmikolay/chip-8/wiki/Mastering-CHIP%E2%80%908">Mastering CHIP‐8</a>. No obstante,
se han implementado algunas cosas extras que mejoran el rendimiento. Estas son:

- Cuando el valor del stack pointer es 0 (bottom of the stack) y se realiza una operacion de return, el programa finaliza.

- Aunque no es la manera mas correcta, se ha intentado que Raylib haga 60 ciclos del bucle principal por segundo, por lo que
  los timers se actualizarian a su correcta frecuencia (60Hz) pero se ejecutarian mas instrucciones por segundo (lo que no seria
  tan real en una maquina CHIP-8 original).

## Compile

Esta seguro de que tengas <a href="https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux">raylib</a> instalado en tu sistema de manera estatica o dinamica (la segunda opcion se deberia de configurar manualmente por parte del usuario para poder compilar chip8asm).
El interprete esta situado en el directorio src, por lo que bastaria con ejecutar los siguientes comandos:

```bash
cd src/
make
```

## Run

Tras esto, se deberia de haber generado el archivo chip8asm. Ahora puedes ejecutar archivos binarios que contengan programas compatibles
con el conjunto de instrucciones de CHIP-8. Algunos sitios para obtener ROMs son:

- <a href="https://github.com/kripod/chip8-roms">kripod/chip8-roms</a>
- <a href="https://www.zophar.net/pdroms/chip8.html">pdroms</a>
- <a href="https://chipo.ber.gp/">chipo</a>
- <a href="https://johnearnest.github.io/chip8Archive/">johnearnest/chip8Archive</a>

El programa chip8asm toma un solo parametro, que es la ruta relativa o absoluta al archivo ROM que quieras correr. Un ejemplo
de comando seria:

```bash
./chip8asm ./some-directory/rom.ch8
```
