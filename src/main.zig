const std = @import("std");
const chip8cpu = @import("chip8cpu.zig");
const Chip8CPU = chip8cpu.Chip8CPU;

pub fn main() !void {
    var cpu: Chip8CPU = Chip8CPU.init();
    cpu.cls();

    // Load the ROM file to memory
    cpu.loadToROM("/home/tux/chip8/src/stars.bin") catch |err| {
        std.debug.print("ROM could not be loaded: {}", .{err});
        return;
    };

    // Crear ventana raylib
    // bucle:
    //  Cargar cpu.ram[pc] y cpu.ram[pc+1]
    //
}
