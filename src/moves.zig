const print = std.debug.print;
const std = @import("std");
const base = @import("base.zig");


pub const MoveSorter = struct {

    pub const Entry = struct {
        move: u3,
        score: u64,
    };

    size: u64,
    entries: []Entry,

    pub fn Add(self: *MoveSorter , move: u3, score: u64) void{

        var pos = self.size;
        self.size += 1;

        while (pos > 0 and self.entries[pos - 1].score > score){
            
            self.entries[pos] = self.entries[pos - 1];
            pos -= 1;

        }

        self.entries[pos].move = move;
        self.entries[pos].score = score;

    }

    pub fn GetNext(self: *MoveSorter) u3{
        
        if (self.size > 0){
            self.size -= 1;
            return self.entries[self.size].move;
        }

        return 0;
        
    }

    pub fn Reset(self: *MoveSorter) void{

        self.size = 0;

    }

    pub fn Init(self: *MoveSorter) void{
        
        self.size = 0;

    }

    

};
