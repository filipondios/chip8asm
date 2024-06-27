const std = @import("std");
const raylib = @import("raylib");

const chip8cpu = @import("chip8cpu.zig");
const Chip8CPU = chip8cpu.Chip8CPU;

pub fn main() !void {
    // Create a new instance
    var cpu: Chip8CPU = Chip8CPU.init();

    // Load the ROM file to memory
    cpu.loadToROM("/home/tux/chip8/src/program.c8") catch |err| {
        std.debug.print("ROM could not be loaded: {}", .{err});
        return;
    };

    // Create a new window (64x32 screen)
    raylib.initWindow(64 * 30, 32 * 30, "raylib-zig [core] example");
    defer raylib.closeWindow();
    raylib.setTargetFPS(20);

    while (!raylib.windowShouldClose()) {
        // Capture the pressed keys
        cpu.get_pressed_keys();

        // Execute the next instruction
        cpu.exec_next_cicle();

        // Draw the screen
        raylib.beginDrawing();
        defer raylib.endDrawing();
        raylib.clearBackground(raylib.Color.black);

        var x: i32 = 0;
        var y: i32 = 0;

        while (x < 64) : (x += 1) {
            y = 0;
            while (y < 32) : (y += 1) {
                if (cpu.display[@intCast(x)][@intCast(y)] != 0)
                    raylib.drawRectangle(x * 30, y * 30, 30, 30, raylib.Color.white);
            }
        }
    }
}
