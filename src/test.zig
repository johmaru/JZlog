const std = @import("std");
const logger = @import("logger.zig");

test "log initialized" {
    try logger.Init(.y_m_d);
    std.debug.print("log initialized\n", .{});
    try logger.log("test", logger.LogLevel.Info);
    std.debug.print("log test\n", .{});
}
