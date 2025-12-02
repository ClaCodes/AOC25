const std = @import("std");

pub fn count_digits(n: u64) u64 {
    var n2: u64 = n;
    var i: u64 = 1;
    while (n2 >= 10) {
        n2 = @divTrunc(n2, 10);
        i += 1;
    }
    return i;
}

pub fn split_equal(n: u64, s: u64) bool {
    var n2: u64 = n;
    const factor: u64 = std.math.pow(u64, 10, s);
    const lowest = @rem(n2, factor);
    const l2 = @divFloor(lowest, std.math.pow(u64, 10, s - 1));
    if (l2 == 0) {
        return false;
    }
    while (n2 > factor) {
        n2 = @divFloor(n2, factor);
        const low = @rem(n2, factor);
        if (low != lowest) {
            return false;
        }
    }
    return n2 == lowest;
}

pub fn is_valid(n: u64) bool {
    const count: u64 = count_digits(n);
    if (@mod(count, 2) != 0) {
        return true;
    }
    return !split_equal(n, @divExact(count, 2));
}

pub fn is_validB(n: u64) bool {
    var count: u64 = count_digits(n) - 1;
    while (count > 0) {
        if (split_equal(n, count)) {
            return false;
        }
        count -= 1;
    }
    return true;
}

pub fn sum_rangeA(a: u64, b: u64) u64 {
    var total: u64 = 0;
    var i: u64 = a;
    while (i <= b) {
        if (!is_valid(i)) {
            total += i;
        }
        i += 1;
    }
    return total;
}

pub fn sum_rangeB(a: u64, b: u64) u64 {
    var total: u64 = 0;
    var i: u64 = a;
    while (i <= b) {
        if (!is_validB(i)) {
            total += i;
        }
        i += 1;
    }
    return total;
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var totalA: u64 = 0;
    var totalB: u64 = 0;
    while (reader.takeDelimiterExclusive('\n')) |line| {
        reader.toss(1);
        var it = std.mem.splitScalar(u8, line, ',');
        while (it.next()) |x| {
            var it2 = std.mem.splitScalar(u8, x, '-');
            const first = try std.fmt.parseInt(u64, it2.next().?, 10);
            const second = try std.fmt.parseInt(u64, it2.next().?, 10);
            totalA += sum_rangeA(first, second);
            totalB += sum_rangeB(first, second);
        }
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

test "count_digits" {
    try std.testing.expectEqual(1, count_digits(0));
    try std.testing.expectEqual(1, count_digits(1));
    try std.testing.expectEqual(1, count_digits(8));
    try std.testing.expectEqual(2, count_digits(81));
    try std.testing.expectEqual(3, count_digits(239));
    try std.testing.expectEqual(4, count_digits(9999));
    try std.testing.expectEqual(4, count_digits(1010));
    try std.testing.expectEqual(6, count_digits(123123));
    try std.testing.expectEqual(10, count_digits(9812398234));
}

test "split_equal" {
    try std.testing.expectEqual(true, split_equal(1010, 2));
    try std.testing.expectEqual(false, split_equal(10, 1));
    try std.testing.expectEqual(true, split_equal(10, 2));
    try std.testing.expectEqual(false, split_equal(101, 1));
    try std.testing.expectEqual(false, split_equal(101, 2));
}

test "is_valid counter examples" {
    try std.testing.expectEqual(false, is_valid(11));
    try std.testing.expectEqual(false, is_valid(22));
    try std.testing.expectEqual(false, is_valid(99));
    try std.testing.expectEqual(false, is_valid(1010));
    try std.testing.expectEqual(false, is_valid(11851185));
    try std.testing.expectEqual(false, is_valid(222222));
    try std.testing.expectEqual(false, is_valid(446446));
    try std.testing.expectEqual(false, is_valid(38593859));
}

test "is_validB counter examples" {
    try std.testing.expectEqual(false, is_validB(11));
    try std.testing.expectEqual(false, is_validB(22));
    try std.testing.expectEqual(false, is_validB(99));
    try std.testing.expectEqual(false, is_validB(1010));
    try std.testing.expectEqual(false, is_validB(11851185));
    try std.testing.expectEqual(false, is_validB(222222));
    try std.testing.expectEqual(false, is_validB(446446));
    try std.testing.expectEqual(false, is_validB(38593859));
    try std.testing.expectEqual(false, is_validB(12341234));
    try std.testing.expectEqual(false, is_validB(123123123));
    try std.testing.expectEqual(false, is_validB(1212121212));
    try std.testing.expectEqual(false, is_validB(1111111));
}

test "is_validB examples" {
    try std.testing.expectEqual(true, is_validB(10));
    try std.testing.expectEqual(true, is_validB(21));
    try std.testing.expectEqual(true, is_validB(98));
    try std.testing.expectEqual(true, is_validB(1009));
    try std.testing.expectEqual(true, is_validB(11851184));
    try std.testing.expectEqual(true, is_validB(222221));
    try std.testing.expectEqual(true, is_validB(446445));
    try std.testing.expectEqual(true, is_validB(38593858));
    try std.testing.expectEqual(true, is_validB(12341233));
    try std.testing.expectEqual(true, is_validB(123123122));
    try std.testing.expectEqual(true, is_validB(1212121211));
    try std.testing.expectEqual(true, is_validB(1111110));
}

test "is_validB examples range" {
    try std.testing.expectEqual(true, is_validB(95));
    try std.testing.expectEqual(true, is_validB(96));
    try std.testing.expectEqual(true, is_validB(97));
    try std.testing.expectEqual(true, is_validB(98));
    try std.testing.expectEqual(false, is_validB(99));
    try std.testing.expectEqual(true, is_validB(100));
    try std.testing.expectEqual(true, is_validB(101));
    try std.testing.expectEqual(true, is_validB(102));
    try std.testing.expectEqual(true, is_validB(103));
    try std.testing.expectEqual(true, is_validB(104));
    try std.testing.expectEqual(true, is_validB(105));
    try std.testing.expectEqual(true, is_validB(106));
    try std.testing.expectEqual(true, is_validB(107));
    try std.testing.expectEqual(true, is_validB(108));
    try std.testing.expectEqual(true, is_validB(109));
    try std.testing.expectEqual(true, is_validB(110));
    try std.testing.expectEqual(false, is_validB(111));
    try std.testing.expectEqual(true, is_validB(112));
    try std.testing.expectEqual(true, is_validB(113));
    try std.testing.expectEqual(true, is_validB(114));
    try std.testing.expectEqual(true, is_validB(115));
}

test "sum_rangeA" {
    try std.testing.expectEqual(33, sum_rangeA(11, 22));
    try std.testing.expectEqual(99, sum_rangeA(95, 115));
    try std.testing.expectEqual(1010, sum_rangeA(998, 1012));
    try std.testing.expectEqual(1188511885, sum_rangeA(1188511880, 1188511890));
    try std.testing.expectEqual(222222, sum_rangeA(222220, 222224));
    try std.testing.expectEqual(0, sum_rangeA(1698522, 1698528));
    try std.testing.expectEqual(446446, sum_rangeA(446443, 446449));
    try std.testing.expectEqual(38593859, sum_rangeA(38593856, 38593862));
    try std.testing.expectEqual(0, sum_rangeA(565653, 565659));
    try std.testing.expectEqual(0, sum_rangeA(824824821, 824824827));
    try std.testing.expectEqual(0, sum_rangeA(2121212118, 2121212124));
}

test "sum_rangeB" {
    try std.testing.expectEqual(33, sum_rangeB(11, 22));
    try std.testing.expectEqual(210, sum_rangeB(95, 115));
    try std.testing.expectEqual(2009, sum_rangeB(998, 1012));
}
