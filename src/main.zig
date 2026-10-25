const rl = @import("raylib");
const std = @import("std");
const clay = @import("clay.zig");

pub fn main(init: std.process.Init) !void {
    rl.initWindow(1280, 720, "clay-zig");
    defer rl.closeWindow();

    const arena_memory = try init.arena.allocator().alloc(u8, clay.minMemorySize());
    const arena = clay.createArenaWithCapacityAndMemory(arena_memory.len, arena_memory.ptr);

    _ = clay.initialize(
        arena,
        .{ .width = 1280, .height = 720 },
        .{ .errorHandlerFunction = null, .userData = null },
    );

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();

        clay.setLayoutDimensions(.{
            .width = 1280,
            .height = 720,
        });
        clay.setPointerState(
            .{
                .x = @floatFromInt(rl.getMouseX()),
                .y = @floatFromInt(rl.getMouseY()),
            },
            rl.isMouseButtonDown(.left),
        );
        clay.updateScrollContainers(
            true,
            .{
                .x = rl.getMouseWheelMoveV().x,
                .y = rl.getMouseWheelMoveV().y,
            },
            rl.getFrameTime(),
        );

        // ----------------------------------------------------------

        clay.beginLayout();

        clay.begin(clay.id("container"), .{
            .layout = .{
                .sizing = .{
                    .width = clay.sizingGrow(0),
                    .height = clay.sizingGrow(0),
                },
            },
            .backgroundColor = .{
                .r = 255,
                .g = 255,
                .b = 255,
                .a = 255,
            },
        });
        {
            defer clay.end();

            clay.begin(
                clay.id("sidebar"),
                .{
                    .layout = .{
                        .layoutDirection = clay.TOP_TO_BOTTOM,
                        .sizing = .{
                            .width = clay.sizingFixed(300),
                            .height = clay.sizingGrow(0),
                        },
                    },
                    .backgroundColor = .{
                        .r = 127,
                        .g = 127,
                        .b = 127,
                        .a = 127,
                    },
                },
            );
            {
                defer clay.end();
            }
        }

        // ----------------------------------------------------------

        const render_commands = clay.endLayout(rl.getFrameTime());

        for (0..@intCast(render_commands.length), render_commands.internalArray) |_, *it| {
            switch (it.commandType) {
                clay.RENDER_COMMAND_TYPE_RECTANGLE => {
                    const color = it.renderData.rectangle.backgroundColor;

                    rl.drawRectangleRec(
                        .{
                            .x = it.boundingBox.x,
                            .y = it.boundingBox.y,
                            .width = it.boundingBox.width,
                            .height = it.boundingBox.height,
                        },
                        .{
                            .r = @intFromFloat(color.r),
                            .g = @intFromFloat(color.g),
                            .b = @intFromFloat(color.b),
                            .a = @intFromFloat(color.a),
                        },
                    );
                },
                else => {
                    std.log.debug("unhandled render command: {}", .{it});
                },
            }
        }

        rl.endDrawing();
    }
}
