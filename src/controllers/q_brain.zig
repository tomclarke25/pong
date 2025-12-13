const Action = @import("../action.zig").Action;
const std = @import("std");
const Random = std.Random;
const assert = std.debug.assert;

pub const QBrain = struct {
    q_table: [num_states][num_actions]f32,
    epsilon: f32 = 1.0,
    alpha: f32 = 0.1,
    gamma: f32 = 0.99,
    rng: Random,

    const num_bins = 20;
    const num_states = num_bins * num_bins;
    const num_actions = 3;
    const epsilon_decay = 0.95;
    const epsilon_min = 0.05;

    pub fn init(rng: Random) QBrain {
        return .{
            .q_table = std.mem.zeroes([num_states][num_actions]f32),
            .rng = rng,
        };
    }

    pub fn selectAction(self: *QBrain, state_index: u9) Action {
        const epsilon_compare_value = self.rng.float(f32);
        if (epsilon_compare_value > self.epsilon) {
            const best_choice = std.mem.indexOfMax(f32, &self.q_table[state_index]).?;
            return @enumFromInt(best_choice);
        } else {
            const random_explore_choice = self.rng.intRangeAtMost(i8, 0, 2);
            return @enumFromInt(random_explore_choice);
        }
    }

    pub fn learn(self: *QBrain, state_index: u9, action: Action, reward: f32, next_state_index: u9, is_terminal: bool) void {
        assert(state_index < num_states);
        assert(next_state_index < num_states);

        const max_next_q = if (is_terminal)
            0.0
        else
            self.q_table[next_state_index][std.mem.indexOfMax(f32, &self.q_table[next_state_index]).?];

        const target = reward + self.gamma * max_next_q;
        const current_q = self.q_table[state_index][@intFromEnum(action)];
        self.q_table[state_index][@intFromEnum(action)] = current_q + self.alpha * (target - current_q);
    }

    pub fn decayEpsilon(self: *QBrain) void {
        self.epsilon = @max(self.epsilon * epsilon_decay, epsilon_min);
        assert(self.epsilon >= epsilon_min);
    }
};