const std = @import("std");
const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ----------------------------------------------------------

    const translate_c = b.dependency("translate_c", .{});

    const clay = Translator.init(translate_c, .{
        .c_source_file = b.path("src/clay.h"),
        .target = target,
        .optimize = optimize,
    });

    // ----------------------------------------------------------

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");

    const raylib_artifact = raylib_dep.artifact("raylib");

    // ----------------------------------------------------------

    const exe = b.addExecutable(.{
        .name = "clay-zig",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/main.zig"),
            .imports = &.{
                .{ .name = "raylib", .module = raylib },
                .{ .name = "c-clay", .module = clay.mod },
            },
        }),
    });
    exe.root_module.linkLibrary(raylib_artifact);
    exe.root_module.addCSourceFile(.{
        .file = b.path("src/clay.c"),
    });

    b.installArtifact(exe);

    // ----------------------------------------------------------

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    run_cmd.addPassthruArgs();
}
