const rl = @import("raylib");
const std = @import("std");
const assert = std.debug.assert;

pub const Config = struct {
    // Window variables.
    window_height: f32,
    window_width: f32,

    // Paddle variables.
    paddle_width: f32 = 10,
    paddle_height: f32 = DEFAULT_PADDLE_HEIGHT,
    paddle_colour: rl.Color = rl.Color.green,
    paddle_margin: f32 = 25,
    paddle_speed_pixels_per_sec: f32 = 450,
    paddle_start_pos_y: f32,

    // Collision points.
    wall_margin: f32 = DEFAULT_WALL_MARGIN,
    left_goal: f32,
    right_goal: f32,
    wall_top: f32 = 10,
    wall_bottom: f32,

    // Display text variables.
    scoreboard_font_size: i32,
    scoreboard_pos_y: i32,

    const DEFAULT_PADDLE_HEIGHT: f32 = 100.0;
    const DEFAULT_WALL_MARGIN: f32 = 10.0;
    const DEFAULT_FONT_SIZE: i32 = 40;
    const DEFAULT_SCOREBOARD_POS_Y: i32 = 25;

    pub fn init(window_width: f32, window_height: f32) Config {
        assert(window_width >= 200);
        assert(window_height >= 100);
        return .{
            .window_height = window_height,
            .window_width = window_width,
            .wall_bottom = window_height - DEFAULT_WALL_MARGIN,
            .wall_margin = DEFAULT_WALL_MARGIN,
            .left_goal = DEFAULT_WALL_MARGIN,
            .right_goal = window_width - DEFAULT_WALL_MARGIN,
            .paddle_start_pos_y = (window_height / 2.0) - (DEFAULT_PADDLE_HEIGHT / 2.0),
            .scoreboard_font_size = DEFAULT_FONT_SIZE,
            .scoreboard_pos_y = DEFAULT_SCOREBOARD_POS_Y,
        };
    }
};