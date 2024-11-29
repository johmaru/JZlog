# JZlog

No dependent Simple zig logging library

library v 0.0.2 on zig version 0.13.0

## how to install

```zig fetch --save https://github.com/johmaru/JZlog/archive/refs/tags/v0.0.2.zip```

edit build.zig

```zig
    const jzlog_dep = b.dependency("JZlog", .{});
    const jzlog_module = jzlog_dep.module("JZlog");

    //Under
    //const exe = b.addExecutable(.{
      //  .name = "test_log",
      //  .root_source_file = b.path("src/main.zig"),
      //  .target = target,
      //  .optimize = optimize,
    // });

    exe.root_module.addImport("JZlog", jzlog_module);
```

main.zig

```zig
const jz_log = @import("JZlog");
```

## how to use

```zig
    const JZlog = @import("JZlog");

    // all default
    try JZlog.init(null,.{}); 

    // If you want to choose time format (Y-M-D or Y-M-D-H-M-S), you can use LogTime enum types.
    try logger.init(.y_m_d,.{}); 

    // Include hsms
    try logger.init(.Include_h_s_m_s,{}); 
    
    // also you can chose any settings your like
     try logger.init(null,.{ .min_level = logger.LogLevel.Warning }); 




    // this is log write function
    try JZlog.log("Hello!", JZlog.LogLevel.Info); // This library supports various LogLevel types

    // this library have async function
    try logger.asyncLog("async!!", logger.LogLevel.Info);
    defer logger.shutdown();
```
