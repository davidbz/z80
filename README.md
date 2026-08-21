# z80

A Zilog Z80 CPU core in Zig. Conformance-tested against
[SingleStepTests/z80](https://github.com/SingleStepTests/z80): all 1,604,000
cases pass on both architectural state and T-state counts.

The core knows nothing about the machine around it — you supply the bus — so it
drops into any system that has a Z80 in it. It is the sound CPU in
[zigesis](https://github.com/davidbz/zigesis), and a sibling of
[z68k](https://github.com/davidbz/z68k), which is the same design for the 68000.

## Using it

```zig
const z80 = @import("z80");

const MyBus = struct {
    mem: [0x10000]u8 = .{0} ** 0x10000,

    pub fn z80Read8(bus: *MyBus, addr: u16) u8 { return bus.mem[addr]; }
    pub fn z80Write8(bus: *MyBus, addr: u16, val: u8) void { bus.mem[addr] = val; }
    pub fn z80In(bus: *MyBus, port: u16) u8 { _ = .{ bus, port }; return 0xFF; }
    pub fn z80Out(bus: *MyBus, port: u16, val: u8) void { _ = .{ bus, port, val }; }
};

var bus: MyBus = .{};
const Core = z80.Core(MyBus);
var cpu: z80.Cpu = .{};

Core.reset(&cpu);
Core.step(&cpu, &bus);           // one instruction; cpu.cycles carries T-states
_ = Core.interrupt(&cpu, &bus, .{ .int = true }); // true when it fired
```

The four bus methods carry a `z80` prefix because a Z80 is nearly always a
second CPU: the host struct usually answers a main CPU's bus too, and `read8`
would collide with it.

Add it to your `build.zig.zon`:

```
zig fetch --save git+https://github.com/davidbz/z80?ref=v0.0.1
```

Nothing here allocates, and no state lives outside `Cpu` — so a host that wants
save states can copy the struct.

## Layout

Data and logic are split, the same way z68k splits them:

| File | What is in it |
|---|---|
| `src/cpu.zig` | Architectural state: registers, flags, IFFs, interrupt mode |
| `src/decode.zig` | Opcode field decomposition and register tables |
| `src/flags.zig` | ALU operations and their flag effects |
| `src/core.zig` | `Core(comptime Bus)` — fetch, decode, execute |
| `src/root.zig` | The barrel module |

Undocumented behaviour is modelled, not skipped: the X and Y flag copies
(including the MEMPTR-sourced ones `BIT n,(HL)` uses), `Q`, MEMPTR/WZ itself,
and the DD/FD-prefixed half-registers. The conformance suite tests all of them.

## Testing

```
zig build test          # unit tests
tools/fetch_tests.sh    # once: clones the corpus into testdata/ (~1.6 GB)
zig build sst           # the full suite, ~30 s
zig build sst -- cb     # only files whose name contains "cb"
```

The suite runner always builds `ReleaseFast` whatever `-Doptimize` says; over
1.6 M cases the difference is half a minute against three.

## License

MIT — see [`LICENSE`](LICENSE).
