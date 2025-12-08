const rl = @import("raylib");
const Config = @import("config.zig").Config;
const std = @import("std");
const assert = std.debug.assert;

pub const Ball = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    radius: f32 = 10,
    colour: rl.Color = rl.Color.green,
    config: *const Config,
    speed: f32,

    const INITIAL_SPEED: f32 = 250;
    const SPEED_INCREMENT: f32 = 15;
    const MAX_SPEED: f32 = 700;
    const INITIAL_ANGLE = 100;
    const MAX_ANGLE_OFFSET = 200;

    pub fn init(position_x: f32, position_y: f32, config: *const Config) Ball {
        assert(position_x >= 0);
        assert(position_x <= config.window_width);
        assert(position_y >= 0);
        assert(position_y <= config.window_height);
        const rand = std.crypto.random.float(f32);
        return .{
            .position = rl.Vector2.init(position_x, position_y),
            .velocity = rl.Vector2.init(INITIAL_SPEED, INITIAL_ANGLE * ((rand * 2) - 1)),
            .config = config,
            .speed = INITIAL_SPEED,
        };
    }

    pub fn update(self: *Ball, delta: f32) void {
        assert(delta > 0);
        self.position = self.position.add(self.velocity.scale(delta));
    }

    pub fn draw(self: Ball) void {
        assert(self.position.x > 0);
        assert(self.position.x < self.config.window_width);
        assert(self.position.y > 0);
        assert(self.position.y < self.config.window_height);
        rl.drawCircleV(self.position, self.radius, self.colour);
    }

    pub fn reset(self: *Ball, reset_point: rl.Vector2) void {
        const angle_factor_random = std.crypto.random.float(f32);
        const direction_multiplier = (angle_factor_random * 2) - 1;
        self.position = reset_point;

        const serve_direction: f32 = if (self.velocity.x > 0) -1 else 1;

        self.velocity.x = serve_direction * INITIAL_SPEED;
        self.velocity.y = MAX_ANGLE_OFFSET * direction_multiplier;

        const magnitude = @sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y);
        self.speed = INITIAL_SPEED;
        self.velocity.x = (self.velocity.x / magnitude) * self.speed;
        self.velocity.y = (self.velocity.y / magnitude) * self.speed;

        assert(self.speed == INITIAL_SPEED);
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
            self.velocity.y = std.math.clamp(hit_offset, -1, 1) * MAX_ANGLE_OFFSET;

            self.speed = @min(self.speed + SPEED_INCREMENT, MAX_SPEED);

            // Normalise speed based on angle.
            const magnitude = @sqrt(self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y);
            self.velocity.x = (self.velocity.x / magnitude) * self.speed;
            self.velocity.y = (self.velocity.y / magnitude) * self.speed;
            assert(self.speed >= INITIAL_SPEED and self.speed <= MAX_SPEED);
        }
    }
};
