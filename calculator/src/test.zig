const std = @import("std");
const calc = @import("main.zig");
const testing = std.testing;

test "to postfix notation" {
    // "1 2 3 + 4 × + 5 -"
    // 无空格的
    const values = try calc.toPostfix("1+((2+3)*4)-5");
    var vals = std.ArrayList(u8).init(std.heap.page_allocator);
    for (values) |token| {
        try vals.appendSlice(token);
    }
    const isEqu = std.mem.eql(u8, vals.items, "123+4*+5-");
    try testing.expect(isEqu);
    // 有空格
    const values2 = try calc.toPostfix("1 + ((2 + 3) * 4) - 5");
    var vals2 = std.ArrayList(u8).init(std.heap.page_allocator);
    for (values2) |token| {
        try vals2.appendSlice(token);
    }
    const isEqu2 = std.mem.eql(u8, vals2.items, "123+4*+5-");
    try testing.expect(isEqu2);
}

test "calculate" {
    const result = try calc.calculate(try calc.toPostfix("1+((2+3)*4)-5"));
    try testing.expectEqual(result, 14);
    try testing.expectEqual(result, 16);
}
