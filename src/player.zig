const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");
const Action = @import("action.zig").Action;
const assert = std.debug.assert;

pub const paddle_width: f32 = 10;
pub const paddle_height: f32 = 100;
pub const paddle_colour: rl.Color = rl.Color.green;
pub const paddle_margin: f32 = 25;
const paddle_speed_pixels_per_sec: f32 = 450;

pub const Player = struct {
    paddle: rl.Rectangle,
    score: i32 = 0,
    paddle_lower_bound: f32,
    paddle_upper_bound: f32,
    paddle_speed_multiplier: f32,

    const paddle_wall_gap: f32 = 30;
    const paddle_roundness: f32 = 0.01;
    const paddle_segments: i32 = 1;
    const paddle_line_thickness: f32 = 4;

    pub fn init(position_x: f32, position_y: f32, paddle_speed_multiplier: f32) Player {
        assert(position_x >= 0);
        assert(position_x <= constants.window_width);
        assert(position_y >= 0);
        assert(position_y <= constants.window_height);

        const wall_top = constants.wall_margin;
        const wall_bottom = constants.window_height - constants.wall_margin;
        return .{
            .paddle = rl.Rectangle.init(position_x, position_y, paddle_width, paddle_height),
            .paddle_lower_bound = wall_top + paddle_wall_gap,
            .paddle_upper_bound = wall_bottom - paddle_height,
            .paddle_speed_multiplier = paddle_speed_multiplier,
        };
    }

    pub fn getPaddleCenterY(self: *const Player) f32 {
        return self.paddle.y + (paddle_height / 2);
    }

    pub fn draw(self: *const Player) void {
        assert(self.paddle.y >= self.paddle_lower_bound);
        assert(self.paddle.y <= self.paddle_upper_bound);
        rl.drawRectangleRoundedLinesEx(self.paddle, paddle_roundness, paddle_segments, paddle_line_thickness, paddle_colour);
    }

    pub fn update(self: *Player, delta_time: f32, move_action: Action) void {
        assert(delta_time > 0);

        if (move_action == .up) {
            self.paddle.y -= paddle_speed_pixels_per_sec * delta_time * self.paddle_speed_multiplier;
        }
        if (move_action == .down) {
            self.paddle.y += paddle_speed_pixels_per_sec * delta_time * self.paddle_speed_multiplier;
        }
        // Top-only gap mimics the original Pong hardware bug.
        self.paddle.y = std.math.clamp(self.paddle.y, self.paddle_lower_bound, self.paddle_upper_bound);
    }
};
