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
        self.regv[0xf] = overflow[1];
    }

    /// Set Vx = Vx - Vy, set VF = NOT borrow.
    /// If Vx > Vy, then VF is set to 1, otherwise 0. Then Vy is subtracted
    /// from Vx, and the results stored in Vx.
    /// (0x8xy5)
    pub fn sub_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        const overflow = @subWithOverflow(self.regv[x], self.regv[y]);
        self.regv[x] = overflow[0];
        self.regv[0xf] = if (overflow[1] == 1) 0 else 1;
    }

    /// Set Vx = Vx SHR 1.
    /// If the least-significant bit of Vx is 1, then VF is set to 1,
    /// otherwise 0. Then Vx is divided by 2.
    /// (0x8xy6)
    pub fn shr_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[0xf] = ((0x1 & self.regv[x]));
        self.regv[x] = @truncate(self.regv[x] >> 0x1);
        _ = y;
    }

    /// Set Vx = Vy - Vx, set VF = NOT borrow.
    /// If Vy > Vx, then VF is set to 1, otherwise 0. Then Vx is subtracted
    /// from Vy, and the results stored in Vx.
    /// (0x8xy7)
    pub fn subn_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        const overflow = @subWithOverflow(self.regv[y], self.regv[x]);
        self.regv[x] = overflow[0];
        self.regv[0xf] = if (overflow[1] == 1) 0 else 1;
    }

    /// Set Vx = Vx SHL 1.
    /// If the most-significant bit of Vx is 1, then VF is set to 1,
    /// otherwise to 0. Then Vx is multiplied by 2.
    /// (0x8xye)
    pub fn shl_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[0xf] = ((0x80 & self.regv[x]));
        self.regv[x] = @truncate(self.regv[x] << 0x1);
        _ = y;
    }

    /// Skip next instruction if Vx != Vy.
    /// The values of Vx and Vy are compared, and if they are not equal,
    /// the program counter is increased by 2.
    /// (0x9xy0)
    pub fn sne_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        if (self.regv[x] != self.regv[y]) {
            self.pc += 2;
        }
    }

    /// Set I = nnn.
    /// The value of register I is set to nnn.
    /// (0xannn)
    pub fn ld_i_addr(self: *Chip8CPU, nnn: u16) void {
        self.i = nnn;
    }

    /// Jump to location nnn + V0.
    /// The program counter is set to nnn plus the value of V0.
    /// (0xbnnn)
    pub fn jp_v0_addr(self: *Chip8CPU, nnn: u16) void {
        self.pc = self.regv[0x0] + nnn;
    }

    /// Set Vx = random byte AND kk.
    /// The interpreter generates a random number from 0 to 255, which is
    /// then ANDed with the value kk. The results are stored in Vx.
    /// (0xcxkk)
    pub fn rnd_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        var prng = std.Random.DefaultPrng.init(undefined);
        const rand = prng.random().int(u8);
        self.regv[x] = rand & kk;
    }

    // TODO Dxyn - DRW Vx, Vy, nibble
    // TODO Ex9E - SKP Vx
    // TODO ExA1 - SKNP Vx

    /// Set Vx = delay timer value.
    /// The value of DT is placed into Vx.
    /// (0xfx07)
    pub fn ld_vx_dt(self: *Chip8CPU, x: u8) void {
        self.regv[x] = self.dt;
    }
};

pub fn main() !void {
    // var a: u8 = 10; // 00001100
    // const b: u8 = 10; // 011111100
    // for (0..2) |index| {
    //    a <<= @truncate(index);
    // }

    var prng = std.Random.DefaultPrng.init(undefined);
    const rand = prng.random().int(u8);
    std.debug.print("result {}", .{rand});

    // if (overflow[1] == 1) {
    //    std.debug.print("overflow", .{});
    // } else std.debug.print("not overflow", .{});
}
