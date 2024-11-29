# JZlog

No dependent Simple zig logging library

## how to install

```zig
// [build.zig.zon](http://_vscodecontentref_/2)
.{
    .dependencies = .{
        .JZlog = .{
            .url = "",
            .hash = "...",
        },
    },
}
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
```