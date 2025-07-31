const std = @import("std");

pub fn List(comptime T: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();
        items: []T,
        _len: usize,
        allocator: std.mem.Allocator,
        pub fn init(allocator: std.mem.Allocator) !Self {
            return .{
                .items = try allocator.alloc(T, capacity),
                ._len = 0,
                .allocator = allocator,
            };
        }
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }
        pub fn push(self: *Self, item: T) !void {
            if (self._len == self.items.len) {
                self.items = try self.allocator.realloc(self.items, self.items.len * 2);
            }
            self.items[self._len] = item;
            self._len += 1;
        }
        pub fn pop(self: *Self) ?T {
            if (self._len == 0) return null;
            self._len -= 1;
            return self.items[self._len];
        }
        pub fn len(self: *Self) usize {
            return self._len;
        }
        pub fn appendSlice(self: *Self, slice: []const T) !void {
            if (self._len + slice.len > self.items.len) {
                self.items = try self.allocator.realloc(self.items, self._len + slice.len);
            }
            std.mem.copyForwards(T, self.items[self._len..], slice);
            self._len += slice.len;
        }
    };
}
