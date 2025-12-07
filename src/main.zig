const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;
const Ball = @import("ball.zig").Ball;
const Player = @import("player.zig").Player;

pub fn main() !void {
    var config = Config.init(800, 600);

    rl.initWindow(@intFromFloat(config.window_width), @intFromFloat(config.window_height), "Pong");
    defer rl.closeWindow();

    var ai: Player = Player.init(config.paddle_margin, config.paddle_start_pos_y, config, rl.KeyboardKey.w, rl.KeyboardKey.s);
    var player: Player = Player.init(config.window_width - config.paddle_margin - config.paddle_width, config.paddle_start_pos_y, config, rl.KeyboardKey.up, rl.KeyboardKey.down);

    var ball: Ball = Ball.init(config.window_width / 2, config.window_height / 2, &config);

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        const delta_time: f32 = rl.getFrameTime();

        const scoreboard: [:0]const u8 = rl.textFormat("{ %d : %d }", .{ ai.score, player.score });

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        const text_width: f32 = @floatFromInt(rl.measureText(scoreboard, 40));
        const text_x: i32 = @intFromFloat((config.window_width - text_width) / 2);
        rl.drawText(scoreboard, text_x, 25, 40, rl.Color.green);

        rl.drawFPS(25, 25);

        player.update(delta_time);
        ai.update(delta_time);

        ball.update(delta_time);

        ball.handleWallCollision(config.wall_top, config.wall_bottom);

        if (ball.position.x - ball.radius < config.ai_goal) {
            ball.reset(rl.Vector2.init(config.window_width / 2, config.window_height / 2));
            player.score += 1;
        }
        if (ball.position.x + ball.radius > config.user_goal) {
            ball.reset(rl.Vector2.init(config.window_width / 2, config.window_height / 2));
            ai.score += 1;
        }

        ball.handlePaddleCollision(player.paddle);
        ball.handlePaddleCollision(ai.paddle);
        ball.draw();

        rl.drawRectangleRoundedLinesEx(rl.Rectangle.init(10, 10, config.window_width - 20, config.window_height - 20), 0.01, 2, 4, rl.Color.green);
        player.draw();
        ai.draw();
    }
}
