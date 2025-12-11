const rl = @import("raylib");

pub const GameView = struct {
    ball_position: rl.Vector2,
    ball_velocity: rl.Vector2,
    ball_radius: f32,
    target_x: f32,
    wall_top: f32,
    wall_bottom: f32,
    paddle_center_y: f32,
    ball_approaching: bool,

    pub fn init(
        ball_position: rl.Vector2,
        ball_velocity: rl.Vector2,
        ball_radius: f32,
        target_x: f32,
        wall_top: f32,
        wall_bottom: f32,
        paddle_center_y: f32,
        ball_approaching: bool,
    ) GameView {
        return .{
            .ball_position = ball_position,
            .ball_velocity = ball_velocity,
            .ball_radius = ball_radius,
            .target_x = target_x,
            .wall_top = wall_top,
            .wall_bottom = wall_bottom,
            .paddle_center_y = paddle_center_y,
            .ball_approaching = ball_approaching,
        };
    }
};
