const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;

pub const Player = struct {

    const PADDLE_WALL_GAP: f32 = 30;

    paddle: rl.Rectangle,
    score: i32 = 0,
    up_key: rl.KeyboardKey,
    down_key: rl.KeyboardKey,
    config: *const Config,

    pub fn init(pos_x: f32, pos_y: f32, config: *const Config, up_key: rl.KeyboardKey, down_key: rl.KeyboardKey) Player {
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
        if (rl.isKeyDown(self.up_key)) {
            self.paddle.y -= self.config.paddle_speed_pixels_per_sec * delta_time;
        }
        if (rl.isKeyDown(self.down_key)) {
            self.paddle.y += self.config.paddle_speed_pixels_per_sec * delta_time;
        }
        // Top only gap like the original pong bug
        const min_y = self.config.wall_top + PADDLE_WALL_GAP;
        const max_y = self.config.wall_bottom - self.config.paddle_height;
        self.paddle.y = std.math.clamp(self.paddle.y, min_y, max_y);
    }
};