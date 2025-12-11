const std = @import("std");
const rl = @import("raylib");
const constants = @import("constants.zig");
const Game = @import("game.zig").Game;
const Controller = @import("controller.zig").Controller;
const HumanController = @import("controllers/human.zig").HumanController;
const TrackerAIController = @import("controllers/tracker.zig").TrackerAIController;
const DifficultyConfig = @import("difficulty_config.zig").DifficultyConfig;

pub fn main() !void {
    rl.initWindow(@intFromFloat(constants.window_width), @intFromFloat(constants.window_height), "Pong");
    defer rl.closeWindow();

    const rng = std.crypto.random;

    const left_controller: Controller = .{ .tracker_ai_controller = TrackerAIController.init(DifficultyConfig.easy(), rng) };
    const right_controller: Controller = .{ .tracker_ai_controller = TrackerAIController.init(DifficultyConfig.perfect(), rng) };

    var game: Game = Game.init(left_controller, right_controller);

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
