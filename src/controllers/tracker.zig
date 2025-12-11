const Random = @import("std").Random;
const GameView = @import("../game_view.zig").GameView;
const Action = @import("../action.zig").Action;
const predictBallY = @import("../prediction.zig").predictBallY;
const DifficultyConfig = @import("../difficulty_config.zig").DifficultyConfig;

pub const TrackerAIController = struct {
    time_since_direction_change_seconds: f32 = 0,
    last_ball_approaching: bool = false,
    random_number_generator: Random,
    random_y_offset: f32 = 0,
    difficulty_config: DifficultyConfig,


    pub fn init(difficulty_config: DifficultyConfig, random_number_generator: Random) TrackerAIController {
        return .{
            .difficulty_config = difficulty_config,
            .random_number_generator = random_number_generator,
        };
    }

    pub fn selectAction(self: *TrackerAIController, game_view: GameView, delta_time: f32) Action {
        if (game_view.ball_approaching != self.last_ball_approaching) {
            const error_range = self.difficulty_config.prediction_error_range;
            self.random_y_offset = @floatFromInt(
                self.random_number_generator.intRangeAtMost(i8, -error_range, error_range)
            );
            self.time_since_direction_change_seconds = 0;
            self.last_ball_approaching = game_view.ball_approaching;
        } else {
            self.time_since_direction_change_seconds += delta_time;
        }

        if (game_view.ball_approaching == false) {
            return .stay;
        }

        if (self.time_since_direction_change_seconds < self.difficulty_config.reaction_delay_seconds) {
            return .stay;
        }

        var predicted_y = predictBallY(
            game_view.ball_position,
            game_view.ball_velocity,
            game_view.ball_radius,
            game_view.target_x,
            game_view.wall_top,
            game_view.wall_bottom,
        );

        predicted_y += self.random_y_offset;

        if (predicted_y < game_view.paddle_center_y - self.difficulty_config.dead_zone) {
            return .up;
        }
        if (predicted_y > game_view.paddle_center_y + self.difficulty_config.dead_zone) {
            return .down;
        }
        return .stay;
    }

    pub fn getSpeedMultiplier(self: TrackerAIController) f32 {
        return self.difficulty_config.speed_multiplier;
    }
};
