const std = @import("std");
const testing = std.testing;
const IniConfig = @import("lib.zig").IniConfig;

test "parse ini file" {
    var cfg = try IniConfig.Parse("test.ini");
    try testing.expectEqualStrings("xianren", cfg.Section("").Key("name"));
    try testing.expectEqualStrings("25", cfg.Section("").Key("age"));
    try testing.expectEqualStrings("Anytown", cfg.Section("address").Key("city"));
}
