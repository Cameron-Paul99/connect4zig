const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const base = @import("base.zig");

pub fn NegaMax(game: *base.Game) i32{

    if (game.moves == game.boardHeight * game.boardWidth){
        return 0;
    }
    
    for (0..game.boardWidth) |i| {
        const c: u3 = @intCast(i);
        if (CanPlay(c, game) and IsWinningMove(game, c)){
            return (game.boardHeight * game.boardWidth + 1 - game.moves) / 2;
        }
    }

    var bestScore: i32 = -(@as(i32, game.boardWidth) * @as(i32, game.boardHeight));
   
    for (0..game.boardWidth) |i| {
        const c: u3 = @intCast(i);
        if (CanPlay(c, game)) {
            
            // Play
            const score = -NegaMax(game);
            if (score > bestScore) bestScore = score;
            

        }


    }
    return bestScore;


}

fn CanPlay(col: u3, g: *base.Game) bool{
    const mask_all = g.red | g.yellow;
    const col_mask = base.colMask(col);
    if ((mask_all & (col_mask << 1)) == col_mask) return false; // column full
    return true;
}


fn Possible(col: u3, g: *base.Game) u64 {
    const mask_all = g.red | g.yellow;
   // const col_mask = base.colMask(col);
    const move_bit = (mask_all + base.bottomMask(col)) & base.BOARD_MASK_ALL; 
    return move_bit;
}

fn IsWinningMove(g: *base.Game, col: u3) bool {

    if ((Possible(col, g) & WinningPosition(g) & base.colMask(col)) == 0){
        return false;
    }

    return true;

}

fn WinningPosition(g: *base.Game) u64 {

    var r : u64 = 0;
    var current_player: u64 = 0;
    const step_h = g.boardHeight + 1;
    const step_d1 = g.boardHeight;
    const step_d2 = g.boardHeight + 2;

    if ((g.moves & 1) == 0){
        current_player = g.red;
    }else{
        current_player = g.yellow;
    }

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

    //Diagonal One
    p = (current_player << step_d1) & (current_player << (2 * step_d1));
    r |= p & (current_player << (3 * step_d1));
    r |= p & (current_player >> step_d1);

    p = (current_player >> step_d1) & (current_player >> (2 * step_d1));
    r |= p & (current_player << step_d1);
    r |= p & (current_player >> (3 * step_d1));
    
    //Diagonal Two  
    p = (current_player << step_d2) & (current_player << (2 * step_d2));
    r |= p & (current_player << (3 * step_d2));
    r |= p & (current_player >> step_d2);

    p = (current_player >> step_d2) & (current_player >> (2 * step_d2));
    r |= p & (current_player << step_d2);
    r |= p & (current_player >> (3 * step_d2));

    return r & (base.BOARD_MASK_ALL ^ g.board);

}

fn AI(game: *base.Game) void{
    
    _ = game;

}
