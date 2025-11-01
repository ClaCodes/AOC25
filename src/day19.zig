const std = @import("std");

pub fn solve(reader: *std.Io.Reader, writer: *std.Io.Writer) !void {
    while (reader.takeDelimiterExclusive('\n')) |line| {
        reader.toss(1);
        try writer.print("{s}\n", .{line});
    } else |err| switch (err) {
        error.EndOfStream => {},
        error.StreamTooLong,
        error.ReadFailed,
        => |e| return e,
    }
    try writer.flush();
}

test "solve" {
    const in =
        \\TEST
        \\
    ;
    const out =
        \\TEST
        \\
    ;
    var buf: [255]u8 = undefined;
    var r: std.Io.Reader = .fixed(in);
    var w: std.Io.Writer = .fixed(&buf);
    try solve(&r, &w);
    try std.testing.expectEqualStrings(out, w.buffered());
}
