const std = @import("std");
const raylib = @import("raylib");

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

    // Create a new window (64x32 screen)
    raylib.initWindow(800, 450, "raylib-zig [core] example");
    defer raylib.closeWindow();
    raylib.setTargetFPS(60);

    while (!raylib.windowShouldClose()) {
        // Capture the pressed keys

        // Execute the next instruction
        cpu.exec_next_cicle();

        // Draw the screen
        raylib.beginDrawing();
        defer raylib.endDrawing();
        raylib.clearBackground(raylib.Color.white);
    }
}
