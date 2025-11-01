const std = @import("std");
const AOC25 = @import("AOC25");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("inputs/input01", .{ .mode = .read_only });
    defer file.close();

    var read_buf: [1024]u8 = undefined;
    var file_reader: std.fs.File.Reader = file.reader(&read_buf);

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);

    try AOC25.solve01(&file_reader.interface, &stdout_writer.interface);
}
