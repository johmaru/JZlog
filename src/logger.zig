const std = @import("std");
const time = std.time;
const builtin = @import("builtin");
const is_debug = @import("builtin").mode == .Debug;

const Logger = struct {
    log_msg: []const u8,
    log_level: LogLevel,
    log_time: []const u8,
};

pub const LogLevel = enum(u8) {
    Debug = 0,
    Info = 1,
    Warning = 2,
    Error = 3,
};

pub const LogLevelContent = struct {
    loglevel: LogLevel,
    loglevel_str: []const u8,
};

pub const LogLevel_struct = [_]LogLevelContent{
    .{
        .loglevel = LogLevel.Debug,
        .loglevel_str = "Debug",
    },
    .{
        .loglevel = LogLevel.Info,
        .loglevel_str = "Info",
    },
    .{
        .loglevel = LogLevel.Warning,
        .loglevel_str = "Warning",
    },
    .{
        .loglevel = LogLevel.Error,
        .loglevel_str = "Error",
    },
};

pub const LogConfig = struct {
    min_level: LogLevel = LogLevel.Debug,
};

pub const LogTime = enum { Include_h_s_m_s, y_m_d };

var LogConfig_content: LogConfig = .{
    .min_level = LogLevel.Debug,
};

var log_time: i64 = undefined;

var time_format: LogTime = LogTime.Include_h_s_m_s;

pub fn init(logtime: ?LogTime, logconfig: ?LogConfig) !void {
    // main allocation
    const allocator = std.heap.page_allocator;

    log_time = time.timestamp();

    if (logconfig) |cfg| {
        LogConfig_content = cfg;
    }

    switch (builtin.os.tag) {
        .windows => {
            // u8 buffer for the path
            var exepath_buffer: [1024]u8 = undefined;
            const exepath = try std.fs.selfExePath(&exepath_buffer);

            const exe_dir = std.fs.path.dirname(exepath) orelse return error.UnexpectedNull;

            if (comptime is_debug) {
                std.debug.print("exe_dir: {s}\n", .{exe_dir});
            }

            // marge the path
            const log_path = try std.fs.path.join(allocator, &[_][]const u8{ exe_dir, "logs" });
            defer allocator.free(log_path);

            var dir = std.fs.cwd().openDir(log_path, .{});
            if (dir) |*d| {
                defer d.close();
            } else |err| {
                if (err == std.fs.Dir.OpenError.FileNotFound) {
                    try std.fs.cwd().makeDir(log_path);
                } else {}
            }

            if (logtime) |lt| {
                time_format = lt;
            }
        },
        .linux => {
            std.debug.print("dev", .{});
        },
        else => {
            return error.UnsupportedOs;
        },
    }
}

fn get_log_file_path() ![]const u8 {
    switch (builtin.os.tag) {
        .windows => {
            const allocator = std.heap.page_allocator;

            var exepath_buffer: [1024]u8 = undefined;
            const exepath = try std.fs.selfExePath(&exepath_buffer);

            const exe_dir = std.fs.path.dirname(exepath) orelse return error.UnexpectedNull;

            const log_path = try std.fs.path.join(allocator, &[_][]const u8{ exe_dir, "logs" });
            defer allocator.free(log_path);

            switch (time_format) {
                LogTime.Include_h_s_m_s => {
                    const time_str = try time_format_content();
                    defer allocator.free(time_str);
                    return try std.fs.path.join(allocator, &[_][]const u8{ log_path, try std.fmt.allocPrint(allocator, "{s}-log.txt", .{time_str}) });
                },
                LogTime.y_m_d => {
                    const time_str = try time_format_content();
                    defer allocator.free(time_str);

                    return try std.fs.path.join(allocator, &[_][]const u8{ log_path, try std.fmt.allocPrint(allocator, "{s}-log.txt", .{time_str}) });
                },
            }
        },
        .linux => {
            return "dev";
        },
        else => {
            return error.UnsupportedOs;
        },
    }
}

fn time_format_content() ![]const u8 {
    switch (time_format) {
        LogTime.Include_h_s_m_s => {
            const date = getDateAll(log_time);
            return try std.fmt.allocPrint(std.heap.page_allocator, "{d}-{d:0>2}-{d:0>2}-{d:0>2}-{d:0>2}-{d:0>2}", .{
                date.year,
                date.month,
                date.day,
                date.hour,
                date.minute,
                date.second,
            });
        },
        LogTime.y_m_d => {
            const date = getDateOnly(log_time);
            return try std.fmt.allocPrint(std.heap.page_allocator, "{d}-{d:0>2}-{d:0>2}", .{
                date.year,
                date.month,
                date.day,
            });
        },
    }
}

fn log_time_format_content() ![]const u8 {
    const date = getDateAll(log_time);
    return try std.fmt.allocPrint(std.heap.page_allocator, "{d}-{d:0>2}-{d:0>2}-{d:0>2}-{d:0>2}-{d:0>2}", .{
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
    });
}

fn getDateOnly(timestamp: i64) struct { year: u16, month: u8, day: u8 } {
    const epoch = std.time.epoch.EpochSeconds{ .secs = @intCast(timestamp) };
    const epoch_day = epoch.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();

    const year = year_day.year;
    const month = month_day.month.numeric();
    const day = month_day.day_index + 1;

    return .{
        .year = year,
        .month = month,
        .day = day,
    };
}

fn getDateAll(timestamp: i64) struct { year: u16, month: u8, day: u8, hour: u8, minute: u8, second: u8 } {
    const epoch = std.time.epoch.EpochSeconds{ .secs = @intCast(timestamp) };
    const epoch_day = epoch.getEpochDay();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const day_seconds = epoch.getDaySeconds();

    const year = year_day.year;
    const month = month_day.month.numeric();
    const day = month_day.day_index + 1;
    const hours = day_seconds.getHoursIntoDay();
    const minutes = day_seconds.getMinutesIntoHour();
    const seconds = day_seconds.getSecondsIntoMinute();

    return .{
        .year = year,
        .month = month,
        .day = day,
        .hour = hours,
        .minute = minutes,
        .second = seconds,
    };
}

pub fn log(log_msg: []const u8, log_level: LogLevel) !void {
    if (@intFromEnum(log_level) < @intFromEnum(LogConfig_content.min_level)) {
        return;
    }

    const allocator = std.heap.page_allocator;

    const log_file_path = try get_log_file_path();
    defer allocator.free(log_file_path);

    if (comptime @import("builtin").mode == .Debug) {
        std.debug.print("Log file path: {s}\n", .{log_file_path});
    }

    const dir_path = std.fs.path.dirname(log_file_path) orelse return error.InvalidPath;
    std.fs.cwd().makeDir(dir_path) catch |err| {
        if (err != error.PathAlreadyExists) {
            return err;
        }
    };

    const log_file = try std.fs.cwd().createFile(log_file_path, .{ .read = true, .truncate = false });
    defer log_file.close();

    try log_file.seekFromEnd(0);

    const str = try log_time_format_content();
    defer allocator.free(str);

    const log_entry = Logger{ .log_msg = log_msg, .log_level = log_level, .log_time = str };

    const log_level_init: []const u8 = LogLevel_struct[@intFromEnum(log_level)].loglevel_str;

    const log_str = try std.fmt.allocPrint(allocator, "{s} Level {s} : {s}\n", .{
        log_entry.log_time,
        log_level_init,
        log_entry.log_msg,
    });
    defer allocator.free(log_str);

    const log_file_latest = std.fs.cwd().openFile(log_file_path, .{ .mode = .read_write });
    if (log_file_latest) |log_file_content| {
        defer log_file_content.close();

        const log_file_info = try log_file.readToEndAlloc(allocator, 1000);
        defer allocator.free(log_file_info);

        const log_file_info_str = try std.fmt.allocPrint(allocator, "{s}{s}", .{ log_file_info, log_str });
        defer allocator.free(log_file_info_str);

        try log_file.writeAll(log_file_info_str);
    } else |err| {
        return err;
    }
}
