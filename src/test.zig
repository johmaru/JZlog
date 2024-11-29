const std = @import("std");
const logger = @import("logger.zig");

test "log hsms initialized" {
    try logger.init(.Include_h_s_m_s, .{});
    try logger.log("test", logger.LogLevel.Info);
    std.debug.print("log hsms test success\n", .{});
}

test "log ymd initialized" {
    try logger.init(.y_m_d, .{});
    try logger.log("test", logger.LogLevel.Info);
    std.debug.print("log ymd test success\n", .{});
}

test "log configlevel filtering" {
    try logger.init(.Include_h_s_m_s, .{ .min_level = logger.LogLevel.Warning });
    try logger.log("test", logger.LogLevel.Info);
    std.debug.print("log configlevel test success\n", .{});
}

test "log async" {
    try logger.init(.Include_h_s_m_s, .{});
    try logger.asyncLog("async", logger.LogLevel.Info);

    std.time.sleep(500 * std.time.ns_per_ms);
    std.debug.print("log async test success\n", .{});
}
