const std = @import("std");

pub fn grand_total_B(outer: std.mem.Allocator, lines: [][]u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(outer);
    defer arena.deinit();
    const allocator = arena.allocator();

    var operations: std.ArrayList(u8) = .{};

    if (lines.len < 1) {
        return error.NoMoreLines;
    }

    var it = std.mem.splitScalar(u8, lines[lines.len - 1], ' ');
    while (it.next()) |n| {
        if (n.len > 0) {
            if (n[0] == '*' or n[0] == '+') {
                try operations.append(allocator, n[0]);
            } else {
                return error.What;
            }
        }
    }

    var op: u64 = 0;
    var acc: u64 = 0;
    if (operations.items[op] == '+') {
        acc = 0;
    } else {
        acc = 1;
    }
    var total: u64 = 0;
    for (0..lines[0].len) |i| {
        var n: std.ArrayList(u8) = .{};
        for (0..lines.len - 1) |j| {
            if (lines[j][i] != ' ') {
                try n.append(allocator, lines[j][i]);
            }
        }
        if (n.items.len > 0) {
            const num = try std.fmt.parseInt(u64, n.items, 10);
            if (operations.items[op] == '+') {
                acc += num;
            } else {
                acc *= num;
            }
        } else {
            total += acc;
            op += 1;
            if (operations.items[op] == '+') {
                acc = 0;
            } else {
                acc = 1;
            }
        }
    }
    total += acc;

    return total;
}

pub fn grand_total_A(outer: std.mem.Allocator, lines: [][]u8) !u64 {
    var arena = std.heap.ArenaAllocator.init(outer);
    defer arena.deinit();
    const allocator = arena.allocator();

    var all: std.ArrayList(std.ArrayList(u64)) = .{};
    var operations: std.ArrayList(u8) = .{};

    for (lines) |l| {
        var nums: std.ArrayList(u64) = .{};
        var it = std.mem.splitScalar(u8, l, ' ');
        while (it.next()) |n| {
            if (n.len > 0) {
                if (n[0] == '*' or n[0] == '+') {
                    try operations.append(allocator, n[0]);
                } else {
                    const num = try std.fmt.parseInt(u64, n, 10);
                    try nums.append(allocator, num);
                }
            }
        }
        if (nums.items.len > 0) {
            try all.append(allocator, nums);
        }
    }

    var total: u64 = 0;
    for (operations.items, 0..) |operation, i| {
        if (operation == '*') {
            var mult: u64 = 1;
            for (all.items) |nums| {
                mult *= nums.items[i];
            }
            total += mult;
        } else if (operation == '+') {
            var add: u64 = 0;
            for (all.items) |nums| {
                add += nums.items[i];
            }
            total += add;
        }
    }
    return total;
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var lines: std.ArrayList([]u8) = .{};
    defer lines.deinit(allocator);
    while (reader.takeDelimiterExclusive('\n')) |line| {
        reader.toss(1);
        const line_copy = try allocator.create([1024 * 8]u8);
        std.mem.copyForwards(u8, line_copy, line);
        try lines.append(allocator, line_copy[0..line.len]);
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    try writer.print("{}\n", .{try grand_total_A(allocator, lines.items)});
    try writer.print("{}\n", .{try grand_total_B(allocator, lines.items)});
    try writer.flush();
}

test "grand_total" {
    const allocator = std.testing.allocator;
    var lines: std.ArrayList([]u8) = .{};
    defer lines.deinit(allocator);
    const line0 = "123 328  51 64 ";
    const line1 = " 45 64  387 23 ";
    const line2 = "  6 98  215 314";
    const line3 = "*   +   *   +";
    var line0m: [line0.len]u8 = line0.*;
    var line1m: [line1.len]u8 = line1.*;
    var line2m: [line2.len]u8 = line2.*;
    var line3m: [line3.len]u8 = line3.*;
    try lines.append(allocator, line0m[0..]);
    try lines.append(allocator, line1m[0..]);
    try lines.append(allocator, line2m[0..]);
    try lines.append(allocator, line3m[0..]);
    try std.testing.expectEqual(4277556, grand_total_A(allocator, lines.items));
    try std.testing.expectEqual(3263827, grand_total_B(allocator, lines.items));
}
