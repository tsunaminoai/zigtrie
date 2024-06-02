const std = @import("std");
const testing = std.testing;

pub fn Trie(comptime T: type) type {
    const TrieNode = struct {
        children: std.ArrayList(TN),
        value: T,

        const TN = @This();

        pub fn init(alloc: std.mem.Allocator, value: T) !*TN {
            const tn = try alloc.create(TN);
            tn.* = .{
                .value = value,
                .children = std.ArrayList(TN).init(alloc),
            };
            return tn;
        }
    };
    return struct {
        arena: std.heap.ArenaAllocator,
        root: *TrieNode,

        const Self = @This();

        pub fn init(alloc: std.mem.Allocator) !Self {
            var arena = std.heap.ArenaAllocator.init(alloc);
            const child_alloc = arena.allocator();

            return Self{
                .root = try TrieNode.init(child_alloc, 'X'),
                .arena = arena,
            };
        }
        pub fn deinit(self: Self) void {
            self.arena.deinit();
        }
    };
}

test "Trie()" {
    const alloc = testing.allocator;
    var t = try Trie(u8).init(alloc);
    defer t.deinit();
}
