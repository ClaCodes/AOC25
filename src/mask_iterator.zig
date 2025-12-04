const std = @import("std");

pub fn count_bits(mask: u64) u7 {
    var count: u7 = 0;
    var i: u6 = 0;
    const one: u64 = 1;
    while (i < 63) {
        if ((mask & (one << i)) != 0) {
            count += 1;
        }
        i += 1;
    }
    if ((mask & (one << 63)) != 0) {
        count += 1;
    }
    return count;
}

pub fn right_most(mask: u64) !u64 {
    var i: u6 = 0;
    const one: u64 = 1;
    while (i < 63) {
        if ((mask & (one << i)) != 0) {
            return (one << i);
        }
        i += 1;
    }
    if ((mask & (one << 63)) != 0) {
        return (one << 63);
    }
    return error.EndOfStream;
}

pub fn fill_to(mask: u64, count: u7) u64 {
    var already = count_bits(mask);
    var n = mask;
    var i: u6 = 0;
    const one: u64 = 1;
    while (already < count) {
        if ((n & (one << i)) == 0) {
            already += 1;
            n |= (one << i);
        }
        i += 1;
    }
    return n;
}

pub fn next_mask(mask: u64) !u64 {
    const already = count_bits(mask);
    const right_most_bit = try right_most(mask);
    const new_mask = try std.math.add(u64, mask, right_most_bit);
    return fill_to(new_mask, already);
}

const MaskIterator = struct {
    state: u64,
    pub fn next(self: *MaskIterator) !u64 {
        const old = self.state;
        self.state = try next_mask(self.state);
        return old;
    }
};

test "count_bits" {
    try std.testing.expectEqual(0, count_bits(0));
    try std.testing.expectEqual(2, count_bits(0b0011));
    try std.testing.expectEqual(2, count_bits(0b0101));
    try std.testing.expectEqual(2, count_bits(0b0110));
    try std.testing.expectEqual(2, count_bits(0b1001));
    try std.testing.expectEqual(2, count_bits(0b1010));
    try std.testing.expectEqual(4, count_bits(0b1111));
    try std.testing.expectEqual(64, count_bits(0b1111111111111111111111111111111111111111111111111111111111111111));
}

test "right_most" {
    try std.testing.expectError(error.EndOfStream, right_most(0));
    try std.testing.expectEqual(0b01, right_most(0b1111));
    try std.testing.expectEqual(0b10, right_most(0b1110));
    try std.testing.expectEqual(0b0000100000000, right_most(0b1110100000000));
    try std.testing.expectEqual(0b1000000000000000000000000000000000000000000000000000000000000000, right_most(0b1000000000000000000000000000000000000000000000000000000000000000));
}

test "fill_to" {
    try std.testing.expectEqual(0b11, fill_to(0b0, 2));
    try std.testing.expectEqual(0b11, fill_to(0b11, 2));
    try std.testing.expectEqual(0b1111, fill_to(0b0, 4));
    try std.testing.expectEqual(0b111100000000, fill_to(0b111100000000, 4));
    try std.testing.expectEqual(0b111100000001, fill_to(0b111100000000, 5));
    try std.testing.expectEqual(0b111100000011, fill_to(0b111100000001, 6));
}

test "next_mask" {
    try std.testing.expectEqual(0b0101, try next_mask(0b0011));
    try std.testing.expectEqual(0b0110, try next_mask(0b0101));
    try std.testing.expectEqual(0b1001, try next_mask(0b0110));
    try std.testing.expectEqual(0b1010, try next_mask(0b1001));
    try std.testing.expectEqual(0b1100, try next_mask(0b1010));
}

test "MaskIterator 12" {
    var m = MaskIterator{ .state = 0b00111111111111 };
    try std.testing.expectEqual(0b00111111111111, m.next());
    try std.testing.expectEqual(0b01011111111111, m.next());
    try std.testing.expectEqual(0b01101111111111, m.next());
    try std.testing.expectEqual(0b01110111111111, m.next());
    try std.testing.expectEqual(0b01111011111111, m.next());
    try std.testing.expectEqual(0b01111101111111, m.next());
    try std.testing.expectEqual(0b01111110111111, m.next());
    try std.testing.expectEqual(0b01111111011111, m.next());
    try std.testing.expectEqual(0b01111111101111, m.next());
    try std.testing.expectEqual(0b01111111110111, m.next());
    try std.testing.expectEqual(0b01111111111011, m.next());
    try std.testing.expectEqual(0b01111111111101, m.next());
    try std.testing.expectEqual(0b01111111111110, m.next());
    try std.testing.expectEqual(0b10011111111111, m.next());
    try std.testing.expectEqual(0b10101111111111, m.next());
    try std.testing.expectEqual(0b10110111111111, m.next());
}
