module guitar_hero_notes(
    input logic [9:0] drawx,        
    input logic [9:0] drawy,        
    input logic [4:0] tick_notes[0:23], 
    output logic [3:0] red,         
    output logic [3:0] green,       
    output logic [3:0] blue         
);

    // screen parameters
    localparam int SCREEN_WIDTH = 640;
    localparam int SCREEN_HEIGHT = 480;
    localparam int NUM_CHUNKS = 16;
    localparam int CHUNK_SIZE = SCREEN_WIDTH / NUM_CHUNKS;
    localparam int HIGHWAY_WIDTH = 10 * CHUNK_SIZE;
    localparam int HIGHWAY_START = 3 * CHUNK_SIZE;

    // lane positions
    localparam int LANE_WIDTH = HIGHWAY_WIDTH / 5;
    localparam int GREEN_LANE_START = HIGHWAY_START;
    localparam int RED_LANE_START = GREEN_LANE_START + LANE_WIDTH;
    localparam int YELLOW_LANE_START = RED_LANE_START + LANE_WIDTH;
    localparam int BLUE_LANE_START = YELLOW_LANE_START + LANE_WIDTH;
    localparam int ORANGE_LANE_START = BLUE_LANE_START + LANE_WIDTH;

    // Note dimensions
    localparam int NOTE_HEIGHT = 20;
    localparam int NOTE_WIDTH = LANE_WIDTH - 8;

    // to show where to play notes
    localparam int TICK_21_INDEX = 21;
    localparam int TICK_21_TOP_Y = TICK_21_INDEX * NOTE_HEIGHT;
    localparam int TICK_21_BOTTOM_Y = TICK_21_TOP_Y + NOTE_HEIGHT;

    always_comb begin
        red = 4'b0000;
        green = 4'b0000;
        blue = 4'b0000;

        if (drawx < HIGHWAY_START || drawx >= HIGHWAY_START + HIGHWAY_WIDTH) begin
            red = 4'b0011;  // Dark Grey 
            green = 4'b0011;
            blue = 4'b0011;
        end

        // lane separators
        else if (drawx == GREEN_LANE_START || drawx == RED_LANE_START || drawx == YELLOW_LANE_START ||
                 drawx == BLUE_LANE_START || drawx == ORANGE_LANE_START) begin
            red = 4'b1111;
            green = 4'b1111;
            blue = 4'b1111;
        end

        // play notes
        else if ((drawy == TICK_21_TOP_Y || drawy == TICK_21_BOTTOM_Y) &&
                 drawx >= HIGHWAY_START && drawx < HIGHWAY_START + HIGHWAY_WIDTH) begin
            red = 4'b1111;
            green = 4'b1111;
            blue = 4'b1111;
        end

        else begin
            int mirrored_drawy = SCREEN_HEIGHT - 1 - drawy;
            int tick_index = (mirrored_drawy / NOTE_HEIGHT);
            if (tick_index < 24) begin
                logic [4:0] note_bits = tick_notes[tick_index];
                if (note_bits[4] && drawx >= GREEN_LANE_START + 4 && drawx < GREEN_LANE_START + 4 + NOTE_WIDTH) begin
                    red = 4'b0011; green = 4'b1111; blue = 4'b0011; // green note
                end 
                else if (note_bits[3] && drawx >= RED_LANE_START + 4 && drawx < RED_LANE_START + 4 + NOTE_WIDTH) begin
                    red = 4'b1111; green = 4'b0011; blue = 4'b0011; // red note
                end 
                else if (note_bits[2] && drawx >= YELLOW_LANE_START + 4 && drawx < YELLOW_LANE_START + 4 + NOTE_WIDTH) begin
                    red = 4'b1111; green = 4'b1111; blue = 4'b0011; // yellow note
                end 
                else if (note_bits[1] && drawx >= BLUE_LANE_START + 4 && drawx < BLUE_LANE_START + 4 + NOTE_WIDTH) begin
                    red = 4'b0011; green = 4'b0011; blue = 4'b1111; // blue note
                end 
                else if (note_bits[0] && drawx >= ORANGE_LANE_START + 4 && drawx < ORANGE_LANE_START + 4 + NOTE_WIDTH) begin
                    red = 4'b1111; green = 4'b1001; blue = 4'b0011; // orange note
                end
            end
        end
    end

endmodule
