const rl = @import("raylib");
const Config = @import("config.zig").Config;
const std = @import("std");

pub const Ball = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius: f32 = 10,
    colour: rl.Color = rl.Color.green,
    config: *Config,

    pub fn init(pos_x: f32, pos_y: f32, config: *Config) Ball {
        return .{
            .position = rl.Vector2.init(pos_x, pos_y),
            .velocity = rl.Vector2.init(250, 100),
            .config = config,
        };
    }

    pub fn update(self: *Ball, delta: f32) void {
        self.position = self.position.add(self.velocity.scale(delta));
    }

    pub fn draw(self: Ball) void {
        rl.drawCircleV(self.position, self.radius, self.colour);
    }

    pub fn reset(self: *Ball, reset_point: rl.Vector2) void {
        self.position = reset_point;
        self.velocity.x = -self.velocity.x;
    }

    pub fn handleWallCollision(self: *Ball, wall_top: f32, wall_bottom: f32) void {
        if (self.position.y - self.radius < wall_top) {
            self.velocity.y = -self.velocity.y;
            self.position.y = wall_top + self.radius;
        }
        if (self.position.y + self.radius > wall_bottom) {
            self.velocity.y = -self.velocity.y;
            self.position.y = wall_bottom - self.radius;
        }
    }

    pub fn handlePaddleCollision(self: *Ball, paddle: rl.Rectangle) void {
        if (rl.checkCollisionCircleRec(self.position, self.radius, paddle)) {
            // TODO: Fix bug where ball can slightly enter the paddle causing vibration of ball
            self.velocity.x = -self.velocity.x;
            const paddle_center = paddle.y + paddle.height / 2;
            const hit_offset = (self.position.y - paddle_center) / (paddle.height / 2);
            const max_offset: f32 = 200;
            self.velocity.y = std.math.clamp(hit_offset, -1, 1) * max_offset;
        }
    }
};