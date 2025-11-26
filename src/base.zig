const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const ai = @import("ai.zig");

pub const WIDTH = 7;
pub const HEIGHT = 6;
const INF: i32 = 1_000_000; // safely bigger than any score you’ll use


pub const Game = struct {
    red: u64,
    yellow: u64,
    moves: u8,
    board_height: u6,
    board_width: u6,
    game_over: bool,
    board: u64,
};

pub const BOARD_MASK_ALL: u64 =
    (@as(u64, 1) << @as(u6, WIDTH * (HEIGHT + 1))) - 1;

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

fn PrintBoard(g: *Game, height: u8, width: u8, writer: *std.Io.Writer) !void { 

    for (0..HEIGHT) |rev_row| {
        const row = height - 1 - rev_row;
        try writer.writeAll("|");
        try writer.flush();
        for (0..width) |col|{
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

pub fn colMask(col: u3) u64 { return (@as(u64, 0x3F) << (@as(u6, col) * 7)); }
pub fn bottomMask(col: u3) u64 { return @as(u64, 1) << (@as(u6, col) * 7); }

pub fn Play(g: *Game, col: u3) bool {

    const mask_all = g.red | g.yellow;
    const col_mask = colMask(col);
    if ((mask_all & (col_mask << 1)) == col_mask) return false; // column full

    const move_bit = (mask_all + bottomMask(col)) & col_mask;
    if ((g.moves & 1) == 0){
        g.red ^= move_bit;
        g.game_over = BoardCheck(g.red, g.board_height);

    }
    else {
        g.yellow ^= move_bit;
        g.game_over = BoardCheck(g.yellow, g.board_height);
    }

    g.board = g.red | g.yellow;
    
    g.moves += 1;
    return true;
}

pub fn BaseConnectFour(game: *Game, stdout: *std.Io.Writer, stdin: *std.Io.Reader, width: u8, height: u8) !void {

    //const alpha = std.math.minInt(i32);
    //const beta = std.math.maxInt(i32);
    const allocator = std.heap.page_allocator;
    _ = allocator;

    ai.ColOrderInit();

    while (!game.game_over){
        
        if ((game.moves & 1) == 0){
            
            try stdout.writeAll("Enter a chip in column: ");
            try stdout.flush();

            const input = try stdin.takeDelimiterExclusive('\n'); 
            const val = try std.fmt.parseInt(u3, input, 10);
            
            try stdout.flush();

             _ = Play(game, val);
             _ = try stdin.discardDelimiterInclusive('\n');

             if (game.game_over) {
                try stdout.writeAll("Red wins!!\n");
                try stdout.flush(); 
             }
            
        }else{


            //TODO: AI play

            const moveRes = ai.NegaMax(game, 8, -INF, INF);

            try stdout.print("AI best move is {d}\n", .{moveRes.best_move});
            _ = Play(game, moveRes.best_move);
            try stdout.print("AI is done with score {d}\n", .{moveRes.score});
            if (game.game_over) {
                try stdout.writeAll("Yellow wins!!\n");
                try stdout.flush(); 
            }
        }

        // TODO: Check if Player or AI has won
        //
        try PrintBoard(game, height, width, stdout);

    }else{

        try stdout.writeAll("Game Over \n");
        try stdout.flush();

    }
}
