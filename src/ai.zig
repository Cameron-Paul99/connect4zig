const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const base = @import("base.zig");

fn NegaMax(game: *base.Game) u32{

    if (game.moves == game.boardHeight * game.boardWidth){
        return 0;
    }
    
    for (0..game.boardWidth) |i| {

        if (CanPlay(i, game) && IsWinningMove(i, game)){
            return (game.boardHeight * game.boardWidth + 1 - game.moves) / 2;
        }

    }


}

fn CanPlay(col: u8, g: *base.Game) u64{
    const mask_all = g.red | g.yellow;
    const col_mask = base.colMask(col);
    if ((mask_all & (col_mask << 1)) == col_mask) return false; // column full
    return true;
}


fn Possible(col: u8, g: *base.Game) u64 {
    const mask_all = g.red | g.yellow;
    const col_mask = colMask(col);
    return move_bit = (mask_all + bottomMask(col)) & BOARD_MASK_ALL; 
}

fn IsWinningMove(g: *base.Game, col: u8) bool {

    return Possible(col, g) & WinningPosition() & base.colMask(col);

}

fn WinningPosition(g: *base.Game, col: u8) u64 {

    var r : u64 = 0;
    var current_player: u64 = 0;
    const step_h = g.boardHeight + 1;
    const step_d1 = g.boardHeight;
    const step_d2 = g.boardHeight + 2;

    if ((g.moves & 1) == 0)
        current_player = g.red;
    else
        current_player = g.yellow;


    // Vertical
    r = (current_player << 1) & (current_player << 2) & (current_player << 3);

    //Horizontal
    var p : u64 = undefined;
    p = (current_player << step_h) & (current_player << (2 * step_h));
    r |= p & (current_player << (3 * step_h));
    r |= p & (current_player >> step_h);

    p = (current_player >> step_h) & (current_player >> (2 * step_h));
    r |= p & (current_player << step_h);
    r |= p & (current_player >> (3 * step_h));

    //Diagonal
    //





    
}

fn AI(game: *base.Game) void{
    
    _ = game;

}
