const HumanController = @import("controllers/human.zig").HumanController;
const TrackerAIController = @import("controllers/tracker.zig").TrackerAIController;
const GameView = @import("game_view.zig").GameView;
const Action = @import("action.zig").Action;

pub const Controller = union(enum) {
    human_controller: HumanController,
    tracker_ai_controller: TrackerAIController,
    
    pub fn selectAction(self: *Controller, game_view: GameView) Action {
        return switch (self.*) {
            .human_controller => |*h| h.selectAction(),
            .tracker_ai_controller => |_| TrackerAIController.selectAction(game_view),
        };
    }
};