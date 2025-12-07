const rl = @import("raylib");

pub const Config = struct {
    const DEFAULT_PADDLE_HEIGHT: f32 = 100.0;
    const DEFAULT_WALL_MARGIN: f32 = 10.0;

    // Window variables
    window_height: f32,
    window_width: f32,

    // Paddle variable
    paddle_width: f32 = 10,
    paddle_height: f32 = DEFAULT_PADDLE_HEIGHT,
    paddle_colour: rl.Color = rl.Color.green,
    paddle_margin: f32 = 25,
    paddle_speed_pixels_per_sec: f32 = 300,
    paddle_start_pos_y: f32,

    // Collision points
    wall_margin: f32 = DEFAULT_WALL_MARGIN,
    ai_goal: f32 = 10,
    user_goal: f32,
    wall_top: f32 = 10,
    wall_bottom: f32,

    pub fn init(window_width: f32, window_height: f32) Config {
        return .{
            .window_height = window_height,
            .window_width = window_width,
            .wall_bottom = window_height - DEFAULT_WALL_MARGIN,
            .user_goal = window_width - DEFAULT_WALL_MARGIN,
            .paddle_start_pos_y = (window_height / 2.0) - (DEFAULT_PADDLE_HEIGHT / 2.0),
        };
    }
};