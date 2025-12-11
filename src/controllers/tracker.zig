const rl = @import("raylib");
const GameView = @import("../game_view.zig").GameView;
const Action = @import("../action.zig").Action;
const predictBallY = @import("../prediction.zig").predictBallY;

pub const TrackerAIController = struct {

    pub fn selectAction(game_view: GameView) Action {

        const dead_zone: f32 = 15;

        const predicted_y = predictBallY(
            game_view.ball_position,
            game_view.ball_velocity,
            game_view.ball_radius,
            game_view.target_x,
            game_view.wall_top,
            game_view.wall_bottom,
        );

        if (predicted_y < game_view.current_paddle_position_y - dead_zone) {
            return .up;
        }
        if (predicted_y > game_view.current_paddle_position_y + dead_zone) {
            return .down;
        }
        return .stay;
    }
};