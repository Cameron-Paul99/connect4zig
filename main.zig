const print = std.debug.print;
const std = @import("std");

const boardType = [6][7]u8;

pub fn main() void{

    const board = std.mem.zeroes(boardType);
    print("Hello, {s}!\n", . {"World"});

    print("Connect 4 board is\n {any}\n", . {board});

}
