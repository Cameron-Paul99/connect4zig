const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");

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

const Game = struct {
    red: u64,
    yellow: u64,
    moves: u8,
};

// Overall Game Flow
const UnionExample = union(enum){
    Waiting: struct {to_move: PlayerType},
    AnimationDrop: struct {player: PlayerType, col: u8, t: f32},
    Resolver: struct {last_player: PlayerType, last_col: u8},
    GameOver: struct {winner: ?PlayerType},
};

fn colMask(col: u3) u64 { return (@as(u64, 0x3F) << (@as(u6, col) * 7)); }
fn bottomMask(col: u3) u64 { return @as(u64, 1) << (@as(u6, col) * 7); }

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
    
    //var stdout = std.io.getStdOut().writer();

    print("os msg is {s}", . {os_msg}); 
    const welcoming = 
        \\Hello
        \\Welcome to Connect 4 created by
        \\Cameron Paul
    ;
    const ns_per_frame = std.time.ns_per_ms * 16; 

    print("{s}\n", . {welcoming});

    const WIDTH = 6;
    const HEIGHT = 7;

    var game = Game {
        .red = 0,
        .yellow = 0,
        .moves = 0,
    };

   _ = Play(&game, 1);

   _ = Play(&game, 0);
    PrintBoard(game, HEIGHT, WIDTH);
    var gameOver = false;
    _ = &gameOver;
    while (!gameOver){

        std.Thread.sleep(ns_per_frame);
        gameOver = true;
    }else{

        print("Game over\n", .{});
    }

}

fn PrintBoard(g: Game, HEIGHT: u8, WIDTH: u8) void{

    for (0..HEIGHT) |rev_row| {
        const row = HEIGHT - 1 - rev_row;
        print("|", .{});
        for (0..WIDTH) |col|{
            const bit_index = col * 7 + row;
            const bit_mask: u64 = @as(u64, 1) << @intCast(bit_index);
            _ = &bit_mask;

           // const occupied = (( red | blue) & bit_mask) != 0;
            var cell: u8 = 0;
            if ((g.red & bit_mask) != 0) cell = 1;
            if ((g.yellow & bit_mask) != 0) cell = 2;

            print("{any} ", .{cell});

        }
        print("|\n", .{});
    }

}

fn Play(g: *Game, col: u3) bool {

    const mask_all = g.red | g.yellow;
    const col_mask = colMask(col);
    if ((mask_all & (col_mask << 1)) == col_mask) return false; // column full

    const move_bit = (mask_all + bottomMask(col)) & col_mask;
    if ((g.moves & 1) == 0)
        g.red ^= move_bit
    else
        g.yellow ^= move_bit;

    g.moves += 1;
    return true;
}

//fn Init (gs: *Game) void{
    
//}

//fn Update(gs: *Game, dt: f32) void{




//}
