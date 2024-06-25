const std = @import("std");

const Chip8CPU = struct {
    display: [2048]u8,
    ram: [4096]u8,
    stack: [16]u16,
    regv: [16]u8,
    i: u16,
    dt: u8,
    st: u8,
    pc: u16,
    sp: u8,

    /// Initializes the CPU resgisters
    /// and memory
    pub fn init() Chip8CPU {
        return Chip8CPU{
            // Initializa all the memory
            .display = std.mem.zeroes([2048]u8),
            .ram = std.mem.zeroes([4096]u8),
            .stack = std.mem.zeroes([16]u16),
            .regv = std.mem.zeroes([16]u8),
            .i = 0x0,
            .dt = 0x0,
            .st = 0x0,
            .pc = 0x200,
            .sp = 0x0,
        };
    }

    /// Clears the 64x32 display buffer
    /// (0x00e0)
    pub fn cls(self: *Chip8CPU) void {
        for (&self.display) |*pixel| {
            pixel.* = 0;
        }
    }

    /// Return from subroutine
    /// The interpreter sets the program counter to the address at the top of
    /// the stack, then subtracts 1 from the stack pointer.
    /// (0x00ee)
    pub fn ret(self: *Chip8CPU) void {
        self.pc = self.stack[self.sp];
        self.sp = self.sp - 1;
    }

    /// Jump to location nnn
    /// The interpreter sets the program counter to nnn.
    /// (0x1nnn)
    pub fn jp(self: *Chip8CPU, nnn: u16) void {
        self.pc = nnn;
    }

    /// Call subroutine at nnn
    /// The interpreter increments the stack pointer, then puts the current
    /// PC on the top of the stack. The PC is then set to nnn.
    /// (0x2nnn)
    pub fn call(self: *Chip8CPU, nnn: u16) void {
        self.sp += 1;
        self.stack[self.sp] = self.pc;
        self.pc = nnn;
    }

    /// Skip next instruction if Vx = kk
    /// The interpreter compares register Vx to kk, and if they are equal,
    /// increments the program counter by 2.
    /// (0x3xkk)
    pub fn se_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        if (self.regv[x] == kk) {
            self.pc += 2;
        }
    }

    /// Skip next instruction if Vx != kk.
    /// The interpreter compares register Vx to kk, and if they are not equal,
    /// increments the program counter by 2.
    /// (0x4xkk)
    pub fn sne_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        if (self.regv[x] != kk) {
            self.pc += 2;
        }
    }

    /// Skip next instruction if Vx = Vy.
    /// The interpreter compares register Vx to register Vy, and if they are
    /// equal, increments the program counter by 2.
    /// (0x5xy0)
    pub fn se_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        if (self.regv[x] != self.regv[y]) {
            self.pc += 2;
        }
    }

    /// Set Vx = kk.
    /// The interpreter puts the value kk into register Vx.
    /// (0x6xkk)
    pub fn ld_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        self.regv[x] = kk;
    }

    /// Set Vx = Vx + kk.
    /// Adds the value kk to the value of register Vx, then stores the
    /// result in Vx.
    /// (0x7xkk)
    pub fn add_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        self.regv[x] += kk;
    }

    /// Set Vx = Vy.
    /// Stores the value of register Vy in register Vx.
    /// (0x8xy0)
    pub fn ld_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] = self.regv[y];
    }

    /// Set Vx = Vx OR Vy.
    /// Performs a bitwise OR on the values of Vx and Vy, then stores
    /// the result in Vx.
    /// (0x8xy1)
    pub fn or_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] |= self.regv[y];
    }

    /// Set Vx = Vx AND Vy.
    /// Performs a bitwise AND on the values of Vx and Vy, then stores
    /// the result in Vx.
    /// (0x8xy2)
    pub fn and_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] &= self.regv[y];
    }

    /// Set Vx = Vx XOR Vy.
    /// Performs a bitwise exclusive OR on the values of Vx and Vy, then
    /// stores the result in Vx.
    /// (0x8xy3)
    pub fn xor_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] ^= self.regv[y];
    }

    /// Set Vx = Vx + Vy, set VF = carry.
    /// The values of Vx and Vy are added together. If the result is greater
    /// than 8 bits (i.e., > 255,) VF is set to 1, otherwise 0. Only the
    /// lowest 8 bits of the result are kept, and stored in Vx.
    /// (0x8xy4)
    pub fn add_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        const overflow = @addWithOverflow(self.regv[x], self.regv[y]);
        self.regv[x] = overflow[0];
        if (overflow[1]) {
            self.regv[0xf] = 1;
        } else {
            self.regv[0xf] = 0;
        }
    }

    /// Set Vx = Vx - Vy, set VF = NOT borrow.
    /// If Vx > Vy, then VF is set to 1, otherwise 0. Then Vy is subtracted
    /// from Vx, and the results stored in Vx.
    /// (0x8xy5)
    pub fn sub_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        // TODO
        self.regv[x] = self.regv[y];
    }
};

pub fn main() !void {
    const a: u8 = 10; // 00001100
    const b: u8 = 252; // 011111100
    const overflow = @subWithOverflow(a, b);
    std.debug.print("overflow: {}, {}", .{ overflow[0], overflow[1] });
}
