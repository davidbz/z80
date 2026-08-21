//! A Zilog Z80 core, in the same shape as z68k: data in `cpu`/`decode`, logic
//! in `flags`/`core`. The host supplies the bus, so the core knows nothing
//! about the machine around it. Nothing here allocates.
//!
//!     var bus = MyBus{ ... };
//!     const Z80 = core.Core(MyBus);
//!     var c: Cpu = .{};
//!     Z80.reset(&c);
//!     Z80.step(&c, &bus);

const std = @import("std");

pub const cpu = @import("cpu.zig");
pub const decode = @import("decode.zig");
pub const flags = @import("flags.zig");
pub const core = @import("core.zig");

pub const Cpu = cpu.Cpu;
pub const Flags = cpu.Flags;
pub const Im = cpu.Im;
pub const Interrupt = cpu.Interrupt;
pub const Core = core.Core;

test {
    std.testing.refAllDecls(@This());
}
