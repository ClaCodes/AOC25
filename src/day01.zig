const std = @import("std");

fn required_fuel(mass: i32) i32 {
    return @divFloor(mass, 3) - 2;
}

fn rocket_limit(mass: i32) i32 {
    const fuel: i32 = required_fuel(mass);
    if (fuel < 0) {
        return 0;
    } else {
        return fuel + rocket_limit(fuel);
    }
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var total: i32 = 0;
    var limit: i32 = 0;
    while (reader.takeDelimiterExclusive('\n')) |line| {
        reader.toss(1);
        const mass = try std.fmt.parseInt(i32, line, 10);
        total += required_fuel(mass);
        limit += rocket_limit(mass);
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    try writer.print("{d}\n", .{total});
    try writer.print("{d}\n", .{limit});
    try writer.flush();
}

test "required_fuel" {
    try std.testing.expectEqual(required_fuel(12), 2);
    try std.testing.expectEqual(required_fuel(14), 2);
    try std.testing.expectEqual(required_fuel(1969), 654);
    try std.testing.expectEqual(required_fuel(100756), 33583);
}

test "rocket_limit" {
    try std.testing.expectEqual(rocket_limit(12), 2);
    try std.testing.expectEqual(rocket_limit(14), 2);
    try std.testing.expectEqual(rocket_limit(1969), 966);
    try std.testing.expectEqual(rocket_limit(100756), 50346);
}

test "solve" {
    const in =
        \\12
        \\14
        \\1969
        \\100756
        \\
    ;
    const out =
        \\34241
        \\51316
        \\
    ;
    var buf: [255]u8 = undefined;
    var r: std.Io.Reader = .fixed(in);
    var w: std.Io.Writer = .fixed(&buf);
    try solve(&r, &w);
    try std.testing.expectEqualStrings(out, w.buffered());
}
