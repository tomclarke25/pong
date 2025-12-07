const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;

pub const Player = struct {
    paddle: rl.Rectangle,
    score: i32 = 0,
    up_key: rl.KeyboardKey,
    down_key: rl.KeyboardKey,
    config: Config,

    pub fn init(pos_x: f32, pos_y: f32, config: Config, up_key: rl.KeyboardKey, down_key: rl.KeyboardKey) Player {
        return .{
            .paddle = rl.Rectangle.init(pos_x, pos_y, config.paddle_width, config.paddle_height),
            .up_key = up_key,
            .down_key = down_key,
            .config = config,
        };
    }

    pub fn draw(self: *const Player) void {
        rl.drawRectangleRoundedLinesEx(self.paddle, 0.01, 1, 4, self.config.paddle_colour);
    }

    pub fn update(self: *Player, delta_time: f32) void {
        if (rl.isKeyDown(self.up_key)) self.paddle.y -= self.config.paddle_speed_pixels_per_sec * delta_time;
        if (rl.isKeyDown(self.down_key)) self.paddle.y += self.config.paddle_speed_pixels_per_sec * delta_time;
        self.paddle.y = std.math.clamp(self.paddle.y, 10, self.config.window_height - 10 - self.config.paddle_height);
    }
};