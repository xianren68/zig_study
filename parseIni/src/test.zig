const std = @import("std");
const testing = std.testing;
const Ini = @import("lib.zig");
const IniConfig = Ini.IniConfig;
const IniError = Ini.IniError;
const globalConfig = struct {
    name: []const u8,
    age: u32,
    sex: []const u8 = "male",
    isMarried: bool,
};
const baseConfig = struct {
    name: []const u8,
    age: u32,
    sex: []const u8 = "male",
};

const address = struct {
    street: []const u8,
    city: []const u8,
    state: []const u8,
    zip: []const u8,
    is_active: bool,
};

test "parse ini file" {
    var cfg = try IniConfig.Parse("test.ini");
    try testing.expect(cfg.section("hello") == null);
    var base_config = cfg.section("").?;
    try testing.expectEqualStrings("xianren", base_config.key("name").?);
    try testing.expectEqualStrings("25", base_config.key("age").?);
    try testing.expect(base_config.key("hello") == null);
    var address_config = cfg.section("address").?;
    try testing.expectEqualStrings("Anytown", address_config.key("city").?);
    const base_model = try base_config.bind_model(baseConfig);
    try testing.expectEqualStrings("xianren", base_model.name);
    try testing.expectEqual(25, base_model.age);
    try testing.expectEqualStrings("male", base_model.sex);
    try testing.expectError(IniError.MissingField, base_config.bind_model(globalConfig));
    const address_model = try address_config.bind_model(address);
    try testing.expectEqualStrings("123 Main St", address_model.street);
    try testing.expectEqualStrings("Anytown", address_model.city);
    try testing.expectEqualStrings("CA", address_model.state);
    try testing.expectEqualStrings("12345", address_model.zip);
    try testing.expectEqual(true, address_model.is_active);
}
