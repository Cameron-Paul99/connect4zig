const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const ai = @import("ai.zig");

pub const Game = struct {
    red: u64,
    yellow: u64,
    moves: u8,
    boardHeight: u6,
    boardWidth: u6,
    gameOver: bool,
};

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

fn PrintBoard(g: *Game, HEIGHT: u8, WIDTH: u8, writer: *std.Io.Writer) !void { 

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

pub fn BaseConnectFour(game: *Game, stdout: *std.Io.Writer, stdin: *std.Io.Reader, WIDTH: u8, HEIGHT: u8) !void {
    
    while (!game.gameOver){
        
        if ((game.moves & 1) == 0){
            
            try stdout.writeAll("Enter a chip in column: ");
            try stdout.flush();

            const input = try stdin.takeDelimiterExclusive('\n'); 
            const val = try std.fmt.parseInt(u3, input, 10);
            
            try stdout.flush();

             _ = Play(game, val);
             _ = try stdin.discardDelimiterInclusive('\n');

             if (game.gameOver) {
                try stdout.writeAll("Red wins!!\n");
                try stdout.flush(); 
             }
            
        }else{

            try stdout.writeAll("Enter a chip in column: ");
            try stdout.flush();

             const input = try stdin.takeDelimiterExclusive('\n');
                                                                  
             const val = try std.fmt.parseInt(u3, input, 10);

             _ = Play(game, val); 
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
