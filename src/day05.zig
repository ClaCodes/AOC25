const std = @import("std");

const range = struct {
    low: u64,
    high: u64,
};

pub fn id_in_range(id: u64, r: range) bool {
    return id >= r.low and id <= r.high;
}

pub fn in_range(id: u64, rs: []range) bool {
    for (rs) |r| {
        if (id_in_range(id, r)) {
            return true;
        }
    }
    return false;
}

pub fn in_range_count(ids: []u64, rs: []range) u64 {
    var count: u64 = 0;
    for (ids) |id| {
        if (in_range(id, rs)) {
            count += 1;
        }
    }
    return count;
}

pub fn fresh_range(r: range) u64 {
    return r.high + 1 - r.low;
}

pub fn less_than_range(_: void, a: range, b: range) bool {
    if (a.low < b.low) {
        return true;
    } else if (a.low > b.low) {
        return false;
    } else {
        return a.high < b.high;
    }
}
pub fn sort_by_low(rs: []range) void {
    std.mem.sort(range, rs, {}, less_than_range);
}

pub fn normalize(rs: []range) void {
    sort_by_low(rs);
    for (1..rs.len) |i| {
        if (rs[i].low <= rs[i - 1].high and rs[i].high > rs[i - 1].high) {
            rs[i].low = rs[i - 1].high + 1;
        } else if (rs[i].low <= rs[i - 1].high) {
            rs[i].high = rs[i - 1].high; // make sure next iteration works
            rs[i].low = rs[i].high + 1; // rendered useless
        }
    }
}

pub fn fresh(rs: []range) u64 {
    var count: u64 = 0;
    for (rs) |r| {
        count += fresh_range(r);
    }
    return count;
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var phase1: bool = true;
    var rs = std.mem.zeroes([1024]range);
    var ids = std.mem.zeroes([1024]u64);
    var i: u64 = 0;
    var j: u64 = 0;
    while (reader.takeDelimiterExclusive('\n')) |line| {
        reader.toss(1);
        if (phase1) {
            if (line.len == 0) {
                phase1 = false;
                continue;
            }
            var it = std.mem.splitScalar(u8, line, '-');
            var r: range = undefined;
            r.low = try std.fmt.parseInt(u64, it.next().?, 10);
            r.high = try std.fmt.parseInt(u64, it.next().?, 10);
            rs[i] = r;
            i += 1;
        } else {
            ids[j] = try std.fmt.parseInt(u64, line, 10);
            j += 1;
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    try writer.print("{}\n", .{in_range_count(ids[0..j], rs[0..i])});
    normalize(rs[0..i]);
    try writer.print("{}\n", .{fresh(rs[0..i])});
    try writer.flush();
}

test "normalize" {
    var rs = [_]range{
        range{ .low = 3, .high = 5 },
        range{ .low = 3, .high = 4 },
    };
    normalize(rs[0..]);
    try std.testing.expectEqual(3, fresh(rs[0..]));
}
test "normalize2" {
    var rs = [_]range{
        range{ .low = 2, .high = 5 },
        range{ .low = 1, .high = 4 },
    };
    normalize(rs[0..]);
    try std.testing.expectEqual(5, fresh(rs[0..]));
}
test "normalize3" {
    var rs = [_]range{
        range{ .low = 2, .high = 3 },
        range{ .low = 1, .high = 4 },
    };
    normalize(rs[0..]);
    try std.testing.expectEqual(4, fresh(rs[0..]));
}
test "normalize4" {
    var rs = [_]range{
        range{ .low = 1, .high = 4 },
        range{ .low = 1, .high = 4 },
    };
    normalize(rs[0..]);
    try std.testing.expectEqual(4, fresh(rs[0..]));
}
test "normalize5" {
    var rs = [_]range{
        range{ .low = 1, .high = 2 },
        range{ .low = 1, .high = 3 },
        range{ .low = 1, .high = 4 },
        range{ .low = 2, .high = 3 },
        range{ .low = 2, .high = 4 },
        range{ .low = 3, .high = 4 },
    };
    normalize(rs[0..]);
    try std.testing.expectEqual(4, fresh(rs[0..]));
}
test "solve" {
    const in =
        \\3-5
        \\10-14
        \\16-20
        \\12-18
        \\
        \\1
        \\5
        \\8
        \\11
        \\17
        \\32
        \\
    ;
    const out =
        \\3
        \\14
        \\
    ;
    var buf: [255]u8 = undefined;
    var r: std.Io.Reader = .fixed(in);
    var w: std.Io.Writer = .fixed(&buf);
    try solve(&r, &w);
    try std.testing.expectEqualStrings(out, w.buffered());
}
