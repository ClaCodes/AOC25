const std = @import("std");

fn rotate_right(dial: *i32, rotation: i32) i32 {
    var new: i32 = dial.* + rotation;
    var zeros: i32 = 0;
    while (new > 99) {
        new -= 100;
        zeros += 1;
    }
    dial.* = new;
    return zeros;
}

fn rotate_left(dial: *i32, rotation: i32) i32 {
    const original = dial.*;
    var new: i32 = dial.* - rotation;
    var zeros: i32 = 0;
    while (new <= 0) {
        new += 100;
        zeros += 1;
    }
    if (new == 100) {
        new = 0;
    }
    if (new == 0 and zeros == 0) {
        zeros += 1;
    }
    if (original == 0) {
        zeros -= 1;
    }
    dial.* = new;
    return zeros;
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var dial: i32 = 50;
    var zerosA: i32 = 0;
    var zerosB: i32 = 0;
    while (reader.takeDelimiterExclusive('\n')) |line| {
        reader.toss(1);
        const rotation = try std.fmt.parseInt(i32, line[1..], 10);
        if (line[0] == 'R') {
            zerosB += rotate_right(&dial, rotation);
            std.log.debug("right: new dial {} rotation {} zerosB {}", .{ dial, rotation, zerosB });
        } else if (line[0] == 'L') {
            zerosB += rotate_left(&dial, rotation);
            std.log.debug("left: new dial {} rotation {} zerosB {}", .{ dial, rotation, zerosB });
        } else {
            return error.ReadFailed;
        }
        if (dial == 0) {
            zerosA += 1;
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    try writer.print("{d}\n", .{zerosA});
    try writer.print("{d}\n", .{zerosB});
    try writer.flush();
}

test "basic" {
    var dial: i32 = 11;
    try std.testing.expectEqual(0, rotate_right(&dial, 8));
    try std.testing.expectEqual(19, dial);
    try std.testing.expectEqual(1, rotate_left(&dial, 19));
    try std.testing.expectEqual(0, dial);
}

test "basic over- and under-flow" {
    var dial: i32 = 0;
    try std.testing.expectEqual(0, rotate_left(&dial, 1));
    try std.testing.expectEqual(99, dial);
    try std.testing.expectEqual(1, rotate_right(&dial, 1));
    try std.testing.expectEqual(0, dial);
    try std.testing.expectEqual(0, rotate_right(&dial, 1));
    try std.testing.expectEqual(1, dial);
    try std.testing.expectEqual(1, rotate_left(&dial, 1));
    try std.testing.expectEqual(0, dial);
}

test "over- and under-flow" {
    var dial: i32 = 5;
    try std.testing.expectEqual(1, rotate_left(&dial, 10));
    try std.testing.expectEqual(95, dial);
    try std.testing.expectEqual(1, rotate_right(&dial, 5));
    try std.testing.expectEqual(0, dial);
}

test "zero" {
    var dial: i32 = 0;
    try std.testing.expectEqual(0, rotate_left(&dial, 0));
    try std.testing.expectEqual(0, dial);
    try std.testing.expectEqual(0, rotate_right(&dial, 0));
    try std.testing.expectEqual(0, dial);
}

test "long sample" {
    var dial: i32 = 50;
    try std.testing.expectEqual(1, rotate_left(&dial, 68));
    try std.testing.expectEqual(0, rotate_left(&dial, 30));
    try std.testing.expectEqual(1, rotate_right(&dial, 48));
    try std.testing.expectEqual(0, rotate_left(&dial, 5));
    try std.testing.expectEqual(1, rotate_right(&dial, 60));
    try std.testing.expectEqual(1, rotate_left(&dial, 55));
    try std.testing.expectEqual(0, rotate_left(&dial, 1));
    try std.testing.expectEqual(1, rotate_left(&dial, 99));
    try std.testing.expectEqual(0, rotate_right(&dial, 14));
    try std.testing.expectEqual(1, rotate_left(&dial, 82));
}

test "solve" {
    const in =
        \\L68
        \\L30
        \\R48
        \\L5
        \\R60
        \\L55
        \\L1
        \\L99
        \\R14
        \\L82
        \\
    ;
    const out =
        \\3
        \\6
        \\
    ;
    var buf: [255]u8 = undefined;
    var r: std.Io.Reader = .fixed(in);
    var w: std.Io.Writer = .fixed(&buf);
    try solve(&r, &w);
    try std.testing.expectEqualStrings(out, w.buffered());
}
