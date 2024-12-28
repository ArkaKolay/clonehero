module progress_bar_display(
    input  logic [9:0] drawX,
    input  logic [9:0] drawY,
    input  logic       active_nblank,
    input  logic [7:0] progress_percentage,
    input  logic       game_play_active,
    output logic [3:0] red,
    output logic [3:0] green,
    output logic [3:0] blue
);

    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;

    localparam BAR_X_START = SCREEN_WIDTH - 50;
    localparam BAR_X_END = SCREEN_WIDTH - 30;
    localparam BAR_Y_START = 20;
    localparam BAR_Y_END = SCREEN_HEIGHT - 20;

    localparam CHAR_WIDTH = 8;
    localparam CHAR_HEIGHT = 16;

    logic [5:0] char_col;
    logic [3:0] char_row;
    logic [7:0] char_code;
    logic [10:0] font_addr;
    logic [7:0] font_data;
    logic pixel_on;

    logic [7:0] percent_tens, percent_ones;
    assign percent_tens = (progress_percentage / 10) + 8'h30; // Tens digit
    assign percent_ones = (progress_percentage % 10) + 8'h30; // Ones digit

    always_comb begin
        // Default background
        red = 4'h0;
        green = 4'h0;
        blue = 4'h0;

        if (game_play_active && active_nblank) begin
            // Draw the bar outline
            if ((drawX >= BAR_X_START && drawX <= BAR_X_END) &&
                (drawY >= BAR_Y_START && drawY <= BAR_Y_END)) begin
                red = 4'hF;
                green = 4'hF;
                blue = 4'hF; // White outline
            end

            // Fill progress
            if ((drawX >= BAR_X_START + 2 && drawX <= BAR_X_END - 2) &&
                (drawY >= BAR_Y_END - ((BAR_Y_END - BAR_Y_START) * progress_percentage) / 100 &&
                drawY <= BAR_Y_END - 2)) begin
                red = 4'hA;  
                green = 4'h0; 
                blue = 4'hA;  
            end

            // Display percentage text at the top of the bar
            if ((drawY >= BAR_Y_START - CHAR_HEIGHT - 5 && drawY < BAR_Y_START - 5) && 
                (drawX >= BAR_X_START && drawX < BAR_X_START + CHAR_WIDTH * 3)) begin
                char_col = (drawX - BAR_X_START) / CHAR_WIDTH;
                char_row = (drawY - (BAR_Y_START - CHAR_HEIGHT - 5)) % CHAR_HEIGHT; 
                case (char_col)
                    0: char_code = percent_tens; // Tens digit
                    1: char_code = percent_ones; // Ones digit
                    2: char_code = 8'h25;       // '%'
                    default: char_code = 8'h20; // Space
                endcase
                font_addr = {char_code, char_row};
                pixel_on = font_data[7 - ((drawX - BAR_X_START) % CHAR_WIDTH)];
                if (pixel_on) begin
                    red = 4'hF;
                    green = 4'hF;
                    blue = 4'hF; // White text
                end
            end
        end
    end

    // Font ROM instantiation
    font_rom font_rom_inst (
        .addr(font_addr),
        .data(font_data)
    );

endmodule
