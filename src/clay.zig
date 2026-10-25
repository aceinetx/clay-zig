const std = @import("std");
const clay = @import("c-clay");
const zeroinit_struct = @import("zeroinit_struct.zig");

pub const minMemorySize = clay.Clay_MinMemorySize;
pub const createArenaWithCapacityAndMemory = clay.Clay_CreateArenaWithCapacityAndMemory;
pub const initialize = clay.Clay_Initialize;
pub const setLayoutDimensions = clay.Clay_SetLayoutDimensions;
pub const setPointerState = clay.Clay_SetPointerState;
pub const updateScrollContainers = clay.Clay_UpdateScrollContainers;
pub const beginLayout = clay.Clay_BeginLayout;
pub const endLayout = clay.Clay_EndLayout;

pub const ElementId = clay.Clay_ElementId;
pub const RenderCommandArray = clay.Clay_RenderCommandArray;

pub const String = clay.Clay_String;
pub const hashString = clay.Clay__HashString;

pub const sizingMinMax = clay.Clay_SizingMinMax;

pub const RENDER_COMMAND_TYPE_RECTANGLE = clay.CLAY_RENDER_COMMAND_TYPE_RECTANGLE;
pub const TOP_TO_BOTTOM = clay.CLAY_TOP_TO_BOTTOM;

pub fn id(eid: []const u8) ElementId {
    return hashString(.{
        .isStaticallyAllocated = true,
        .length = @intCast(eid.len),
        .chars = eid.ptr,
    }, 0);
}

pub fn begin(eid: ElementId, decl: zeroinit_struct.createZeroinitStruct(clay.Clay_ElementDeclaration)) void {
    clay.Clay__OpenElementWithId(eid);

    const decl_orig: *const clay.Clay_ElementDeclaration = @ptrCast(&decl);
    clay.Clay__ConfigureOpenElement(decl_orig.*);
}
pub const end = clay.Clay__CloseElement;

pub fn sizingGrow(minMax: anytype) zeroinit_struct.createZeroinitStruct(clay.Clay_SizingAxis) {
    switch (@TypeOf(minMax)) {
        comptime_int => {
            if (minMax != 0) @compileError("minMax expected to be 0 as for zero-init");

            return .{ .size = .{ .minMax = std.mem.zeroes(sizingMinMax) }, .type = clay.CLAY__SIZING_TYPE_GROW };
        },
        sizingMinMax => {
            return .{ .size = .{ .minMax = minMax }, .type = clay.CLAY__SIZING_TYPE_GROW };
        },
        else => @compileError("expected an argument of type clay.sizingMinMax or comptime_int"),
    }
}

pub fn sizingFixed(value: f32) zeroinit_struct.createZeroinitStruct(clay.Clay_SizingAxis) {
    return .{
        .size = .{
            .minMax = .{
                .min = value,
                .max = value,
            },
        },
        .type = clay.CLAY__SIZING_TYPE_FIXED,
    };
}
