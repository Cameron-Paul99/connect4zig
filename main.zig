const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const base = @import("src/base.zig");
const t = @import("src/tt.zig");

const PlayerType = enum(u64) {
    AI = 2,
    PLAYER = 1,
    Empty = 0,
};

const EnumExample = enum {
    RED,
    BLUE,
    pub fn GetPlayerColor(player: PlayerType) EnumExample{
        return switch(player){
            .AI => EnumExample.RED,
            .PLAYER => EnumExample.BLUE,
        };
    }

};

// Overall Game Flow
const UnionExample = union(enum){
    Waiting: struct {to_move: PlayerType},
    AnimationDrop: struct {player: PlayerType, col: u8, t: f32},
    Resolver: struct {last_player: PlayerType, last_col: u8},
    GameOver: struct {winner: ?PlayerType},
};

const chip = struct {
    statusEffect: Effect,
    pos: struct {u8, u8},
};

const Effect = enum {
    FIRE,
    ELECTRIC,
    // Enums can also be switched upon
    // Enums can have functions
};

// Switch statement outside 
const os_msg = switch (builtin.target.os.tag){
    .linux => "we found a linux user",
    else => "Not a linux user",
};


pub fn main() !void{
    
    var stdin_buffer: [512]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
    const stdin = &stdin_reader.interface;

    var stdout_buffer : [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const welcoming = 
        \\Hello
        \\Welcome to Connect 4 created by
        \\Cameron Paul
    ;

    var allocator = std.heap.page_allocator;
    var tt = try t.TT.init(&allocator, 1 << 24);
    defer tt.deinit(&allocator);

    var game = base.Game {
        .red = 0,
        .yellow = 0,
        .moves = 0,
        .board_width = base.WIDTH,
        .board_height = base.HEIGHT,
        .game_over = false,
        .board = 0,
        .tt = tt,
        .curr_player = 0,
    };

    try stdout.print("{s}\n", .{os_msg});

    try stdout.print("{s}\n", .{welcoming});

    try stdout.flush();

    try base.BaseConnectFour(&game, stdout, stdin, base.WIDTH, base.HEIGHT);


}

//fn Init (gs: *Game) void{
    
//}

//fn Update(gs: *Game, dt: f32) void{




//}
