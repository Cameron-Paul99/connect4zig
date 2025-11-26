const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const Entry = packed struct {
    key: u56,
    val: u8,
};
 
pub const TT = struct{

    t: []Entry,

    pub fn init(allocator: *Allocator, size: usize) !TT{
        const table = try allocator.alloc(Entry, size);

        for (table) |*e| {
            
            e.* = .{
                .key = 0,
                .val = 0,
            };

        }
        return TT {
            .t = table,
        };
    }

    pub fn deinit(self: *TT, allocator: *Allocator) void {
        allocator.free(self.t);
    }

    fn Index(self: *TT, k: u56) usize{
        const len_u56: u56 = @intCast(self.t.len);
        const idx_u56: u56 = k % len_u56;
        return @intCast(idx_u56);
    }

    pub fn Put(self: *TT, k: u56, val: u8) void{

        const i = self.Index(k);
        self.t[i].key = k;
        self.t[i].val = val;

    }

    pub fn Get(self: *TT, k: u56) ?u8{
        const i = self.Index(k);
        if (self.t[i].key == k) return self.t[i].val;

        return null;
    }


};
