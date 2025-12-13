const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");
const Ball = @import("ball.zig").Ball;
const Player = @import("player.zig").Player;
const player = @import("player.zig");
const Controller = @import("controller.zig").Controller;
const GameView = @import("game_view.zig").GameView;
const assert = std.debug.assert;

pub const Game = struct {
    left_player: Player,
    right_player: Player,
    ball: Ball,
    serve_delay_timer: f32 = 0,
    left_controller: Controller,
    right_controller: Controller,

    const boundary_roundness: f32 = 0.01;
    const boundary_segments: i32 = 2;
    const boundary_line_thickness: f32 = 4;

    const center_line_dash_length: f32 = 10;
    const center_line_dash_spacing: f32 = 20;
    const center_line_dash_colour: rl.Color = rl.Color.green;

    const scoreboard_font_size: i32 = 40;
    const scoreboard_pos_y: i32 = 25;

    const serve_delay_seconds: f32 = 0.3;
    const winning_score: i32 = 5;

    pub fn init(left_controller: Controller, right_controller: Controller) Game {
        const paddle_start_y = (constants.window_height / 2.0) - (player.paddle_height / 2.0);
        const right_paddle_x = constants.window_width - player.paddle_margin - player.paddle_width;

        return .{
            .left_player = Player.init(player.paddle_margin, paddle_start_y, left_controller.getSpeedMultiplier()),
            .right_player = Player.init(right_paddle_x, paddle_start_y, right_controller.getSpeedMultiplier()),
            .left_controller = left_controller,
            .right_controller = right_controller,
            .ball = Ball.init(constants.window_width / 2, constants.window_height / 2),
            .serve_delay_timer = serve_delay_seconds,
        };
    }

    pub fn update(self: *Game, delta_time: f32) void {
        assert(delta_time > 0);

        if (self.serve_delay_timer > 0) {
            self.serve_delay_timer -= delta_time;
            return;
        }

        self.ball.update(delta_time);

        const wall_top = constants.wall_margin;
        const wall_bottom = constants.window_height - constants.wall_margin;
        self.ball.handleWallCollision(wall_top, wall_bottom);

        // Only check collision with paddle the ball is moving toward.
        if (self.ball.velocity.x < 0) {
            self.ball.handlePaddleCollision(self.left_player.paddle);
        } else {
            self.ball.handlePaddleCollision(self.right_player.paddle);
        }

        const left_goal = constants.wall_margin;
        const right_goal = constants.window_width - constants.wall_margin;
        const reset_point = rl.Vector2.init(constants.window_width / 2, constants.window_height / 2);

        if (self.ball.position.x - self.ball.radius < left_goal) {
            self.ball.reset(reset_point);
            self.right_player.score += 1;
            self.serve_delay_timer = serve_delay_seconds;
            if (self.right_player.score >= winning_score) {
                self.right_player.score = 0;
                self.left_player.score = 0;
                return;
            }
        }
        if (self.ball.position.x + self.ball.radius > right_goal) {
            self.ball.reset(reset_point);
            self.left_player.score += 1;
            self.serve_delay_timer = serve_delay_seconds;
            if (self.left_player.score >= winning_score) {
                self.right_player.score = 0;
                self.left_player.score = 0;
                return;
            }
        }

        const left_view: GameView = self.createGameView(&self.left_player, .left);
        const right_view: GameView = self.createGameView(&self.right_player, .right);

        self.right_player.update(delta_time, self.right_controller.selectAction(right_view, delta_time));
        self.left_player.update(delta_time, self.left_controller.selectAction(left_view, delta_time));
    }

    pub fn render(self: *const Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        const scoreboard: [:0]const u8 = rl.textFormat("{ %d : %d }", .{ self.left_player.score, self.right_player.score });
        const text_width: f32 = @floatFromInt(rl.measureText(scoreboard, scoreboard_font_size));
        const text_x: i32 = @intFromFloat((constants.window_width - text_width) / 2);
        rl.drawText(scoreboard, text_x, scoreboard_pos_y, scoreboard_font_size, rl.Color.green);

        const game_boundary: rl.Rectangle = rl.Rectangle.init(constants.wall_margin, constants.wall_margin, constants.window_width - (constants.wall_margin * 2), constants.window_height - (constants.wall_margin * 2));
        rl.drawRectangleRoundedLinesEx(game_boundary, boundary_roundness, boundary_segments, boundary_line_thickness, rl.Color.green);

        // Temporary dashed line until drawLineDashed is merged into raylib-zig.
        var dash_y: f32 = constants.wall_margin;
        const dash_end_y: f32 = constants.window_height - constants.wall_margin;
        const center_x: f32 = constants.window_width / 2;
        while (dash_y < dash_end_y) : (dash_y += center_line_dash_spacing) {
            rl.drawLineEx(rl.Vector2.init(center_x, dash_y), rl.Vector2.init(center_x, dash_y + center_line_dash_length), boundary_line_thickness, center_line_dash_colour);
        }

        self.ball.draw();
        self.right_player.draw();
        self.left_player.draw();
    }

    fn createGameView(self: *const Game, paddle: *const Player, player_side: enum { left, right }) GameView {
        const wall_top = constants.wall_margin;
        const wall_bottom = constants.window_height - constants.wall_margin;
        const target_x: f32 = switch (player_side) {
            .left => paddle.paddle.x + paddle.paddle.width + self.ball.radius,
            .right => paddle.paddle.x - self.ball.radius,
        };
        const ball_approaching = switch (player_side) {
            .left => self.ball.velocity.x < 0 and self.ball.position.x > target_x,
            .right => self.ball.velocity.x > 0 and self.ball.position.x < target_x,
        };

        return GameView.init(
            self.ball.position,
            self.ball.velocity,
            self.ball.radius,
            target_x,
            wall_top,
            wall_bottom,
            paddle.getPaddleCenterY(),
            ball_approaching,
        );
    }
};
