const std = @import("std");

pub fn createZeroinitStruct(original: type) type {
    const strukt = @typeInfo(original).@"struct";

    var attrs: [strukt.field_attrs.len]@TypeOf(strukt.field_attrs[0]) = undefined;
    @memcpy(&attrs, strukt.field_attrs);

    var types: [strukt.field_types.len]@TypeOf(strukt.field_types[0]) = undefined;
    @memcpy(&types, strukt.field_types);

    inline for (0.., &types) |i, *ty| {
        if (@typeInfo(ty.*) == .@"struct") {
            ty.* = createZeroinitStruct(ty.*);
        }
        const value: ty.* = std.mem.zeroes(ty.*);
        attrs[i].default_value_ptr = @ptrCast(&value);
    }

    return @Struct(
        strukt.layout,
        strukt.backing_integer,
        strukt.field_names,
        &types,
        &attrs,
    );
}
