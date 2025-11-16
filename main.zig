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
    boardHeight: u6,
    boardWidth: u6,
    gameOver: bool,
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
    //_ = stdin;

    var stdout_buffer : [512]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const welcoming = 
        \\Hello
        \\Welcome to Connect 4 created by
        \\Cameron Paul
    ;

    const WIDTH = 7;
    const HEIGHT = 6;

    const ns_per_frame = std.time.ns_per_ms * 16;

    var game = Game {
        .red = 0,
        .yellow = 0,
        .moves = 0,
        .boardWidth = WIDTH,
        .boardHeight = HEIGHT,
        .gameOver = false,
    };

    var gameOver = false;
    _ = &gameOver;

    var col : u8 = 0;

    try stdout.print("{s}\n", .{os_msg});

    try stdout.print("{s}\n", .{welcoming});

    _ = &col;
    _ = ns_per_frame;

    try stdout.flush();

    while (!game.gameOver){
        
        if ((game.moves & 1) == 0){
            
            try stdout.writeAll("Enter a chip in column: ");
            try stdout.flush();

            const input = try stdin.takeDelimiterExclusive('\n'); // TODO: Change to both new line and space
            const val = try std.fmt.parseInt(u3, input, 10);
            
            
            try stdout.flush();
            if (val >= 0 and val <= 6){

                _ = Play(&game, val);
                _ = try stdin.discardDelimiterInclusive('\n');

            }else {

                break; // TODO: redo input if invalid 
            }

             if (game.gameOver) {
                try stdout.writeAll("Red wins!!\n");
                try stdout.flush(); 
             }
           
           // gameOver = true;
            
        }else{

            try stdout.writeAll("Enter a chip in column: ");
            try stdout.flush();
            //game.gameOver = true;
             const input = try stdin.takeDelimiterExclusive('\n'); // TODO: Change to both new line and space
                                                                   //
             //if (input.len == 0) {
              //  try stdout.writeAll("\nEnter a chip\n");
              //  try stdout.flush();
             //   continue;
            // }
            const val = try std.fmt.parseInt(u3, input, 10);
          //  const val = std.fmt.parseInt(u3, trimmed, 10) catch |err| switch (err) {
           //     error.InvalidCharacter => {
             //       try stdout.writeAll("That is not a valid number.\n");
               //     try stdout.flush();
                //    continue; // ask again
               // },
               // else => return err, // real I/O/other errors bubble up
            //};


             _ = Play(&game, val); 
             _ = try stdin.discardDelimiterInclusive('\n');
             if (game.gameOver) {
                try stdout.writeAll("Yellow wins!! \n");
                try stdout.flush(); 
             }
            //TODO: AI play

        }

        // TODO: Check if Player or AI has won
        //
        try PrintBoard(game, HEIGHT, WIDTH, stdout);

    }else{
        try stdout.writeAll("Game Over \n");
        try stdout.flush();
       
        
    }
}

fn BoardCheck(board: u64, height: u6) bool {

    // Vertical Check
    var m = board & (board >> 1);
    if ((m & (m >> 2)) != 0) return true;

    // Horizontal Check
    m = board & (board >> height);
    if ((m & (m >> height * 2)) != 0) return true;

    // Diagonal Down
    m = board & (board >> (height + 1));
    if ((m & (m >> (height + 1) * 2)) != 0) return true;

    // Diagonal Up
    m = board & (board >> (height - 1));
    if ((m & (m >> (height - 1) * 2)) != 0) return true;

    return false;

}

fn PrintBoard(g: Game, HEIGHT: u8, WIDTH: u8, writer: *std.Io.Writer) !void{ //TODO: Change to new stdout

    for (0..HEIGHT) |rev_row| {
        const row = HEIGHT - 1 - rev_row;
        try writer.writeAll("|");
        try writer.flush();
        for (0..WIDTH) |col|{
            const bit_index = col * 7 + row;
            const bit_mask: u64 = @as(u64, 1) << @intCast(bit_index);
            _ = &bit_mask;

           // const occupied = (( red | blue) & bit_mask) != 0;
            var cell: u8 = 0;
            if ((g.red & bit_mask) != 0) cell = 1;
            if ((g.yellow & bit_mask) != 0) cell = 2;

            try writer.print("{any} ", .{cell});
            try writer.flush();

        }
       try writer.writeAll("|\n");
       try writer.flush();
    }

}
fn colMask(col: u3) u64 { return (@as(u64, 0x3F) << (@as(u6, col) * 7)); }
fn bottomMask(col: u3) u64 { return @as(u64, 1) << (@as(u6, col) * 7); }

fn Play(g: *Game, col: u3) bool {

    const mask_all = g.red | g.yellow;
    const col_mask = colMask(col);
    if ((mask_all & (col_mask << 1)) == col_mask) return false; // column full

    const move_bit = (mask_all + bottomMask(col)) & col_mask;
    if ((g.moves & 1) == 0){
        g.red ^= move_bit;
        g.gameOver = BoardCheck(g.red, g.boardHeight);

    }
    else {
        g.yellow ^= move_bit;
        g.gameOver = BoardCheck(g.yellow, g.boardHeight);
    }
    
    g.moves += 1;
    return true;
}

//fn Init (gs: *Game) void{
    
//}

//fn Update(gs: *Game, dt: f32) void{




//}
