const rl = @import("raylib");
const constants = @import("constants.zig");
const Game = @import("game.zig").Game;

pub fn main() !void {
    rl.initWindow(@intFromFloat(constants.window_width), @intFromFloat(constants.window_height), "Pong");
    defer rl.closeWindow();

    var game: Game = Game.init();

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        const delta_time: f32 = rl.getFrameTime();

        // Skip update on first frame.
        if (delta_time > 0) {
            game.update(delta_time);
        }

        game.render();
    }
}