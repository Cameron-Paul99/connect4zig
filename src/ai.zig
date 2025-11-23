const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const base = @import("base.zig");

pub var original_max_depth: u8 = 0;

pub const SearchRes = struct {
    score: i32,
    best_move: u3,
};

const NEG_INF = std.math.minInt(i32);

pub fn NegaMax(game: *base.Game, depth: u8, alpha_in: i32, beta_in: i32) SearchRes{

    var alpha = alpha_in;
    var beta = beta_in;

    if (depth == 0){
        //print("returning depth here", .{});
        return DepthMax(game);
        
    }

    if (game.moves == game.board_height * game.board_width){
        print("returning moves here\n", .{});
        return .{
            .score = 0,
            .best_move = 0, 
        };
    }
    
    for (0..game.board_width) |i| {
        const c: u3 = @intCast(i);
        if (CanPlay(c, game) and IsWinningMove(game, c)){
            return .{ 
                .score = (game.board_height * game.board_width + 1 - game.moves) / 2,
                .best_move = c,
            };
        }
    }


    const max = (game.board_width * game.board_height - 1 - game.moves) / 2;
    if (beta > max){
        beta = max;
        if (alpha >= beta) return .{ .score = beta, .best_move = 0};
    }

    var best_score: i32 = -(@as(i32, game.board_width) * @as(i32, game.board_height));
    var best_move: u3 = 0;
   
    for (0..game.board_width) |i| {
        const c: u3 = @intCast(i);
        if (CanPlay(c, game)) {
            
            var child = game.*;
           _ = base.Play(&child, c);
            
            const childRes = NegaMax(&child, depth - 1, -alpha, -beta);
            const score = -childRes.score;

            if (score >= beta){
                return .{ .score = score, .best_move = c};
            }
            if (score > alpha){
                alpha = score;
                best_score = score;
                best_move = c;
            }

        }

    }

    if (best_score == NEG_INF) {
        best_score = alpha;
    }
    print("Got to the end of the function\n", .{});
    return .{.score = best_score, .best_move = best_move };
}

fn DepthMax(game: *base.Game) SearchRes{
    var bestScore: i32 = -999999;
    var bestMove: u3 = 0;

    var i: usize = 0;
    while (i < game.board_width) : (i += 1) {
         const c: u3 = @intCast(i);
        if (!CanPlay(c, game)) continue;

        var child = game.*;
        _ = base.Play(&child, c);
        const score = Evaluate(&child); // heuristic

        if (score > bestScore) {
            bestScore = score;
            bestMove = c;
        }
    }

    return .{
        .score = bestScore,
        .best_move = bestMove,
    };    
}

fn Evaluate(game: *base.Game) i32 {
    _ = game;
    return 0; // placeholder — we can make a real one next
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
    const step_h = g.board_height + 1;
    const step_d1 = g.board_height;
    const step_d2 = g.board_height + 2;

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

