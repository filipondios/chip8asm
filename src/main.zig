const std = @import("std");

const Chip8CPU = struct {
    display: [2048]u8,
    ram: [4096]u8,
    stack: [16]u16,
    regv: [16]u8,
    keypad: [16]u8,
    i: u16,
    dt: u8,
    st: u8,
    pc: u16,
    sp: u8,

    const sprites = [80]u8{
        0xf0, 0x90, 0x90, 0x90, 0xf0, // 0
        0x20, 0x60, 0x20, 0x20, 0x70, // 1
        0xf0, 0x10, 0xf0, 0x80, 0xf0, // 2
        0xf0, 0x10, 0xf0, 0x10, 0xf0, // 3
        0x90, 0x90, 0xf0, 0x10, 0x10, // 4
        0xf0, 0x80, 0xf0, 0x10, 0xf0, // 5
        0xf0, 0x80, 0xf0, 0x90, 0xf0, // 6
        0xf0, 0x10, 0x20, 0x40, 0x40, // 7
        0xf0, 0x90, 0xf0, 0x90, 0xf0, // 8
        0xf0, 0x90, 0xf0, 0x10, 0xf0, // 9
        0xf0, 0x90, 0xf0, 0x90, 0x90, // A
        0xe0, 0x90, 0xe0, 0x90, 0xe0, // B
        0xf0, 0x80, 0x80, 0x80, 0xf0, // C
        0xe0, 0x90, 0x90, 0x90, 0xe0, // D
        0xf0, 0x80, 0xf0, 0x80, 0xf0, // E
        0xf0, 0x80, 0xf0, 0x80, 0x80, // F
    };

    /// Creates a new instance of a CPU
    /// with all resgisters and memory
    /// Initialized
    pub fn init() Chip8CPU {
        var cpu: Chip8CPU = Chip8CPU{
            .i = 0x0,
            .dt = 0x0,
            .st = 0x0,
            .pc = 0x200,
            .sp = 0x0,
        };

        // Initialize all the buffers
        cpu.display = std.mem.zeroes([2048]u8);
        cpu.ram = std.mem.zeroes([4096]u8);
        cpu.stack = std.mem.zeroes([16]u16);
        cpu.regv = std.mem.zeroes([16]u8);
        cpu.keypad = std.mem.zeroes([16]u8);

        // Load sprites to memory (0 - 80)
        std.mem.copyForwards(u8, cpu.display, sprites);
        return cpu;
    }

    /// Clears the 64x32 display buffer
    /// (0x00e0)
    pub fn cls(self: *Chip8CPU) void {
        for (&self.display) |*pixel| {
            pixel.* = 0;
        }
        self.pc += 2;
    }

    /// Return from subroutine
    /// The interpreter sets the program counter to the address at the top of
    /// the stack, then subtracts 1 from the stack pointer.
    /// (0x00ee)
    pub fn ret(self: *Chip8CPU) void {
        self.pc = self.stack[self.sp] + 2;
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
        self.pc += if (self.regv[x] == kk) 4 else 2;
    }

    /// Skip next instruction if Vx != kk.
    /// The interpreter compares register Vx to kk, and if they are not equal,
    /// increments the program counter by 2.
    /// (0x4xkk)
    pub fn sne_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        self.pc += if (self.regv[x] != kk) 4 else 2;
    }

    /// Skip next instruction if Vx = Vy.
    /// The interpreter compares register Vx to register Vy, and if they are
    /// equal, increments the program counter by 2.
    /// (0x5xy0)
    pub fn se_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.pc += if (self.regv[x] != self.regv[y]) 4 else 2;
    }

    /// Set Vx = kk.
    /// The interpreter puts the value kk into register Vx.
    /// (0x6xkk)
    pub fn ld_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        self.regv[x] = kk;
        self.pc += 2;
    }

    /// Set Vx = Vx + kk.
    /// Adds the value kk to the value of register Vx, then stores the
    /// result in Vx.
    /// (0x7xkk)
    pub fn add_vx_byte(self: *Chip8CPU, x: u8, kk: u8) void {
        self.regv[x] += kk;
        self.pc += 2;
    }

    /// Set Vx = Vy.
    /// Stores the value of register Vy in register Vx.
    /// (0x8xy0)
    pub fn ld_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] = self.regv[y];
        self.pc += 2;
    }

    /// Set Vx = Vx OR Vy.
    /// Performs a bitwise OR on the values of Vx and Vy, then stores
    /// the result in Vx.
    /// (0x8xy1)
    pub fn or_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] |= self.regv[y];
        self.pc += 2;
    }

    /// Set Vx = Vx AND Vy.
    /// Performs a bitwise AND on the values of Vx and Vy, then stores
    /// the result in Vx.
    /// (0x8xy2)
    pub fn and_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] &= self.regv[y];
        self.pc += 2;
    }

    /// Set Vx = Vx XOR Vy.
    /// Performs a bitwise exclusive OR on the values of Vx and Vy, then
    /// stores the result in Vx.
    /// (0x8xy3)
    pub fn xor_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[x] ^= self.regv[y];
        self.pc += 2;
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
        self.pc += 2;
    }

    /// Set Vx = Vx - Vy, set VF = NOT borrow.
    /// If Vx > Vy, then VF is set to 1, otherwise 0. Then Vy is subtracted
    /// from Vx, and the results stored in Vx.
    /// (0x8xy5)
    pub fn sub_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        const overflow = @subWithOverflow(self.regv[x], self.regv[y]);
        self.regv[x] = overflow[0];
        self.regv[0xf] = if (overflow[1] == 1) 0 else 1;
        self.pc += 2;
    }

    /// Set Vx = Vx SHR 1.
    /// If the least-significant bit of Vx is 1, then VF is set to 1,
    /// otherwise 0. Then Vx is divided by 2.
    /// (0x8xy6)
    pub fn shr_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[0xf] = ((0x1 & self.regv[x]));
        self.regv[x] = @truncate(self.regv[x] >> 0x1);
        self.pc += 2;
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
        self.pc += 2;
    }

    /// Set Vx = Vx SHL 1.
    /// If the most-significant bit of Vx is 1, then VF is set to 1,
    /// otherwise to 0. Then Vx is multiplied by 2.
    /// (0x8xye)
    pub fn shl_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.regv[0xf] = ((0x80 & self.regv[x]));
        self.regv[x] = @truncate(self.regv[x] << 0x1);
        self.pc += 2;
        _ = y;
    }

    /// Skip next instruction if Vx != Vy.
    /// The values of Vx and Vy are compared, and if they are not equal,
    /// the program counter is increased by 2.
    /// (0x9xy0)
    pub fn sne_vx_vy(self: *Chip8CPU, x: u8, y: u8) void {
        self.pc += if (self.regv[x] != self.regv[y]) 4 else 2;
    }

    /// Set I = nnn.
    /// The value of register I is set to nnn.
    /// (0xannn)
    pub fn ld_i_addr(self: *Chip8CPU, nnn: u16) void {
        self.i = nnn;
        self.pc += 2;
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
        self.pc += 2;
    }

    /// Display n-byte sprite starting at memory location I at (Vx, Vy),
    /// set VF = collision.
    /// The interpreter reads n bytes from memory, starting at the address
    /// stored in I. These bytes are then displayed as sprites on screen at
    /// coordinates (Vx, Vy). Sprites are XORed onto the existing screen. If
    /// this causes any pixels to be erased, VF is set to 1, otherwise 0.
    /// (0xdxyn)
    pub fn drw_vx_vy_nibble(self: *Chip8CPU, x: u8, y: u8, n: u8) void {
        const cx = self.regv[x];
        const cy = self.regv[y];
        self.regv[0xf] = 0;
        self.pc += 2;

        for (0..n - 1) |i| {
            const sprite: u8 = self.ram[self.i + i];

            for (0..7) |bit| {
                if ((sprite & (0x80 >> bit)) != 0) {
                    const index: u16 = ((cx + bit) + ((cy + i) * 64)) % 2048;
                    // Detect colision at display (used pixel)
                    if (self.display[index] == 1)
                        self.regv[0xf] = 1;
                    // Draw the pixel
                    self.display[index] ^= 1;
                }
            }
        }
    }

    /// Skip next instruction if key with the value of Vx is pressed.
    /// Checks the keyboard, and if the key corresponding to the value of Vx
    /// is currently in the down position, PC is increased by 2.
    /// (0xex9e)
    pub fn skp_vx(self: *Chip8CPU, x: u8) void {
        self.pc += if (self.keypad[self.regv[x]] == 1) 4 else 2;
    }

    /// Skip next instruction if key with the value of Vx is not pressed.
    ///  Checks the keyboard, and if the key corresponding to the value of Vx
    /// is currently in the up position, PC is increased by 2.
    /// (0xexa1)
    pub fn skpn_vx(self: *Chip8CPU, x: u8) void {
        self.pc += if (self.keypad[self.regv[x]] == 0) 4 else 2;
    }

    /// Set Vx = delay timer value.
    /// The value of DT is placed into Vx.
    /// (0xfx07)
    pub fn ld_vx_dt(self: *Chip8CPU, x: u8) void {
        self.regv[x] = self.dt;
        self.pc += 2;
    }

    /// Wait for a key press, store the value of the key in Vx.
    /// All execution stops until a key is pressed, then the value of that
    /// key is stored in Vx.
    /// (0xfx0a)
    pub fn ld_vx_k(self: *Chip8CPU, x: u8) void {
        var keypressed: bool = false;

        for (0x0..0xf) |key| {
            if (self.keypad[key] == 1) {
                keypressed = true;
                self.regv[x] = key;
                break;
            }
        }
        if (keypressed)
            self.pc += 2;
    }

    /// Set delay timer = Vx.
    /// DT is set equal to the value of Vx.
    /// (0xfx15)
    pub fn ld_dt_vx(self: *Chip8CPU, x: u8) void {
        self.dt = self.regv[x];
        self.pc += 2;
    }

    /// Set sound timer = Vx.
    /// ST is set equal to the value of Vx.
    /// (0xfx18)
    pub fn ld_st_vx(self: *Chip8CPU, x: u8) void {
        self.st = self.regv[x];
        self.pc += 2;
    }

    /// Set I = I + Vx.
    /// The values of I and Vx are added, and the results are stored in I.
    /// (0xfx1e)
    pub fn add_i_vx(self: *Chip8CPU, x: u8) void {
        self.i = self.i + self.regv[x];
        self.pc += 2;
    }

    /// Set I = location of sprite for digit Vx.
    /// The value of I is set to the location for the hexadecimal sprite
    /// corresponding to the value of Vx.
    /// (0xfx29)
    pub fn ld_f_vx(self: *Chip8CPU, x: u8) void {
        self.i = 5 * self.regv[x];
        self.pc += 2;
    }

    /// Store BCD representation of Vx in memory locations I, I+1, and I+2.
    /// The interpreter takes the decimal value of Vx, and places the hundreds
    /// digit in memory at location in I, the tens digit at location I+1, and
    /// the ones digit at location I+2.
    /// (0xfx33)
    pub fn ld_b_vx(self: *Chip8CPU, x: u8) void {
        const val = self.regv[x];
        self.ram[self.i] = @trunc(val / 100);
        self.ram[self.i + 1] = @trunc(val / 10) % 10;
        self.ram[self.i + 2] = (val % 100) % 10;
        self.pc += 2;
    }

    /// Store registers V0 through Vx in memory starting at location I.
    /// The interpreter copies the values of registers V0 through Vx into
    /// memory, starting at the address in I.
    /// (0xfx55)
    pub fn ld_i_vx(self: *Chip8CPU, x: u8) void {
        for (0x0..x) |addr|
            self.ram[self.i + addr] = self.regv[addr];
        self.pc += 2;
    }

    /// Read registers V0 through Vx from memory starting at location I.
    /// The interpreter reads values from memory starting at location I
    /// into registers V0 through Vx.
    /// (0xfx65)
    pub fn ld_vx_i(self: *Chip8CPU, x: u8) void {
        for (0x0..x) |reg|
            self.regv[reg] = self.ram[self.i + reg];
        self.pc += 2;
    }
};

pub fn main() !void {
    var prng = std.Random.DefaultPrng.init(undefined);
    const rand = prng.random().int(u8);
    std.debug.print("result {}", .{rand});
}
