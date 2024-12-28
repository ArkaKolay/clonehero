module vga_guitar_hero_combined(
    input  logic         clk,
    input  logic         reset,
    input  logic [9:0]   drawx,
    input  logic [9:0]   drawy,
    input  logic [31:0]  keycode0,
    input  logic [31:0]  keycode1,
    input  logic         active_nblank,
    input  logic [4:0]   tick_notes[0:23],
    input  logic [19:0]  score,
    input  logic [3:0]   multiplier,
    input  logic [9:0]   streak,
    input  logic [1:0]   current_state, // Game state
    input  logic [7:0]   progress_percentage,
    output logic [3:0]   red,
    output logic [3:0]   green,
    output logic [3:0]   blue
);

    // Game states
    typedef enum logic [1:0] {START_SCREEN, GAME_PLAY, GAME_OVER} game_state_t;

    // Signals for rendering
    logic [3:0] start_red, start_green, start_blue;
    logic [3:0] text_red, text_green, text_blue;
    logic [3:0] notes_red, notes_green, notes_blue;
    logic [3:0] indicator_red, indicator_green, indicator_blue;
    logic [3:0] game_over_red, game_over_green, game_over_blue;
    logic [3:0] progress_red, progress_green, progress_blue;
    logic [3:0] scoreboard_red, scoreboard_green, scoreboard_blue;

    // Start Screen Display Instance
    start_screen_display start_screen_inst (
        .clk(clk),
        .drawX(drawx),
        .drawY(drawy),
        .active_nblank(active_nblank && (current_state == START_SCREEN)), // Only active in START_SCREEN
        .keycode(keycode0[7:0]),
        .red(start_red),
        .green(start_green),
        .blue(start_blue)
    );
    
    // Key Indicators
    note_keypress keypress_inst (
        .drawx(drawx),
        .drawy(drawy),
        .keycode0(keycode0),
        .keycode1(keycode1),
        .red(indicator_red),
        .green(indicator_green),
        .blue(indicator_blue)
    );

    // Guitar Hero Notes
    guitar_hero_notes notes_inst (
        .drawx(drawx),
        .drawy(drawy),
        .tick_notes(tick_notes),
        .red(notes_red),
        .green(notes_green),
        .blue(notes_blue)
    );

    // Text Display
    vga_text_display text_inst (
        .clk(clk),
        .drawX(drawx),
        .drawY(drawy),
        .active_nblank(active_nblank),
        .score(score),
        .multiplier(multiplier),
        .streak(streak),
        .red(text_red),
        .green(text_green),
        .blue(text_blue)
    );
    
    // Game Over Display Instance
    game_over_display game_over_inst (
        .clk(clk),
        .drawX(drawx),
        .drawY(drawy),
        .active_nblank(active_nblank && (current_state == GAME_OVER)), // Only active in GAME_OVER
        .score(score),
        .red(game_over_red),
        .green(game_over_green),
        .blue(game_over_blue)
    );

    // Progress Bar Display Instance
    progress_bar_display progress_bar_inst (
        .drawX(drawx),
        .drawY(drawy),
        .active_nblank(active_nblank),
        .progress_percentage(progress_percentage),
        .game_play_active(current_state == GAME_PLAY),
        .red(progress_red),
        .green(progress_green),
        .blue(progress_blue)
    );

    // Rendering Logic with Priority
    always_comb begin
        case (current_state)
            START_SCREEN: begin
                // Render priority: black background for scoreboard > scoreboard > start screen
                if (drawx >= 480 && drawx < 640 && drawy >= 40 && drawy < 200) begin
                    red = 4'h0; // Black background for scoreboard
                    green = 4'h0;
                    blue = 4'h0;
                end else if (scoreboard_red != 4'h0 || scoreboard_green != 4'h0 || scoreboard_blue != 4'h0) begin
                    red = scoreboard_red;
                    green = scoreboard_green;
                    blue = scoreboard_blue;
                end else begin
                    red = start_red;
                    green = start_green;
                    blue = start_blue;
                end
            end
            GAME_PLAY: begin
                // priority: text > indicators > progress bar > notes
                if (text_red != 4'h0 || text_green != 4'h0 || text_blue != 4'h0) begin
                    red = text_red;
                    green = text_green;
                    blue = text_blue;
                end else if (indicator_red != 4'h0 || indicator_green != 4'h0 || indicator_blue != 4'h0) begin
                    red = indicator_red;
                    green = indicator_green;
                    blue = indicator_blue;
                end else if (progress_red != 4'h0 || progress_green != 4'h0 || progress_blue != 4'h0) begin
                    red = progress_red;
                    green = progress_green;
                    blue = progress_blue;
                end else begin
                    red = notes_red;
                    green = notes_green;
                    blue = notes_blue;
                end
            end
            GAME_OVER: begin
                // Use game over screen outputs
                red = game_over_red;
                green = game_over_green;
                blue = game_over_blue;
            end
            default: begin
                red = 4'h0;
                green = 4'h0;
                blue = 4'h0;
            end
        endcase
    end
endmodule
