const rl = @import("raylib");
const std = @import("std");
const constants = @import("constants.zig");
const assert = std.debug.assert;

pub const Ball = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius: f32 = 10,
    colour: rl.Color = rl.Color.green,
    speed: f32,

    const initial_speed: f32 = 250;
    const speed_increment: f32 = 15;
    const max_speed: f32 = 700;
    const initial_angle = 100;
    const max_angle_offset = 200;

    pub fn init(position_x: f32, position_y: f32) Ball {
        assert(position_x >= 0);
        assert(position_x <= constants.window_width);
        assert(position_y >= 0);
        assert(position_y <= constants.window_height);
        const rand = std.crypto.random.float(f32);
        return .{
            .position = rl.Vector2.init(position_x, position_y),
            .velocity = rl.Vector2.init(initial_speed, initial_angle * ((rand * 2) - 1)),
            .speed = initial_speed,
        };
    }

    pub fn update(self: *Ball, delta: f32) void {
        assert(delta > 0);
        self.position = self.position.add(self.velocity.scale(delta));
    }

    pub fn draw(self: Ball) void {
        assert(self.position.x > 0);
        assert(self.position.x < constants.window_width);
        assert(self.position.y > 0);
        assert(self.position.y < constants.window_height);
        rl.drawCircleV(self.position, self.radius, self.colour);
    }

    pub fn reset(self: *Ball, reset_point: rl.Vector2) void {
        const angle_factor_random = std.crypto.random.float(f32);
        const direction_multiplier = (angle_factor_random * 2) - 1;
        self.position = reset_point;

        const serve_direction: f32 = if (self.velocity.x > 0) -1 else 1;

        self.velocity.x = serve_direction * initial_speed;
        self.velocity.y = max_angle_offset * direction_multiplier;

        const magnitude = @sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y);
        self.speed = initial_speed;
        self.velocity.x = (self.velocity.x / magnitude) * self.speed;
        self.velocity.y = (self.velocity.y / magnitude) * self.speed;
    }

    pub fn handleWallCollision(self: *Ball, wall_top: f32, wall_bottom: f32) void {
        assert(wall_top < wall_bottom);
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
        assert(paddle.width > 0 and paddle.height > 0);
        if (rl.checkCollisionCircleRec(self.position, self.radius, paddle)) {
            self.velocity.x = -self.velocity.x;
            if (self.velocity.x > 0) {
                self.position.x = paddle.x + paddle.width + self.radius;
            } else {
                self.position.x = paddle.x - self.radius;
            }
            const paddle_center = paddle.y + paddle.height / 2;
            const hit_offset = (self.position.y - paddle_center) / (paddle.height / 2);
            self.velocity.y = std.math.clamp(hit_offset, -1, 1) * max_angle_offset;

            self.speed = @min(self.speed + speed_increment, max_speed);

            // Normalise speed based on angle.
            const magnitude = @sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y);
            self.velocity.x = (self.velocity.x / magnitude) * self.speed;
            self.velocity.y = (self.velocity.y / magnitude) * self.speed;
            assert(self.speed >= initial_speed and self.speed <= max_speed);
        }
    }
};
