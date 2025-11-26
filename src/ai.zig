const print = std.debug.print;
const std = @import("std");
const builtin = @import("builtin");
const base = @import("base.zig");

pub var original_max_depth: u8 = 0;

pub const SearchRes = struct {
    score: i32,
    best_move: u3,
};

var col_order: [base.WIDTH]usize = undefined;

const NEG_INF = std.math.minInt(i32);

pub fn ColOrderInit() void {
    const center: i32 = base.WIDTH / 2;

    var idx: usize = 0;
    col_order[idx] = @intCast(center);
    idx += 1;

    var offset: i32 = 1;
    while (idx < base.WIDTH) : (offset += 1) {
        const left  = center - offset;
        const right = center + offset;

        if (left >= 0) {
            col_order[idx] = @intCast(left);
            idx += 1;
        }
        if (right < base.WIDTH and idx < base.WIDTH) {
            col_order[idx] = @intCast(right);
            idx += 1;
        }

    }

    for (0.. base.WIDTH) |i|{
        
        print("{d} ", .{col_order[i]});

    }
}

pub fn NegaMax(game: *base.Game, depth: i64, alpha_in: i32, beta_in: i32) SearchRes{

    var alpha = alpha_in;
    var beta = beta_in;

    if (depth == 0){
        return .{.score = 0, .best_move = 0};
    }

    // DRAW
    if (game.moves == game.board_height * game.board_width){
        print("returning moves here\n", .{});
        return .{
            .score = 0,
            .best_move = 0, 
        };
    }
   
    // WINNING MOVE
    for (0..game.board_width) |i| {
        //const c: u3 = @intCast(i);
        const c: u3 = @intCast(col_order[i]);
        if (CanPlay(c, game) and IsWinningMove(game, c)){
            return .{ 
                .score = (game.board_height * game.board_width + 1 - game.moves) / 2,
                .best_move = c,
            };
        }
    }

    // Upper bound Cal
    const max = (game.board_width * game.board_height - 1 - game.moves) / 2;
    if (beta > max){
        beta = max;
        if (alpha >= beta){
            return .{ .score = beta, .best_move = 0};
        }
    }
    
    var best_move: u3 = 0;
   
    // Leaf Node Calculation
    for (0..game.board_width) |i| {
        const c: u3 = @intCast(col_order[i]);

        if (CanPlay(c, game)) {
            
            var child = game.*;
           _ = base.Play(&child, c);
            
            const childRes = NegaMax(&child, depth - 1, -beta, -alpha);
            const score = -1 * childRes.score;

            if (score >= beta){
                return .{ .score = score, .best_move = c};
            }
            if (score > alpha){
                alpha = score;
                best_move = c;
            }

        }

    }

    return .{.score = alpha, .best_move = best_move };
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

