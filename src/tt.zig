const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");

const Entry = packed struct {
    key: u56,
    val: u8,
};

pub const TT = struct{

    t: []Entry,

    pub fn init(allocator: *Allocator, size: usize) !TT{
        return TT {.t = try allocator.alloc(Entry, size)};
    }

    pub fn deinit(self: *TT, allocator: *Allocator) void {
        allocator.free(self.t);
    }

    fn Index(self: *TT, k: u56) usize{
        return @intCast(k % self.t.len);
    }

    pub fn Put(self: *TT, k: u56, val: u8){

        const i = self.Index(k);
        self.t[i].key = k;
        self.t[i].val = val;

    };

    pub fn Get(self: *TT, k: u56) ?u8{
        const i = self.Index(k);
        if (self.t[i].key == k) return self.t[i].key;

        return null;
    };


};
