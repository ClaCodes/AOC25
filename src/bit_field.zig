const std = @import("std");
const m = @import("mask_iterator.zig");

pub const BitField = struct {
    data: []u64,
    pub fn set(self: *BitField, i: u64) !void {
        const index = @divFloor(i, 64);
        const offset: u6 = @intCast(@mod(i, 64));
        const one: u64 = 1;
        if (index >= self.data.len) {
            return error.OutOfBounds;
        }
        self.data[index] |= (one << offset);
    }
    pub fn clear(self: *BitField, i: u64) !void {
        const index = @divFloor(i, 64);
        const offset: u6 = @intCast(@mod(i, 64));
        const one: u64 = 1;
        if (index >= self.data.len) {
            return error.OutOfBounds;
        }
        self.data[index] &= ~(one << offset);
    }
    pub fn clear_all(self: *BitField) void {
        for (0..self.data.len) |i| {
            self.data[i] = 0;
        }
    }
    pub fn get_no_border(self: *const BitField, i: i64) bool {
        if (i < 0) {
            return false;
        }
        if (self.get(@intCast(i))) |value| {
            return value;
        } else |e| {
            std.log.debug("{}", .{e});
            return false;
        }
    }
    pub fn get(self: *const BitField, i: u64) !bool {
        const index = @divFloor(i, 64);
        const offset: u6 = @intCast(@mod(i, 64));
        const one: u64 = 1;
        if (index >= self.data.len) {
            return error.OutOfBounds;
        }
        return (self.data[index] & (one << offset) != 0);
    }
    pub fn count_set(self: *const BitField) u64 {
        var count: u64 = 0;
        for (self.data) |d| {
            count += m.count_bits(d);
        }
        return count;
    }
    pub fn xor(self: *BitField, other: *const BitField) !void {
        if (other.data.len > self.data.len) {
            return error.OutOfBounds;
        }
        for (0..self.data.len) |i| {
            self.data[i] ^= other.data[i];
        }
    }
};

pub const BitField2d = struct {
    field: BitField,
    width: u64,
    pub fn set(self: *BitField2d, x: u64, y: u64) !void {
        if (x >= self.width) {
            return error.OutOfBounds;
        }
        try self.field.set(x + y * self.width);
    }
    pub fn clear(self: *BitField2d, x: u64, y: u64) !void {
        if (x >= self.width) {
            return error.OutOfBounds;
        }
        try self.field.clear(x + y * self.width);
    }
    pub fn clear_all(self: *BitField2d) void {
        self.field.clear_all();
    }
    pub fn get_no_border(self: *const BitField2d, x: i64, y: i64) bool {
        if (x < 0 or y < 0) {
            return false;
        }
        if (self.get(@intCast(x), @intCast(y))) |value| {
            return value;
        } else |e| {
            std.log.debug("{}", .{e});
            return false;
        }
    }
    pub fn get(self: *const BitField2d, x: u64, y: u64) !bool {
        if (x >= self.width) {
            return error.OutOfBounds;
        }
        return try self.field.get(x + y * self.width);
    }
    pub fn count_set(self: *const BitField2d) u64 {
        return self.field.count_set();
    }
    pub fn xor(self: *BitField2d, other: *const BitField2d) !void {
        return self.field.xor(&other.field);
    }
};

test "BitField" {
    var data = std.mem.zeroes([32]u64);
    var b = BitField{ .data = data[0..] };
    try b.set(23);
    try std.testing.expectEqual(true, b.get(23));
    try std.testing.expectEqual(false, b.get(24));
    try b.set(22);
    try std.testing.expectEqual(2, b.count_set());
    try b.clear(23);
    try std.testing.expectEqual(false, b.get(23));
}

test "BitField out of bounds" {
    var data = std.mem.zeroes([2]u64);
    var b = BitField{ .data = data[0..] };
    try b.set(127);
    try std.testing.expectEqual(true, b.get(127));
    try std.testing.expectError(error.OutOfBounds, b.set(128));
    try std.testing.expectError(error.OutOfBounds, b.get(128));
    try std.testing.expectEqual(false, b.get_no_border(128));
}

test "BitField2d" {
    var data = std.mem.zeroes([32]u64);
    const b = BitField{ .data = data[0..] };
    var b2d = BitField2d{ .field = b, .width = 12 };
    try std.testing.expectError(error.OutOfBounds, b2d.set(14, 2));
    try std.testing.expectError(error.OutOfBounds, b2d.get(14, 2));
    try std.testing.expectEqual(false, b2d.get_no_border(14, 2));
    try b2d.set(8, 20);
    try std.testing.expectEqual(true, try b2d.get(8, 20));
    try std.testing.expectEqual(false, try b2d.get(9, 20));
    try std.testing.expectEqual(false, try b2d.get(8, 21));
    try b2d.clear(8, 20);
    try std.testing.expectEqual(false, try b2d.get(8, 20));
}
