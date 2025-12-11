const rl = @import("raylib");
const Action = @import("../action.zig").Action;

pub const HumanController = struct {
    up_key: rl.KeyboardKey,
    down_key: rl.KeyboardKey,

    pub fn init(up_key: rl.KeyboardKey, down_key: rl.KeyboardKey) HumanController {
        return .{
            .up_key = up_key,
            .down_key = down_key,
        };
    }

    pub fn selectAction(self: *HumanController) Action {
        if (rl.isKeyDown(self.up_key) and !rl.isKeyDown(self.down_key)) {
            return .up;
        }
        if (rl.isKeyDown(self.down_key) and !rl.isKeyDown(self.up_key)) {
            return .down;
        }
        return .stay;
    }
};
