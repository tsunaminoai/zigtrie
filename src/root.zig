const std = @import("std");
const testing = std.testing;

pub fn Trie(comptime T: type) type {
    const TrieNode = struct {
        children: [26]?*TN = [1]?*TN{null} ** 26,
        value: T,
        is_word: bool = false,

        const TN = @This();

        pub fn init(alloc: std.mem.Allocator, value: T) !*TN {
            const tn = try alloc.create(TN);
            tn.* = TN{
                .value = value,
            };
            return tn;
        }
    };
    return struct {
        arena: std.heap.ArenaAllocator,
        root: *TrieNode,

        num_words: usize = 0,
        num_nodes: usize = 0,
        const Self = @This();

        pub fn init(alloc: std.mem.Allocator) !Self {
            var arena = std.heap.ArenaAllocator.init(alloc);
            const child_alloc = arena.allocator();

            return Self{
                .root = try TrieNode.init(child_alloc, 'X'),
                .arena = arena,
            };
        }
        pub fn deinit(self: *Self) void {
            self.arena.deinit();
        }
        pub fn insert_word(self: *Self, word: []const u8) !void {
            var current_node = self.root;
            const alloc = self.arena.allocator();

            for (word, 0..) |char, i| {
                const index = char - 'a';
                if (current_node.children[index]) |child| current_node = child else {
                    const new_node = try TrieNode.init(alloc, char);
                    current_node.children[char - 'a'] = new_node;
                    current_node = new_node;
                    self.num_nodes += 1;
                }
                if (i == word.len - 1) {
                    current_node.is_word = true;
                    self.num_words += 1;
                }
            }
        }
        fn print_node(self: Self, node: *TrieNode, prefix: []u8, len: usize) void {
            prefix[len] = node.value;
            // std.debug.print("{s}", .{prefix});
            if (node.is_word) std.debug.print("{s}\n", .{prefix[1..]});
            for (node.children) |child| {
                if (child) |kid| self.print_node(kid, prefix, len + 1);
            }
            prefix[len] = 0;
        }
        pub fn print_contents(self: Self) !void {
            var buffer = [_]u8{0} ** 50;
            self.print_node(self.root, &buffer, 0);
        }

        pub fn contains_word(self: Self, word: []const u8) bool {
            var current_node = self.root;
            for (word, 0..) |char, i| {
                const index = char - 'a';
                if (current_node.children[index]) |child| current_node = child;
                if (i == word.len - 1) return current_node.is_word;
            }
            return false;
        }
    };
}

test "Trie()" {
    const alloc = testing.allocator;
    var t = try Trie(u8).init(alloc);
    defer t.deinit();
    //std.debug.print("{any}\n", .{t.root.children.items});

    try t.insert_word("wife");
    try t.insert_word("wine");
    try t.insert_word("wines");
    try t.print_contents();

    try testing.expectEqual(t.contains_word("wine"), true);
    try testing.expectEqual(t.contains_word("tree"), false);
}
