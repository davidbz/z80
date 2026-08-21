const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // The core: no dependencies, no allocation.
    const z80 = b.addModule("z80", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // --- tests -------------------------------------------------------------
    const test_step = b.step("test", "Run unit tests");

    const core_tests = b.addTest(.{ .root_module = z80 });
    test_step.dependOn(&b.addRunArtifact(core_tests).step);

    const harness_mod = b.createModule(.{
        .root_source_file = b.path("src/harness.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "z80", .module = z80 }},
    });
    const harness_tests = b.addTest(.{ .root_module = harness_mod });
    test_step.dependOn(&b.addRunArtifact(harness_tests).step);

    // --- SingleStepTests conformance suite ----------------------------------
    // The runner chews through 1.3 GiB of JSON across 1.6M cases: Debug takes
    // ~2m40s where ReleaseFast takes ~30s, so it always builds fast no matter
    // what -Doptimize says. Safety-checked coverage of the core still comes
    // from the Debug unit tests above.
    const z80_fast = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });
    const sst = b.addExecutable(.{
        .name = "z80-sst",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/harness.zig"),
            .target = target,
            .optimize = .ReleaseFast,
            .imports = &.{.{ .name = "z80", .module = z80_fast }},
        }),
    });

    const sst_run = b.addRunArtifact(sst);
    sst_run.setCwd(b.path(".")); // testdata/ is resolved relative to the project
    if (b.args) |args| sst_run.addArgs(args);
    b.step("sst", "Run the SingleStepTests conformance suite (needs testdata/)")
        .dependOn(&sst_run.step);
}
