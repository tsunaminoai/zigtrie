const std = @import("std");
const lib = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var t = try lib.Trie(u8).init(alloc);
    defer t.deinit();

    var file = try std.fs.cwd().openFile("english.txt", .{});
    defer file.close();

    var reader = file.reader();
    var idx: usize = 0;
    blk: while (try reader.readUntilDelimiterOrEofAlloc(alloc, '\n', 100_000_000)) |word| {
        defer alloc.free(word);
        for (word) |char| if (char > 'z' or char < 'a') continue :blk;
        if (idx % 1000 == 0 and idx != 0) {
            std.debug.print("inserting: {s}{s}\r", .{ word, " " ** 20 });
            //break :blk;
        }
        try t.insert_word(word[0 .. word.len - 1]);
        idx += 1;
    }
    std.debug.print("\n", .{});
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Trie contains {} nodes\n", .{t.num_nodes});
    try stdout.print("Trie contains {} words\n", .{t.num_words});
    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
