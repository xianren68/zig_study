const std = @import("std");
pub const IniError = error{
    InvalidKey,
    InvalidValue,
    SectionNotFound,
    InvalidType,
    NotFoundKey,
    NotFoundSection,
    MissingField,
};
const Section = struct {
    name: []const u8,
    keys: std.StringHashMap([]const u8),
    pub fn key(self: *Section, k: []const u8) ?[]const u8 {
        return self.keys.get(k);
    }
    pub fn bind_model(self: *Section, comptime T: type) !T {
        const type_info = @typeInfo(T);
        if (type_info != .Struct) {
            return IniError.InvalidType;
        }
        const fields = type_info.Struct.fields;
        var config: T = undefined;
        inline for (fields) |field| {
            const field_name = field.name;
            const field_type = field.type;
            const field_value = self.key(field_name);
            if (field_value == null) {
                if (field.default_value) |default_ptr| {
                    // 将anyopaque指针转换为具体类型的指针
                    const default_value_ptr: *const field_type = @ptrCast(@alignCast(default_ptr));
                    // 然后赋值：将默认值赋给字段
                    @field(config, field.name) = default_value_ptr.*;
                } else {
                    return IniError.MissingField;
                }
            } else {
                try assign_field(&@field(config, field_name), field_type, field_value.?);
            }
        }
        return config;
    }
    fn assign_field(field_ptr: anytype, comptime FieldType: type, value: []const u8) !void {
        const file_info = @typeInfo(FieldType);
        switch (file_info) {
            .Int => {
                field_ptr.* = try std.fmt.parseInt(FieldType, value, 10);
            },
            .Float => {
                field_ptr.* = try std.fmt.parseFloat(FieldType, value);
            },
            .Bool => {
                field_ptr.* = std.mem.eql(u8, value, "true") or
                    std.mem.eql(u8, value, "1") or
                    std.mem.eql(u8, value, "yes");
            },
            .Pointer => |ptr_info| {
                if (ptr_info.size != .Slice or ptr_info.child != u8 or !ptr_info.is_const) {
                    return IniError.InvalidType;
                }
                field_ptr.* = value;
            },
            else => return IniError.InvalidType,
        }
    }
};

pub const IniConfig = struct {
    data: std.StringHashMap(std.StringHashMap([]const u8)),
    pub fn Parse(path: []const u8) !IniConfig {
        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();
        var buf_reader = std.io.bufferedReader(file.reader());
        var reader = buf_reader.reader();
        var ini_config = IniConfig{
            .data = std.StringHashMap(std.StringHashMap([]const u8)).init(std.heap.page_allocator),
        };
        var current_section: []const u8 = "";
        try ini_config.data.put("", std.StringHashMap([]const u8).init(std.heap.page_allocator));
        // 按行读取
        while (try reader.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', 1024)) |line| {
            // 处理每一行
            var ln = line[0 .. line.len - 1];
            if (ln.len == 0) continue;
            if (ln[0] == '[') {
                std.heap.page_allocator.free(current_section);
                current_section = ln[1 .. ln.len - 1];
                try ini_config.data.put(current_section, std.StringHashMap([]const u8).init(std.heap.page_allocator));
            } else {
                const index = std.mem.indexOfScalar(u8, ln, '=');
                if (index == null) continue;
                const key = ln[0..index.?];
                const value = ln[index.? + 1 .. ln.len];
                try ini_config.data.getPtr(current_section).?.put(key, value);
            }
        }
        return ini_config;
    }
    pub fn section(self: *IniConfig, name: []const u8) ?Section {
        if (self.data.get(name)) |sec| {
            return Section{ .keys = sec, .name = name };
        }
        return null;
    }
};
