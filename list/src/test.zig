const std = @import("std");
const testing = std.testing;
const List = @import("lib.zig").List;
test "list init" {
    var list = try List(u8, 10).init(std.testing.allocator);
    defer list.deinit();
    list.items[0] = 1;
    try testing.expectEqual(list.items[0], 1);
}

test "list push" {
    var list = try List(u8, 3).init(std.testing.allocator);
    defer list.deinit();
    try list.push(1);
    try list.push(2);
    try list.push(3);
    try testing.expectEqual(list.len(), 3);
    try testing.expect(std.mem.eql(u8, list.items, &[_]u8{ 1, 2, 3 }));
    try list.push(4);
    try list.push(5);
    try list.push(6);
    try testing.expectEqual(list.len(), 6);
    try testing.expect(std.mem.eql(u8, list.items, &[_]u8{ 1, 2, 3, 4, 5, 6 }));
}

test "list pop" {
    var list = try List(u8, 6).init(std.testing.allocator);
    defer list.deinit();
    try list.push(1);
    try list.push(2);
    try list.push(3);
    try list.push(4);
    try list.push(5);
    try list.push(6);
    try testing.expectEqual(list.pop(), 6);
    try testing.expectEqual(list.pop(), 5);
    try testing.expectEqual(list.pop(), 4);
    try testing.expectEqual(list.pop(), 3);
    try testing.expectEqual(list.pop(), 2);
    try testing.expectEqual(list.pop(), 1);
    try testing.expectEqual(list.len(), 0);
    try testing.expectEqual(list.pop(), null);
}

test "list appendSlice" {
    var list = try List(u8, 3).init(std.testing.allocator);
    defer list.deinit();
    try list.appendSlice(&[_]u8{ 1, 2, 3 });
    try testing.expectEqual(list.len(), 3);
    try testing.expect(std.mem.eql(u8, list.items, &[_]u8{ 1, 2, 3 }));
    try list.appendSlice(&[_]u8{ 4, 5, 6 });
    try testing.expectEqual(list.len(), 6);
    try testing.expect(std.mem.eql(u8, list.items, &[_]u8{ 1, 2, 3, 4, 5, 6 }));
}
