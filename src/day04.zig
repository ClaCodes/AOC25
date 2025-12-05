const std = @import("std");
const bf = @import("bit_field.zig");

pub fn mark_moveable(b: *const bf.BitField2d, movable: *bf.BitField2d) !void {
    const bits = b.field.data.len * 64;
    const lines = bits / b.width;
    var i: i64 = 0;
    while (i < lines) : (i += 1) {
        var j: i64 = 0;
        while (j < b.width) : (j += 1) {
            var n: u64 = 0;
            if (!b.get_no_border(j, i)) {
                continue;
            }
            if (b.get_no_border(j + 1, i + 0)) {
                n += 1;
            }
            if (b.get_no_border(j + 1, i + 1)) {
                n += 1;
            }
            if (b.get_no_border(j + 0, i + 1)) {
                n += 1;
            }
            if (b.get_no_border(j - 1, i + 1)) {
                n += 1;
            }
            if (b.get_no_border(j - 1, i + 0)) {
                n += 1;
            }
            if (b.get_no_border(j - 1, i - 1)) {
                n += 1;
            }
            if (b.get_no_border(j + 0, i - 1)) {
                n += 1;
            }
            if (b.get_no_border(j + 1, i - 1)) {
                n += 1;
            }
            if (n < 4) {
                try movable.set(@intCast(j), @intCast(i));
            }
        }
    }
}

pub fn print_field(b: *bf.BitField2d, writer: *std.io.Writer) !void {
    const bits = b.field.data.len * 64;
    const lines = bits / b.width;
    var i: u64 = 0;
    while (i < lines) : (i += 1) {
        var j: u64 = 0;
        while (j < b.width) : (j += 1) {
            if (try b.get(j, i)) {
                try writer.print("@", .{});
            } else {
                try writer.print(".", .{});
            }
        }
        try writer.print("\n", .{});
    }
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var data = std.mem.zeroes([512]u64);
    const b = bf.BitField{ .data = data[0..] };
    var b2d = bf.BitField2d{ .field = b, .width = 0 };
    var data2 = std.mem.zeroes([512]u64);
    const b2 = bf.BitField{ .data = data2[0..] };
    var movable = bf.BitField2d{ .field = b2, .width = 0 };
    var line_count: u64 = 0;
    while (reader.takeDelimiterExclusive('\n')) |line| : (line_count += 1) {
        reader.toss(1);
        b2d.width = line.len;
        movable.width = line.len;
        for (line, 0..) |c, i| {
            if (c == '@') {
                try b2d.set(i, line_count);
            }
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    const original_count = b2d.count_set();
    // try print_field(&b2d, writer);
    try mark_moveable(&b2d, &movable);
    try writer.print("{}\n", .{movable.count_set()});
    while (movable.count_set() > 0) {
        try b2d.xor(&movable);
        movable.clear_all();
        try mark_moveable(&b2d, &movable);
    }
    try writer.print("{}\n", .{original_count - b2d.count_set()});
    try writer.flush();
}

test "solve" {
    const in =
        \\ ..@@.@@@@.
        \\ @@@.@.@.@@
        \\ @@@@@.@.@@
        \\ @.@@@@..@.
        \\ @@.@@@@.@@
        \\ .@@@@@@@.@
        \\ .@.@.@.@@@
        \\ @.@@@.@@@@
        \\ .@@@@@@@@.
        \\ @.@.@@@.@.
        \\
    ;
    const out =
        \\13
        \\43
        \\
    ;
    var buf: [255]u8 = undefined;
    var r: std.Io.Reader = .fixed(in);
    var w: std.Io.Writer = .fixed(&buf);
    try solve(&r, &w);
    try std.testing.expectEqualStrings(out, w.buffered());
}
