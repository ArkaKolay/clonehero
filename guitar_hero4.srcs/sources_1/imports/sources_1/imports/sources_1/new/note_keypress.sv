module note_keypress(
    input  logic [9:0]   drawx,
    input  logic [9:0]   drawy,
    input  logic [31:0]  keycode0,
    input  logic [31:0]  keycode1,
    output logic [3:0]   red,
    output logic [3:0]   green,
    output logic [3:0]   blue
);
    parameter int HIGHWAY_START = 120;
    parameter int HIGHWAY_WIDTH = 400;
    parameter int LANE_WIDTH = HIGHWAY_WIDTH / 5;
    parameter int TICK_21_TOP_Y = 420;
    parameter int TICK_21_BOTTOM_Y = 440;
    parameter int GAP = 3;
    parameter int LANE_GAP = 7;
    parameter int BOX_WIDTH = LANE_WIDTH - 2 * LANE_GAP;

    // Lane colors
    parameter logic [3:0] GREEN_RED = 4'b0011, GREEN_GREEN = 4'b1111, GREEN_BLUE = 4'b0011;
    parameter logic [3:0] RED_RED = 4'b1111, RED_GREEN = 4'b0011, RED_BLUE = 4'b0011;
    parameter logic [3:0] YELLOW_RED = 4'b1111, YELLOW_GREEN = 4'b1111, YELLOW_BLUE = 4'b0011;
    parameter logic [3:0] BLUE_RED = 4'b0011, BLUE_GREEN = 4'b0011, BLUE_BLUE = 4'b1111;
    parameter logic [3:0] ORANGE_RED = 4'b1111, ORANGE_GREEN = 4'b1001, ORANGE_BLUE = 4'b0011;

    logic [4:0] keypress;

    // keycodes
    logic [7:0] key0_0 = keycode0 [7:0];
    logic [7:0] key0_1 = keycode0 [15:8];
    logic [7:0] key0_2 = keycode0 [23:16];
    logic [7:0] key0_3 = keycode0 [31:24];
    logic [7:0] key1_0 = keycode1 [7:0];
    logic [7:0] key1_1 = keycode1 [15:8];
    logic [7:0] key1_2 = keycode1 [23:16];
    logic [7:0] key1_3 = keycode1 [31:24];

    always_comb begin
    // Default: no keys are pressed
    keypress = 5'b00000;
    
    // Check all key codes individually and set corresponding keypress bits
    if (key0_0 == 8'h07 || key0_1 == 8'h07 || key0_2 == 8'h07 || key0_3 == 8'h07 ||
        key1_0 == 8'h07 || key1_1 == 8'h07 || key1_2 == 8'h07 || key1_3 == 8'h07) 
        keypress[0] = 1; // Green key

    if (key0_0 == 8'h09 || key0_1 == 8'h09 || key0_2 == 8'h09 || key0_3 == 8'h09 ||
        key1_0 == 8'h09 || key1_1 == 8'h09 || key1_2 == 8'h09 || key1_3 == 8'h09) 
        keypress[1] = 1; // Red key

    if (key0_0 == 8'h0D || key0_1 == 8'h0D || key0_2 == 8'h0D || key0_3 == 8'h0D ||
        key1_0 == 8'h0D || key1_1 == 8'h0D || key1_2 == 8'h0D || key1_3 == 8'h0D) 
        keypress[2] = 1; // Yellow key

    if (key0_0 == 8'h0E || key0_1 == 8'h0E || key0_2 == 8'h0E || key0_3 == 8'h0E ||
        key1_0 == 8'h0E || key1_1 == 8'h0E || key1_2 == 8'h0E || key1_3 == 8'h0E) 
        keypress[3] = 1; // Blue key

    if (key0_0 == 8'h0F || key0_1 == 8'h0F || key0_2 == 8'h0F || key0_3 == 8'h0F ||
        key1_0 == 8'h0F || key1_1 == 8'h0F || key1_2 == 8'h0F || key1_3 == 8'h0F) 
        keypress[4] = 1; // Orange key
    end

    // Default color to black
    always_comb begin
        red = 4'b0000;
        green = 4'b0000;
        blue = 4'b0000;

        // Draw boxes based on active keys
        if (keypress[0] && // Green key
            (((drawy == TICK_21_TOP_Y + GAP || drawy == TICK_21_BOTTOM_Y - GAP) &&
              drawx >= HIGHWAY_START + LANE_GAP && drawx < HIGHWAY_START + LANE_GAP + BOX_WIDTH) ||
             ((drawx == HIGHWAY_START + LANE_GAP || drawx == HIGHWAY_START + LANE_GAP + BOX_WIDTH - 1) &&
              drawy >= TICK_21_TOP_Y + GAP && drawy < TICK_21_BOTTOM_Y - GAP))
        ) begin
            red = GREEN_RED;
            green = GREEN_GREEN;
            blue = GREEN_BLUE;
        end else if (keypress[1] && // Red key
            (((drawy == TICK_21_TOP_Y + GAP || drawy == TICK_21_BOTTOM_Y - GAP) &&
              drawx >= HIGHWAY_START + LANE_WIDTH + LANE_GAP && drawx < HIGHWAY_START + LANE_WIDTH + LANE_GAP + BOX_WIDTH) ||
             ((drawx == HIGHWAY_START + LANE_WIDTH + LANE_GAP || drawx == HIGHWAY_START + LANE_WIDTH + LANE_GAP + BOX_WIDTH - 1) &&
              drawy >= TICK_21_TOP_Y + GAP && drawy < TICK_21_BOTTOM_Y - GAP))
        ) begin
            red = RED_RED;
            green = RED_GREEN;
            blue = RED_BLUE;
        end else if (keypress[2] && // Yellow key
            (((drawy == TICK_21_TOP_Y + GAP || drawy == TICK_21_BOTTOM_Y - GAP) &&
              drawx >= HIGHWAY_START + 2 * LANE_WIDTH + LANE_GAP && drawx < HIGHWAY_START + 2 * LANE_WIDTH + LANE_GAP + BOX_WIDTH) ||
             ((drawx == HIGHWAY_START + 2 * LANE_WIDTH + LANE_GAP || drawx == HIGHWAY_START + 2 * LANE_WIDTH + LANE_GAP + BOX_WIDTH - 1) &&
              drawy >= TICK_21_TOP_Y + GAP && drawy < TICK_21_BOTTOM_Y - GAP))
        ) begin
            red = YELLOW_RED;
            green = YELLOW_GREEN;
            blue = YELLOW_BLUE;
        end else if (keypress[3] && // Blue key
            (((drawy == TICK_21_TOP_Y + GAP || drawy == TICK_21_BOTTOM_Y - GAP) &&
              drawx >= HIGHWAY_START + 3 * LANE_WIDTH + LANE_GAP && drawx < HIGHWAY_START + 3 * LANE_WIDTH + LANE_GAP + BOX_WIDTH) ||
             ((drawx == HIGHWAY_START + 3 * LANE_WIDTH + LANE_GAP || drawx == HIGHWAY_START + 3 * LANE_WIDTH + LANE_GAP + BOX_WIDTH - 1) &&
              drawy >= TICK_21_TOP_Y + GAP && drawy < TICK_21_BOTTOM_Y - GAP))
        ) begin
            red = BLUE_RED;
            green = BLUE_GREEN;
            blue = BLUE_BLUE;
        end else if (keypress[4] && // Orange key
            (((drawy == TICK_21_TOP_Y + GAP || drawy == TICK_21_BOTTOM_Y - GAP) &&
              drawx >= HIGHWAY_START + 4 * LANE_WIDTH + LANE_GAP && drawx < HIGHWAY_START + 4 * LANE_WIDTH + LANE_GAP + BOX_WIDTH) ||
             ((drawx == HIGHWAY_START + 4 * LANE_WIDTH + LANE_GAP || drawx == HIGHWAY_START + 4 * LANE_WIDTH + LANE_GAP + BOX_WIDTH - 1) &&
              drawy >= TICK_21_TOP_Y + GAP && drawy < TICK_21_BOTTOM_Y - GAP))
        ) begin
            red = ORANGE_RED;
            green = ORANGE_GREEN;
            blue = ORANGE_BLUE;
        end
    end
endmodule
