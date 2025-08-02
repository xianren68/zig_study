const std = @import("std");

pub const IniConfig = struct {
    data: std.StringHashMap(std.StringHashMap([]const u8)),
    current_section: []const u8,
    pub fn Parse(path: []const u8) !IniConfig {
        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();
        var buf_reader = std.io.bufferedReader(file.reader());
        var reader = buf_reader.reader();
        var ini_config = IniConfig{
            .data = std.StringHashMap(std.StringHashMap([]const u8)).init(std.heap.page_allocator),
            .current_section = "",
        };
        try ini_config.data.put(ini_config.current_section, std.StringHashMap([]const u8).init(std.heap.page_allocator));
        // 按行读取
        while (try reader.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', 1024)) |line| {
            // 处理每一行
            var ln = line[0 .. line.len - 1];
            if (ln.len == 0) continue;
            if (ln[0] == '[') {
                std.heap.page_allocator.free(ini_config.current_section);
                ini_config.current_section = ln[1 .. ln.len - 1];
                try ini_config.data.put(ini_config.current_section, std.StringHashMap([]const u8).init(std.heap.page_allocator));
            } else {
                const index = std.mem.indexOfScalar(u8, ln, '=');
                if (index == null) continue;
                const key = ln[0..index.?];
                const value = ln[index.? + 1 .. ln.len];
                try ini_config.data.getPtr(ini_config.current_section).?.put(key, value);
            }
        }
        return ini_config;
    }
    pub fn Section(self: *IniConfig, name: []const u8) *IniConfig {
        self.current_section = name;
        return self;
    }
    pub fn Key(self: *IniConfig, key: []const u8) []const u8 {
        return self.data.get(self.current_section).?.get(key).?;
    }
};
