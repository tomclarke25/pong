pub const DifficultyConfig = struct {
    dead_zone: f32,
    prediction_error_range: i8,
    reaction_delay_seconds: f32,
    speed_multiplier: f32,

    pub fn easy() DifficultyConfig {
        return .{
            .dead_zone = 30,
            .prediction_error_range = 50,
            .reaction_delay_seconds = 0.33,
            .speed_multiplier = 0.6,
        };
    }
    pub fn medium() DifficultyConfig {
        return .{
            .dead_zone = 20,
            .prediction_error_range = 20,
            .reaction_delay_seconds = 0.17,
            .speed_multiplier = 0.8,
        };
    }
    pub fn hard() DifficultyConfig {
        return .{
            .dead_zone = 10,
            .prediction_error_range = 5,
            .reaction_delay_seconds = 0.05,
            .speed_multiplier = 1.0,
        };
    }
    pub fn perfect() DifficultyConfig {
        return .{
            .dead_zone = 10,
            .prediction_error_range = 0,
            .reaction_delay_seconds = 0,
            .speed_multiplier = 1.0,
        };
    }
};