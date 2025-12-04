const std = @import("std");

pub fn greedy_find(line: []const u8) u64 {
    var needle: u8 = 9;
    while (needle > 0) : (needle -= 1) {
        for (line, 0..) |c, i| {
            if (c - '0' == needle) {
                return i;
            }
        }
    }
    unreachable;
}

pub fn greedy_find_v(line: []const u8) u8 {
    const i = greedy_find(line);
    return line[i] - '0';
}

pub fn max_joltage(line: []const u8, depth: u64) u64 {
    const to_go = depth - 1;
    const i = greedy_find(line[0 .. line.len - to_go]);
    const v = line[i] - '0';
    if (to_go == 0) {
        return v;
    }
    return std.math.pow(u64, 10, to_go) * v + max_joltage(line[i + 1 ..], to_go);
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var totalA: u64 = 0;
    var totalB: u64 = 0;
    while (reader.takeDelimiterExclusive('\n')) |line| {
        reader.toss(1);
        totalA += max_joltage(line, 2);
        totalB += max_joltage(line, 12);
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    try writer.print("{}\n", .{totalA});
    try writer.print("{}\n", .{totalB});
    try writer.flush();
}

test "greedy_find_v" {
    try std.testing.expectEqual(9, greedy_find_v("987654321111111"));
    try std.testing.expectEqual(8, greedy_find_v("87654321111111"));
    try std.testing.expectEqual(7, greedy_find_v("7654321111111"));
    try std.testing.expectEqual(9, greedy_find_v("811111111111119"));
    try std.testing.expectEqual(8, greedy_find_v("234234234234278"));
    try std.testing.expectEqual(9, greedy_find_v("818181911112111"));
}

test "max_joltage" {
    try std.testing.expectEqual(98, max_joltage("987654321111111", 2));
    try std.testing.expectEqual(89, max_joltage("811111111111119", 2));
    try std.testing.expectEqual(78, max_joltage("234234234234278", 2));
    try std.testing.expectEqual(92, max_joltage("818181911112111", 2));
    try std.testing.expectEqual(987654321111, max_joltage("987654321111111", 12));
    try std.testing.expectEqual(811111111119, max_joltage("811111111111119", 12));
    try std.testing.expectEqual(434234234278, max_joltage("234234234234278", 12));
    try std.testing.expectEqual(888911112111, max_joltage("818181911112111", 12));
}
