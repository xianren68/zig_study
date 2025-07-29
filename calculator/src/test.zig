const std = @import("std");
const calc = @import("main.zig");
const testing = std.testing;

test "to postfix notation" {
    // "1 2 3 + 4 × + 5 -"
    //
    const values = try calc.toPostfix("1+((2+3)*4)-5");
    var vals = std.ArrayList(u8).init(std.heap.page_allocator);
    for (values) |token| {
        try vals.appendSlice(token);
    }
    const isEqu = std.mem.eql(u8, vals.items, "123+4*+5-");
    try testing.expect(isEqu);
}
