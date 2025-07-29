const std = @import("std");

// 计算优先级
// 1. 括号优先级最高，先计算括号内的表达式
// 2. 然后计算乘除法
// 3. 最后计算加减法

pub fn main() !void {
    // 从标准输入流获取字符串
    var str = try std.io.getStdIn().readUntilDelimiterAlloc(std.heap.page_allocator, '\n', 1024);
    // 去除空格
    str = std.mem.trim(u8, str, " ");
    // 后缀字符串
}

// 将字符串转化为后缀表达式子
pub fn toPostfix(str: []const u8) ![][]const u8 {
    var map = std.StringHashMap(i32).init(std.heap.page_allocator);
    // 输入等级
    map.put("+", 1) catch unreachable;
    map.put("-", 1) catch unreachable;
    map.put("*", 2) catch unreachable;
    map.put("/", 2) catch unreachable;
    map.put(")", 3) catch unreachable;
    map.put("(", 0) catch unreachable;
    var s1 = std.ArrayList([]const u8).init(std.heap.page_allocator);
    var s2 = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer {
        s1.deinit();
        s2.deinit();
    }
    var i: usize = 0;
    while (i < str.len) {
        var num = std.ArrayList(u8).init(std.heap.page_allocator);
        while (i < str.len and str[i] >= '0' and str[i] <= '9') {
            num.append(str[i]) catch unreachable;
            i += 1;
        }
        if (num.items.len > 0) {
            s1.append(num.toOwnedSlice() catch unreachable) catch unreachable;
            num.clearAndFree();
        }
        if (i == str.len) {
            break;
        }

        if (s2.items.len == 0 or str[i] == '(') {
            const s22 = std.heap.page_allocator.alloc(u8, 1) catch unreachable;
            s22[0] = str[i];
            s2.append(s22) catch unreachable;
        } else if (str[i] == ')') {
            while (s2.items.len > 0) {
                const last = s2.pop();
                if (last[0] == '(') {
                    break;
                }
                s1.append(last) catch unreachable;
            }
        } else {
            while (s2.items.len > 0 and map.get(s2.getLast()) != null and map.get(s2.getLast()).? >= map.get(&[_]u8{str[i]}).?) {
                s1.append(s2.pop()) catch unreachable;
            }
            const s11 = std.heap.page_allocator.alloc(u8, 1) catch unreachable;
            s11[0] = str[i];
            s2.append(s11) catch unreachable;
        }
        i += 1;
    }
    try s1.appendSlice(try s2.toOwnedSlice());
    return s1.toOwnedSlice();
}

// 将后缀表达式子计算结果
pub fn calculate(postfix: [][]const u8) !f64 {
    var stack = std.ArrayList(f64).init(std.heap.page_allocator);
    defer stack.deinit();
    for (postfix) |token| {
        if (token[0] >= '0' and token[0] <= '9') {
            try stack.push(f64.parse(token));
        } else {
            const b = try stack.pop();
            const a = try stack.pop();
            switch (token[0]) {
                '+' => try stack.push(a + b),
                '-' => try stack.push(a - b),
                '*' => try stack.push(a * b),
                '/' => try stack.push(a / b),
                else => unreachable,
            }
        }
    }
    return stack.pop();
}
