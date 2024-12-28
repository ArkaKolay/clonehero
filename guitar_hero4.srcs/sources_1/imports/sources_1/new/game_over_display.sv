module game_over_display(
    input  logic         clk,
    input  logic [9:0]   drawX,
    input  logic [9:0]   drawY,
    input  logic         active_nblank,
    input  logic [19:0]  score,           
    output logic [3:0]   red,
    output logic [3:0]   green,
    output logic [3:0]   blue
);

    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;

    // Parameters for text positions
    localparam GAME_OVER_X = 245;
    localparam GAME_OVER_Y = 110;
    localparam SCORE_X = 190;
    localparam SCORE_Y = 160;
    localparam MENU_TEXT_X = 50;
    localparam MENU_TEXT_Y = 380;
    localparam CHAR_WIDTH = 16;
    localparam CHAR_HEIGHT = 32;
    
    localparam RECT_X_START = 160;
    localparam RECT_X_END = 480;
    localparam RECT_Y_START = 80;
    localparam RECT_Y_END = 240;


    // Font ROM signals
    logic [5:0] char_col;
    logic [3:0] char_row;
    logic [7:0] char_code;
    logic [10:0] font_addr;
    logic [7:0] font_data;
    logic pixel_on;

    // Draw logic
    always_comb begin
        // Default background color
        red = 4'h4;  // Purplish background
        green = 4'h0;
        blue = 4'h4;

        // Blue grid lines spanning the entire screen
        if (drawY % 40 == 0 || drawX % 40 == 0) begin
            red = 4'h0;
            green = 4'h0;
            blue = 4'hF;
        end

        // Black rectangle around the text
        if (drawX >= RECT_X_START && drawX <= RECT_X_END &&
            drawY >= RECT_Y_START && drawY <= RECT_Y_END) begin
            red = 4'h0;
            green = 4'h0;
            blue = 4'h0;
        end

        // Draw "Game Over" text
        if (drawX >= GAME_OVER_X && drawX < GAME_OVER_X + CHAR_WIDTH * 9 &&
            drawY >= GAME_OVER_Y && drawY < GAME_OVER_Y + CHAR_HEIGHT) begin
            char_col = (drawX - GAME_OVER_X) / CHAR_WIDTH;
            char_row = (drawY - GAME_OVER_Y) / 2 % CHAR_HEIGHT; // Adjusted for scaling
            case (char_col)
                0: char_code = 8'h47; // 'G'
                1: char_code = 8'h61; // 'a'
                2: char_code = 8'h6D; // 'm'
                3: char_code = 8'h65; // 'e'
                4: char_code = 8'h20; // ' '
                5: char_code = 8'h4F; // 'O'
                6: char_code = 8'h76; // 'v'
                7: char_code = 8'h65; // 'e'
                8: char_code = 8'h72; // 'r'
                default: char_code = 8'h20; // Space
            endcase
            font_addr = {char_code, char_row};
            pixel_on = font_data[7 - ((drawX - GAME_OVER_X) / 2 % CHAR_WIDTH)];
            if (pixel_on && active_nblank) begin
                red = 4'hF;
                green = 4'hF;
                blue = 4'hF; // White text
            end
        end

        // Draw "Your Score:"
        if (drawX >= SCORE_X && drawX < SCORE_X + CHAR_WIDTH * 11 &&
            drawY >= SCORE_Y && drawY < SCORE_Y + CHAR_HEIGHT) begin
            char_col = (drawX - SCORE_X) / CHAR_WIDTH;
            char_row = (drawY - SCORE_Y) / 2 % CHAR_HEIGHT; // Adjusted for scaling
            case (char_col)
                0: char_code = 8'h59; // 'Y'
                1: char_code = 8'h6F; // 'o'
                2: char_code = 8'h75; // 'u'
                3: char_code = 8'h72; // 'r'
                4: char_code = 8'h20; // ' '
                5: char_code = 8'h53; // 'S'
                6: char_code = 8'h63; // 'c'
                7: char_code = 8'h6F; // 'o'
                8: char_code = 8'h72; // 'r'
                9: char_code = 8'h65; // 'e'
                10: char_code = 8'h3A; // ':'
                default: char_code = 8'h20; // Space
            endcase
            font_addr = {char_code, char_row};
            pixel_on = font_data[7 - ((drawX - SCORE_X) / 2 % CHAR_WIDTH)];
            if (pixel_on && active_nblank) begin
                red = 4'hF;
                green = 4'hF;
                blue = 4'hF; // White text
            end
        end

        // Draw score value
        for (int i = 0; i < 5; i++) begin
            if (drawX >= SCORE_X + CHAR_WIDTH * (12 + i) && drawX < SCORE_X + CHAR_WIDTH * (13 + i) &&
                drawY >= SCORE_Y && drawY < SCORE_Y + CHAR_HEIGHT) begin
                char_col = (drawX - (SCORE_X + CHAR_WIDTH * (12 + i))) / CHAR_WIDTH;
                char_row = (drawY - SCORE_Y) / 2 % CHAR_HEIGHT; // Adjusted for scaling
                char_code = (score / (10 ** (4 - i))) % 10 + 8'h30; // Extract digit from score
                font_addr = {char_code, char_row};
                pixel_on = font_data[7 - ((drawX - (SCORE_X + CHAR_WIDTH * (12 + i))) / 2 % CHAR_WIDTH)];
                if (pixel_on && active_nblank) begin
                    red = 4'hF;
                    green = 4'hF;
                    blue = 4'hF; // White text
                end
            end
        end

        // Draw "Press Space to Return to Main Menu" text
        if (drawX >= MENU_TEXT_X && drawX < MENU_TEXT_X + CHAR_WIDTH * 34 &&
            drawY >= MENU_TEXT_Y && drawY < MENU_TEXT_Y + CHAR_HEIGHT) begin
            char_col = (drawX - MENU_TEXT_X) / CHAR_WIDTH;
            char_row = (drawY - MENU_TEXT_Y) / 2 % CHAR_HEIGHT; // Adjusted for scaling
            case (char_col)
                0: char_code = 8'h50; // 'P'
                1: char_code = 8'h72; // 'r'
                2: char_code = 8'h65; // 'e'
                3: char_code = 8'h73; // 's'
                4: char_code = 8'h73; // 's'
                5: char_code = 8'h20; // ' '
                6: char_code = 8'h53; // 'S'
                7: char_code = 8'h70; // 'p'
                8: char_code = 8'h61; // 'a'
                9: char_code = 8'h63; // 'c'
                10: char_code = 8'h65; // 'e'
                11: char_code = 8'h20; // ' '
                12: char_code = 8'h74; // 't'
                13: char_code = 8'h6F; // 'o'
                14: char_code = 8'h20; // ' '
                15: char_code = 8'h52; // 'R'
                16: char_code = 8'h65; // 'e'
                17: char_code = 8'h74; // 't'
                18: char_code = 8'h75; // 'u'
                19: char_code = 8'h72; // 'r'
                20: char_code = 8'h6E; // 'n'
                21: char_code = 8'h20; // ' '
                22: char_code = 8'h74; // 't'
                23: char_code = 8'h6F; // 'o'
                24: char_code = 8'h20; // ' '
                25: char_code = 8'h4D; // 'M'
                26: char_code = 8'h61; // 'a'
                27: char_code = 8'h69; // 'i'
                28: char_code = 8'h6E; // 'n'
                29: char_code = 8'h20; // ' '
                30: char_code = 8'h4D; // 'M'
                31: char_code = 8'h65; // 'e'
                32: char_code = 8'h6E; // 'n'
                33: char_code = 8'h75; // 'u'
                default: char_code = 8'h20; // Space
            endcase
            font_addr = {char_code, char_row};
            pixel_on = font_data[7 - ((drawX - MENU_TEXT_X) / 2 % CHAR_WIDTH)];
            if (pixel_on && active_nblank) begin
                red = 4'hF;
                green = 4'hF;
                blue = 4'hF; // White text
            end
        end
    end

    // Font ROM instantiation
    font_rom font_rom_inst (
        .addr(font_addr),
        .data(font_data)
    );

endmodule
