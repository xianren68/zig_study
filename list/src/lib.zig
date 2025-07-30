const std = @import("std");

pub fn List(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: []T,
        len: usize,
        allocator: std.mem.Allocator,
        pub fn init(allocator: std.mem.Allocator) !@This() {
            return .{
                .items = try allocator.alloc(T, capacity),
                .len = 0,
                .allocator = allocator,
            };
        }
        pub fn deinit(self: *@This()) void {
            self.allocator.free(self.items);
        }
        pub fn push(self: *@This(), item: T) !void {
            if (self.len == self.items.len) {
                self.items = try self.allocator.realloc(self.items, self.items.len * 2);
            }
            self.items[self.len] = item;
            self.len += 1;
        }
        pub fn pop(self: *@This()) ?T {
            if (self.len == 0) return null;
            self.len -= 1;
            return self.items[self.len];
        }
    };
}
