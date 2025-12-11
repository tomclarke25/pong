const rl = @import("raylib");
const std = @import("std");
const assert = std.debug.assert;

pub fn predictBallY(
    ball_position: rl.Vector2,
    ball_velocity: rl.Vector2,
    ball_radius: f32,
    target_x: f32,
    wall_top: f32,
    wall_bottom: f32,
) f32 {
    assert(ball_velocity.x != 0);
    assert(wall_top < wall_bottom);

    const time_to_intercept = (target_x - ball_position.x) / ball_velocity.x;
    const bound_top = wall_top + ball_radius;
    const bound_bottom = wall_bottom - ball_radius;
    const height_playable = bound_bottom - bound_top;

    assert(time_to_intercept > 0);
    assert(height_playable > 0);

    const y_raw = ball_position.y + (ball_velocity.y * time_to_intercept);

    var y_folded = @abs(y_raw - bound_top);

    y_folded = @mod(y_folded, (2 * height_playable));

    if (y_folded > height_playable) {
        y_folded = (2 * height_playable) - y_folded;
    }
    assert(y_folded >= 0 and y_folded <= height_playable);

    const predicted_y = y_folded + bound_top;

    assert(predicted_y >= bound_top);
    assert(predicted_y <= bound_bottom);
    return predicted_y;
}
