# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-08-02

### Added

- 'Beep' sound when the sound timer is greater than zero.
- Memory information print at every instruction for debug.
- Extern '.c' file for complex functions implementations. 
- Makefile options for debug and release.
- This CHANGELOG file.

### Changed

- Move the delay and sound timers management to a extern '.c' file.
- Change the TODO file format to the specified by [Todo TXT](https://github.com/todotxt/todo.txt)
- The display buffer is painted at each instruction fetch.
- 'ClearBackground' raylib function before painting the display buffer.

### Removed

- 'cpu_draw' flag that indicated whether to redraw the display buffer.

### Fixed

- Delay and sound timers update.
- Pixel overwriting representation at the window.

## [1.0.0] - 2024-07-15

### Added

- Chip-8 Specifications except sound.
- Chip-8 Instructions.
- ROM file loading from parameter.

[2.0.0]: https://github.com/dpv927/chip8asm/tree/v2.0.0
[1.0.0]: https://github.com/dpv927/chip8asm/tree/v1.0.0
