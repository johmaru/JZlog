# JZlog

Simple zig logging library

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

    try JZlog.Init(null); // If you want to choose time format (Y-M-D or Y-M-D-H-M-S), you can use LogTime enum types.
    try JZlog.log("Hello!", JZlog.LogLevel.Info); // This library supports various LogLevel types
```