module vga_text_display (
    input  logic         clk,          
    input  logic [9:0]   drawX,       
    input  logic [8:0]   drawY,       
    input  logic         active_nblank, 
    input  logic [19:0]  score,
    input  logic [3:0]   multiplier,
    input  logic [9:0]   streak,
    output logic [3:0]   red,         
    output logic [3:0]   green,     
    output logic [3:0]   blue          
);
    // Digit Variables
    logic [7:0] score_digit_addr[0:5]; 
    logic [7:0] multiplier_digit_addr[0:1]; 
    logic [7:0] streak_digit_addr[0:3];
    
    digit_address address_inst(
        .score(score),
        .multiplier(multiplier),
        .streak(streak),
        .score_digit_addr(score_digit_addr),
        .multiplier_digit_addr(multiplier_digit_addr),
        .streak_digit_addr(streak_digit_addr)
    );

    parameter SCREEN_WIDTH = 640;
    parameter SCREEN_HEIGHT = 480;

    // font dimensions 
    parameter CHAR_WIDTH = 8; 
    parameter CHAR_HEIGHT = 16; 
    parameter SCALE = 1;
    parameter SCALED_CHAR_WIDTH = CHAR_WIDTH * SCALE;
    parameter SCALED_CHAR_HEIGHT = CHAR_HEIGHT * SCALE;
    parameter TEXT_COLS = 16; 
    parameter TEXT_ROWS = 3;  
    parameter SCREEN_COLS = SCREEN_WIDTH / SCALED_CHAR_WIDTH; 
    parameter SCREEN_ROWS = SCREEN_HEIGHT / SCALED_CHAR_HEIGHT; 

    localparam H_OFFSET = 2; 
    localparam V_OFFSET = 12; 
    // character positions
    logic [6:0] char_row, char_col;
    logic [3:0] pixel_row, pixel_col;

    always_comb begin
        char_row = (drawY / SCALED_CHAR_HEIGHT) - V_OFFSET; 
        char_col = (drawX / SCALED_CHAR_WIDTH) - H_OFFSET;  
        pixel_row = (drawY % SCALED_CHAR_HEIGHT) / SCALE;   
        pixel_col = (drawX % SCALED_CHAR_WIDTH) / SCALE;   
    end

    logic [7:0] text_buffer [0:(TEXT_COLS * TEXT_ROWS - 1)];

    // Fetch character 
    logic [7:0] current_char;

    always_comb begin
        if (char_row >= 0 && char_row < TEXT_ROWS && char_col >= 0 && char_col < TEXT_COLS) begin
            current_char = text_buffer[char_row * TEXT_COLS + char_col]; 
        end else begin
            current_char = 8'h20; 
        end
    end

    logic [10:0] font_addr; 
    logic [7:0] font_data;  

    assign font_addr = {current_char, pixel_row}; 
    // Instantiate the font ROM
    font_rom font_rom_inst (
        .addr(font_addr),
        .data(font_data)
    );

    logic pixel_on;
    assign pixel_on = font_data[7 - pixel_col]; 

    // Assign colors based on pixel state
    always_comb begin
        if (pixel_on && active_nblank) begin
            red = 4'hF;    // White 
            green = 4'hF;
            blue = 4'hF;
        end else begin
            red = 4'h0;    // Black 
            green = 4'h0;
            blue = 4'h0;
        end
    end

    always_ff @(posedge clk) begin
        text_buffer[0] = 8'h53; // 'S'
        text_buffer[1] = 8'h63; // 'c'
        text_buffer[2] = 8'h6F; // 'o'
        text_buffer[3] = 8'h72; // 'r'
        text_buffer[4] = 8'h65; // 'e'
        text_buffer[5] = 8'h3A; // ':'
        text_buffer[6] = score_digit_addr[0]; // Most significant score digit
        text_buffer[7] = score_digit_addr[1]; 
        text_buffer[8] = score_digit_addr[2];
        text_buffer[9] = score_digit_addr[3];
        text_buffer[10] = score_digit_addr[4];
        text_buffer[11] = score_digit_addr[5];

        // mult
        text_buffer[16] = 8'h4D; // 'M'
        text_buffer[17] = 8'h75; // 'u'
        text_buffer[18] = 8'h6C; // 'l'
        text_buffer[19] = 8'h74; // 't'
        text_buffer[20] = 8'h3A; // ':'
        text_buffer[21] = multiplier_digit_addr[0]; // Most significant multiplier digit
        text_buffer[22] = multiplier_digit_addr[1]; 
        text_buffer[23] = 8'h20; 

        // streak
        text_buffer[32] = 8'h53; // 'S'
        text_buffer[33] = 8'h74; // 't'
        text_buffer[34] = 8'h72; // 'r'
        text_buffer[35] = 8'h65; // 'e'
        text_buffer[36] = 8'h61; // 'a'
        text_buffer[37] = 8'h6B; // 'k'
        text_buffer[38] = 8'h3A; // ':'
        text_buffer[39] = streak_digit_addr[0]; // Most significant streak digit
        text_buffer[40] = streak_digit_addr[1];
        text_buffer[41] = streak_digit_addr[2];
        text_buffer[42] = streak_digit_addr[3];
    end

endmodule
