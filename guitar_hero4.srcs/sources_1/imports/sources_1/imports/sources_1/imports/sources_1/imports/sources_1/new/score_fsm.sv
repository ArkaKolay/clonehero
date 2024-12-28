module score_fsm(
    input logic clk,               
    input logic reset,             
    input logic [31:0] keycode0,   
    input logic [4:0] tick_notes[23:0], 
    output logic [19:0] score,     
    output logic [3:0] multiplier,
    output logic [9:0] streak      
);

    // Clock divider 
    localparam int DIVIDE_FACTOR = 25000000/10; 
    logic [21:0] clock_counter;            
    logic scoring_enable;                  

    // Internal variables
    logic [4:0] keypress;          
    logic [4:0] current_tick_notes; 
    logic [4:0] matched_notes;    
    integer note_count;           
    localparam int NOTE_VALUE = 50; // Base score value per note

    // Clock divider logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            clock_counter <= 0;
            scoring_enable <= 0;
        end else begin
            if (clock_counter == DIVIDE_FACTOR - 1) begin
                clock_counter <= 0;
                scoring_enable <= 1; // Enable scoring logic
            end else begin
                clock_counter <= clock_counter + 1;
                scoring_enable <= 0; // Disable scoring logic
            end
        end
    end

    always_comb begin
        // Default: no keys pressed
        keypress = 5'b00000;

        // Check each keycode segment for specific key values
        if (keycode0[7:0] == 8'h07 || keycode0[15:8] == 8'h07 || keycode0[23:16] == 8'h07 || keycode0[31:24] == 8'h07)
            keypress[4] = 1; // Green key
        if (keycode0[7:0] == 8'h09 || keycode0[15:8] == 8'h09 || keycode0[23:16] == 8'h09 || keycode0[31:24] == 8'h09)
            keypress[3] = 1; // Red key
        if (keycode0[7:0] == 8'h0D || keycode0[15:8] == 8'h0D || keycode0[23:16] == 8'h0D || keycode0[31:24] == 8'h0D)
            keypress[2] = 1; // Yellow key
        if (keycode0[7:0] == 8'h0E || keycode0[15:8] == 8'h0E || keycode0[23:16] == 8'h0E || keycode0[31:24] == 8'h0E)
            keypress[1] = 1; // Blue key
        if (keycode0[7:0] == 8'h0F || keycode0[15:8] == 8'h0F || keycode0[23:16] == 8'h0F || keycode0[31:24] == 8'h0F)
            keypress[0] = 1; // Orange key
    end

    // Score FSM logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            score <= 20'd0;
            multiplier <= 4'd1;
            streak <= 10'd0;
        end else if (scoring_enable) begin
            // Retrieve notes for the current tick
            current_tick_notes = tick_notes[21]; 

            if (current_tick_notes != 5'b00000) begin
                matched_notes = keypress & current_tick_notes;
                note_count = matched_notes[0] + matched_notes[1] + matched_notes[2] +
                             matched_notes[3] + matched_notes[4];

                if (note_count > 0) begin
                    score <= score + (note_count * NOTE_VALUE * multiplier);

                    streak <= streak + 1;
                    if (streak >= 30)
                        multiplier <= 4;
                    else if (streak >= 20)
                        multiplier <= 3;
                    else if (streak >= 10)
                        multiplier <= 2;
                    else
                        multiplier <= 1;
                end else begin
                    streak <= 0;
                    multiplier <= 1;
                end
            end
        end
    end
endmodule
