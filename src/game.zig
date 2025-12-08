const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;
const Ball = @import("ball.zig").Ball;
const Player = @import("player.zig").Player;
const assert = std.debug.assert;

pub const Game = struct {
    left_player: Player,
    right_player: Player,
    ball: Ball,
    config: *const Config,
    serve_delay_timer: f32 = 0,

    const BOUNDARY_MARGIN: f32 = 10;
    const BOUNDARY_ROUNDNESS: f32 = 0.01;
    const BOUNDARY_SEGMENTS: i32 = 2;
    const BOUNDARY_LINE_THICKNESS: f32 = 4;

    const CENTER_LINE_DASH_LENGTH: f32 = 10;
    const CENTER_LINE_DASH_SPACING: f32 = 20;
    const CENTER_LINE_DASH_COLOUR: rl.Color = rl.Color.green;

    const SERVE_DELAY_SECONDS: f32 = 0.3;
    const WINNING_SCORE: i32 = 5;

    pub fn init(config: *const Config) Game {
        return .{
            .left_player = Player.init(config.paddle_margin, config.paddle_start_pos_y, config, rl.KeyboardKey.w, rl.KeyboardKey.s),
            .right_player = Player.init(config.window_width - config.paddle_margin - config.paddle_width, config.paddle_start_pos_y, config, rl.KeyboardKey.up, rl.KeyboardKey.down),
            .ball = Ball.init(config.window_width / 2, config.window_height / 2, config),
            .config = config,
            .serve_delay_timer = SERVE_DELAY_SECONDS,
        };
    }

    pub fn update(self: *Game, delta_time: f32) void {
        assert(delta_time > 0);

        self.right_player.update(delta_time);
        self.left_player.update(delta_time);

        if (self.serve_delay_timer > 0) {
            self.serve_delay_timer -= delta_time;
            return;
        }

        self.ball.update(delta_time);
        self.ball.handleWallCollision(self.config.wall_top, self.config.wall_bottom);

        // Only check collision with paddle the ball is moving toward.
        if (self.ball.velocity.x < 0) {
            self.ball.handlePaddleCollision(self.left_player.paddle);
        } else {
            self.ball.handlePaddleCollision(self.right_player.paddle);
        }

        if (self.ball.position.x - self.ball.radius < self.config.left_goal) {
            self.ball.reset(rl.Vector2.init(self.config.window_width / 2, self.config.window_height / 2));
            self.right_player.score += 1;
            self.serve_delay_timer = SERVE_DELAY_SECONDS;
            if (self.right_player.score >= WINNING_SCORE) {
                self.right_player.score = 0;
                self.left_player.score = 0;
                return;
            }
        }
        if (self.ball.position.x + self.ball.radius > self.config.right_goal) {
            self.ball.reset(rl.Vector2.init(self.config.window_width / 2, self.config.window_height / 2));
            self.left_player.score += 1;
            self.serve_delay_timer = SERVE_DELAY_SECONDS;
            if (self.left_player.score >= WINNING_SCORE) {
                self.right_player.score = 0;
                self.left_player.score = 0;
                return;
            }
        }
    }

    pub fn render(self: *const Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        const scoreboard: [:0]const u8 = rl.textFormat("{ %d : %d }", .{ self.left_player.score, self.right_player.score });
        const text_width: f32 = @floatFromInt(rl.measureText(scoreboard, self.config.scoreboard_font_size));
        const text_x: i32 = @intFromFloat((self.config.window_width - text_width) / 2);
        rl.drawText(scoreboard, text_x, self.config.scoreboard_pos_y, self.config.scoreboard_font_size, rl.Color.green);

        const game_boundary: rl.Rectangle = rl.Rectangle.init(BOUNDARY_MARGIN, BOUNDARY_MARGIN, self.config.window_width - (BOUNDARY_MARGIN * 2), self.config.window_height - (BOUNDARY_MARGIN * 2));
        rl.drawRectangleRoundedLinesEx(game_boundary, BOUNDARY_ROUNDNESS, BOUNDARY_SEGMENTS, BOUNDARY_LINE_THICKNESS, rl.Color.green);

        // Temporary dashed line until drawLineDashed is merged into raylib-zig
        var dash_y: f32 = BOUNDARY_MARGIN;
        const dash_end_y: f32 = self.config.window_height - BOUNDARY_MARGIN;
        const center_x: f32 = self.config.window_width / 2;
        while (dash_y < dash_end_y) : (dash_y += CENTER_LINE_DASH_SPACING) {
            rl.drawLineEx(rl.Vector2.init(center_x, dash_y), rl.Vector2.init(center_x, dash_y + CENTER_LINE_DASH_LENGTH), BOUNDARY_LINE_THICKNESS, CENTER_LINE_DASH_COLOUR);
        }

        self.ball.draw();
        self.right_player.draw();
        self.left_player.draw();
    }
};
