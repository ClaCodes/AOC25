const std = @import("std");
const bf = @import("bit_field.zig");

const solution = struct {
    split_count: u64,
    beam_count: u64,
};

pub fn count_splits(splitters: *bf.BitField2d, startX: u64, startY: u64, max_y: u64) solution {
    var beam_count = std.mem.zeroes([512]u64);
    var old_beam_count = std.mem.zeroes([512]u64);
    beam_count[startX] = 1;
    var y: u64 = startY;
    var s: solution = .{ .split_count = 0, .beam_count = 0 };
    while (y <= max_y) : (y += 1) {
        old_beam_count = std.mem.zeroes(@TypeOf(old_beam_count));
        for (beam_count, 0..) |b, i| {
            old_beam_count[i] = b;
        }
        beam_count = std.mem.zeroes(@TypeOf(beam_count));
        for (0..splitters.width) |x| {
            const beam_at_x: u64 = old_beam_count[x];
            if (beam_at_x < 1) continue;
            const splitting = splitters.get(x, y) catch unreachable;
            if (splitting) {
                s.split_count += 1;
                beam_count[x - 1] += beam_at_x;
                beam_count[x + 1] += beam_at_x;
            } else {
                beam_count[x] += beam_at_x;
            }
        }
    }
    for (beam_count) |c| {
        s.beam_count += c;
    }
    return s;
}

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    var y: u64 = 0;
    var startX: u64 = 0;
    var startY: u64 = 0;
    var data = std.mem.zeroes([512]u64);
    const b: bf.BitField = .{ .data = data[0..] };
    var splitters: bf.BitField2d = .{ .field = b, .width = 0 };
    while (reader.takeDelimiterExclusive('\n')) |line| : (y += 1) {
        splitters.width = line.len;
        reader.toss(1);
        for (line, 0..) |c, x| {
            switch (c) {
                'S' => {
                    startX = x;
                    startY = y;
                },
                '^' => {
                    try splitters.set(x, y);
                },
                '.' => {},
                else => unreachable,
            }
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    const s = count_splits(&splitters, startX, startY, y);
    try writer.print("{}\n", .{s.split_count});
    try writer.print("{}\n", .{s.beam_count});
    try writer.flush();
}

test "solve" {
    const in =
        \\.......S.......
        \\...............
        \\.......^.......
        \\...............
        \\......^.^......
        \\...............
        \\.....^.^.^.....
        \\...............
        \\....^.^...^....
        \\...............
        \\...^.^...^.^...
        \\...............
        \\..^...^.....^..
        \\...............
        \\.^.^.^.^.^...^.
        \\...............
        \\
    ;
    const out =
        \\21
        \\40
        \\
    ;
    var buf: [1024 * 1024 * 24]u8 = undefined;
    var r: std.Io.Reader = .fixed(in);
    var w: std.Io.Writer = .fixed(&buf);
    try solve(&r, &w);
    try std.testing.expectEqualStrings(out, w.buffered());
}
