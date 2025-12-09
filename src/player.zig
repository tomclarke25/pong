const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");
const assert = std.debug.assert;

pub const paddle_width: f32 = 10;
pub const paddle_height: f32 = 100;
pub const paddle_colour: rl.Color = rl.Color.green;
pub const paddle_margin: f32 = 25;
const paddle_speed_pixels_per_sec: f32 = 450;

pub const Player = struct {
    paddle: rl.Rectangle,
    score: i32 = 0,
    up_key: rl.KeyboardKey,
    down_key: rl.KeyboardKey,
    paddle_lower_bound: f32,
    paddle_upper_bound: f32,

    const PADDLE_WALL_GAP: f32 = 30;
    const PADDLE_ROUNDNESS: f32 = 0.01;
    const PADDLE_SEGMENTS: i32 = 1;
    const PADDLE_LINE_THICKNESS: f32 = 4;

    pub fn init(position_x: f32, position_y: f32, up_key: rl.KeyboardKey, down_key: rl.KeyboardKey) Player {
        assert(position_x >= 0);
        assert(position_x <= constants.window_width);
        assert(position_y >= 0);
        assert(position_y <= constants.window_height);

        const wall_top = constants.wall_margin;
        const wall_bottom = constants.window_height - constants.wall_margin;
        return .{
            .paddle = rl.Rectangle.init(position_x, position_y, paddle_width, paddle_height),
            .up_key = up_key,
            .down_key = down_key,
            .paddle_lower_bound = wall_top + PADDLE_WALL_GAP,
            .paddle_upper_bound = wall_bottom - paddle_height,
        };
    }

    pub fn getPaddleCenterY(self: *const Player) f32 {
        return self.paddle.y + paddle_height / 2;
    }

    pub fn draw(self: *const Player) void {
        assert(self.paddle.y >= self.paddle_lower_bound);
        assert(self.paddle.y <= self.paddle_upper_bound);
        rl.drawRectangleRoundedLinesEx(self.paddle, PADDLE_ROUNDNESS, PADDLE_SEGMENTS, PADDLE_LINE_THICKNESS, paddle_colour);
    }

    pub fn update(self: *Player, delta_time: f32) void {
        assert(delta_time > 0);
        if (rl.isKeyDown(self.up_key)) {
            self.paddle.y -= paddle_speed_pixels_per_sec * delta_time;
        }
        if (rl.isKeyDown(self.down_key)) {
            self.paddle.y += paddle_speed_pixels_per_sec * delta_time;
        }
        // Top-only gap mimics the original Pong hardware bug.
        self.paddle.y = std.math.clamp(self.paddle.y, self.paddle_lower_bound, self.paddle_upper_bound);
    }
};
