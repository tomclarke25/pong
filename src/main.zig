const std = @import("std");
const rl = @import("raylib");
const Config = @import("config.zig").Config;
const Ball = @import("ball.zig").Ball;
const Player = @import("player.zig").Player;
const Game = @import("game.zig").Game;

pub fn main() !void {
    const config: Config = Config.init(800, 600);

    rl.initWindow(@intFromFloat(config.window_width), @intFromFloat(config.window_height), "Pong");
    defer rl.closeWindow();

    var game: Game = Game.init(&config);

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        const delta_time: f32 = rl.getFrameTime();

        // Skip update on first frame
        if (delta_time > 0) {
            game.update(delta_time);
        }

        game.render();
    }
}
