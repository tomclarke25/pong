const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;
const assert = std.debug.assert;

pub const Player = struct {
    paddle: rl.Rectangle,
    score: i32 = 0,
    up_key: rl.KeyboardKey,
    down_key: rl.KeyboardKey,
    config: *const Config,
    paddle_lower_bound: f32,
    paddle_upper_bound: f32,

    const PADDLE_WALL_GAP: f32 = 30;
    const PADDLE_ROUNDNESS: f32 = 0.01;
    const PADDLE_SEGMENTS: i32 = 1;
    const PADDLE_LINE_THICKNESS: f32 = 4;

    pub fn init(position_x: f32, position_y: f32, config: *const Config, up_key: rl.KeyboardKey, down_key: rl.KeyboardKey) Player {
        assert(position_x >= 0);
        assert(position_x <= config.window_width);
        assert(position_y >= 0);
        assert(position_y <= config.window_height);

        return .{
            .paddle = rl.Rectangle.init(position_x, position_y, config.paddle_width, config.paddle_height),
            .up_key = up_key,
            .down_key = down_key,
            .config = config,
            .paddle_lower_bound = config.wall_top + PADDLE_WALL_GAP,
            .paddle_upper_bound = config.wall_bottom - config.paddle_height,
        };
    }

    pub fn draw(self: *const Player) void {
        assert(self.paddle.y >= self.paddle_lower_bound);
        assert(self.paddle.y <= self.paddle_upper_bound);
        rl.drawRectangleRoundedLinesEx(self.paddle, PADDLE_ROUNDNESS, PADDLE_SEGMENTS, PADDLE_LINE_THICKNESS, self.config.paddle_colour);
    }

    pub fn update(self: *Player, delta_time: f32) void {
        assert(delta_time > 0);
        if (rl.isKeyDown(self.up_key)) {
            self.paddle.y -= self.config.paddle_speed_pixels_per_sec * delta_time;
        }
        if (rl.isKeyDown(self.down_key)) {
            self.paddle.y += self.config.paddle_speed_pixels_per_sec * delta_time;
        }
        // Top-only gap mimics the original Pong hardware bug.
        self.paddle.y = std.math.clamp(self.paddle.y, self.paddle_lower_bound, self.paddle_upper_bound);
        assert(self.paddle.y >= self.paddle_lower_bound and self.paddle.y <= self.paddle_upper_bound);
    }
};
