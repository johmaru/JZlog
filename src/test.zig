const std = @import("std");
const logger = @import("logger.zig");

test "log hsms initialized" {
    try logger.init(.Include_h_s_m_s, .{});
    std.debug.print("log initialized\n", .{});
    try logger.log("test", logger.LogLevel.Info);
    std.debug.print("log hsms test success\n", .{});
}

test "log ymd initialized" {
    try logger.init(.y_m_d, .{});
    std.debug.print("log initialized\n", .{});
    try logger.log("test", logger.LogLevel.Info);
    std.debug.print("log ymd test success\n", .{});
}

test "log configlevel filtering" {
    try logger.init(.Include_h_s_m_s, .{ .min_level = logger.LogLevel.Warning });
    std.debug.print("log initialized\n", .{});
    try logger.log("test", logger.LogLevel.Info);
    std.debug.print("log configlevel test success\n", .{});
}
