const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;
const Ball = @import("ball.zig").Ball;
const Player = @import("player.zig").Player;

pub const Game = struct {
    left_player: Player,
    right_player: Player,
    ball: Ball,
    config: *const Config,

    pub fn init(config: *const Config) Game {
        return .{
            .left_player = Player.init(config.paddle_margin, config.paddle_start_pos_y, config, rl.KeyboardKey.w, rl.KeyboardKey.s),
            .right_player = Player.init(config.window_width - config.paddle_margin - config.paddle_width, config.paddle_start_pos_y, config, rl.KeyboardKey.up, rl.KeyboardKey.down),
            .ball = Ball.init(config.window_width / 2, config.window_height / 2, config),
            .config = config,
        };
    }

    pub fn update(self: *Game, delta_time: f32) void {
        // Player movement
        self.right_player.update(delta_time);
        self.left_player.update(delta_time);

        // Ball physics
        self.ball.update(delta_time);
        self.ball.handleWallCollision(self.config.wall_top, self.config.wall_bottom);

        // Paddle collision
        if (self.ball.velocity.x < 0) {
            self.ball.handlePaddleCollision(self.left_player.paddle);
        } else {
            self.ball.handlePaddleCollision(self.right_player.paddle);
        }

        // Scoring
        if (self.ball.position.x - self.ball.radius < self.config.left_goal) {
            self.ball.reset(rl.Vector2.init(self.config.window_width / 2, self.config.window_height / 2));
            self.right_player.score += 1;
        }
        if (self.ball.position.x + self.ball.radius > self.config.right_goal) {
            self.ball.reset(rl.Vector2.init(self.config.window_width / 2, self.config.window_height / 2));
            self.left_player.score += 1;
        }
    }

    pub fn render(self: *const Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        // UI elements
        const scoreboard: [:0]const u8 = rl.textFormat("{ %d : %d }", .{ self.left_player.score, self.right_player.score });
        const text_width: f32 = @floatFromInt(rl.measureText(scoreboard, self.config.scoreboard_font_size));
        const text_x: i32 = @intFromFloat((self.config.window_width - text_width) / 2);
        rl.drawText(scoreboard, text_x, self.config.scoreboard_pos_y, self.config.scoreboard_font_size, rl.Color.green);
        rl.drawFPS(25, 25);

        // Game boundary
        const game_boundary: rl.Rectangle = rl.Rectangle.init(10, 10, self.config.window_width - 20, self.config.window_height - 20);
        rl.drawRectangleRoundedLinesEx(game_boundary, 0.01, 2, 4, rl.Color.green);

        // Game objects
        self.ball.draw();
        self.right_player.draw();
        self.left_player.draw();
    }
};