module start_screen_display(
    input  logic         clk,
    input  logic [9:0]   drawX,
    input  logic [9:0]   drawY,
    input  logic         active_nblank,
    input  logic [7:0]   keycode,         
    output logic [3:0]   red,
    output logic [3:0]   green,
    output logic [3:0]   blue
);

    localparam SCREEN_WIDTH = 640;
    localparam SCREEN_HEIGHT = 480;

    // Parameters for sun
    localparam int SUN_CENTER_X = 320;
    localparam int SUN_CENTER_Y = 150; 
    localparam int SUN_RADIUS = 80;

    // Parameters for text 
    localparam WELCOME_X = 230; 
    localparam WELCOME_Y = 20;  
    localparam PRESS_START_X = 240;
    localparam PRESS_START_Y = 40;  

    // song positions
    localparam SONG1_X = 255;  // X-coordinate for song 1
    localparam SONG1_Y = 255;  // Y-coordinate for song 1
    localparam SONG2_X = 265;  // X-coordinate for song 2
    localparam SONG2_Y = 295;  // Y-coordinate for song 2

    // black box 
    localparam BLACK_BOX_X_START = 240;
    localparam BLACK_BOX_X_END = 400;
    localparam BLACK_BOX_Y_START = 240;
    localparam BLACK_BOX_Y_END = 320;

    localparam CHAR_WIDTH = 8;
    localparam CHAR_HEIGHT = 16;
    localparam int SONG_COUNT = 2;
    integer selected_song = 0;

    logic [5:0] char_col;
    logic [3:0] char_row;
    logic [7:0] char_code;
    logic [10:0] font_addr;
    logic [7:0] font_data;
    logic pixel_on;

    always_ff @(posedge clk) begin
        if (keycode == 8'h52) begin // Up arrow key
            if (selected_song > 0) selected_song <= selected_song - 1;
        end else if (keycode == 8'h51) begin // Down arrow key
            if (selected_song < SONG_COUNT - 1) selected_song <= selected_song + 1;
        end
    end

    always_comb begin
        red = 4'h0;
        green = 4'h0;
        blue = 4'h0;

        if (((drawX - SUN_CENTER_X) * (drawX - SUN_CENTER_X) +
             (drawY - SUN_CENTER_Y) * (drawY - SUN_CENTER_Y)) < SUN_RADIUS * SUN_RADIUS) begin
            if ((drawY - SUN_CENTER_Y) % 10 < 5) begin
                red = 4'h2;
                green = 4'h2;
                blue = 4'hC; // normal blue
            end else begin
                red = 4'h0;
                green = 4'h0;
                blue = 4'h4; // Deep blue
            end
        end 
        // Black background
        else if (drawY <= SUN_CENTER_Y) begin
            red = 4'h0;
            green = 4'h0;
            blue = 4'h0; // Black
        end 
        // Pink grid 
        else if (drawY > SUN_CENTER_Y + SUN_RADIUS + 10) begin
            if (drawY % 40 == 0) begin
                // Horizontal grid lines
                red = 4'hF;
                green = 4'h5;
                blue = 4'hA; 
            end else if (drawX % 40 == 0) begin
                // Vertical grid lines
                red = 4'hF;
                green = 4'h5;
                blue = 4'hA; 
            end else begin
                red = 4'h2;
                green = 4'h0;
                blue = 4'h2; 
            end
        end

        if (drawY == SUN_CENTER_Y + SUN_RADIUS + 10) begin
            red = 4'hF;
            green = 4'h5;
            blue = 4'hA; // Pink line
        end

        // Black box around the songs
        if (drawX >= BLACK_BOX_X_START && drawX <= BLACK_BOX_X_END &&
            drawY >= BLACK_BOX_Y_START && drawY <= BLACK_BOX_Y_END) begin
            red = 4'h0;
            green = 4'h0;
            blue = 4'h0; 
        end

        if (drawX >= WELCOME_X && drawX < WELCOME_X + CHAR_WIDTH * 32 &&
            drawY >= WELCOME_Y && drawY < WELCOME_Y + CHAR_HEIGHT) begin
            char_col = (drawX - WELCOME_X) / CHAR_WIDTH;
            char_row = (drawY - WELCOME_Y) % CHAR_HEIGHT;
            case (char_col)
                0: char_code = 8'h57; // 'W'
                1: char_code = 8'h65; // 'e'
                2: char_code = 8'h6C; // 'l'
                3: char_code = 8'h63; // 'c'
                4: char_code = 8'h6F; // 'o'
                5: char_code = 8'h6D; // 'm'
                6: char_code = 8'h65; // 'e'
                7: char_code = 8'h20; // ' '
                8: char_code = 8'h74; // 't'
                9: char_code = 8'h6F; // 'o'
                10: char_code = 8'h20; // ' '
                11: char_code = 8'h47; // 'G'
                12: char_code = 8'h75; // 'u'
                13: char_code = 8'h69; // 'i'
                14: char_code = 8'h74; // 't'
                15: char_code = 8'h61; // 'a'
                16: char_code = 8'h72; // 'r'
                17: char_code = 8'h20; // ' '
                18: char_code = 8'h48; // 'H'
                19: char_code = 8'h65; // 'e'
                20: char_code = 8'h72; // 'r'
                21: char_code = 8'h6F; // 'o'
                default: char_code = 8'h20; // Space
            endcase
            font_addr = {char_code, char_row};
            pixel_on = font_data[7 - ((drawX - WELCOME_X) % CHAR_WIDTH)];
            if (pixel_on && active_nblank) begin
                red = 4'h0;
                green = 4'hF;
                blue = 4'hF; // cyan text
            end
        end

        // Draw "Press Space to Start"
        if (drawX >= PRESS_START_X && drawX < PRESS_START_X + CHAR_WIDTH * 32 &&
            drawY >= PRESS_START_Y && drawY < PRESS_START_Y + CHAR_HEIGHT) begin
            char_col = (drawX - PRESS_START_X) / CHAR_WIDTH;
            char_row = (drawY - PRESS_START_Y) % CHAR_HEIGHT;
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
                15: char_code = 8'h53; // 'S'
                16: char_code = 8'h74; // 't'
                17: char_code = 8'h61; // 'a'
                18: char_code = 8'h72; // 'r'
                19: char_code = 8'h74; // 't'
                default: char_code = 8'h20; // Space
            endcase
            font_addr = {char_code, char_row};
            pixel_on = font_data[7 - ((drawX - PRESS_START_X) % CHAR_WIDTH)];
            if (pixel_on && active_nblank) begin
                red = 4'h0;
                green = 4'hF;
                blue = 4'hF; // cyan 
            end
        end

        // titles
        for (int i = 0; i < SONG_COUNT; i++) begin
            logic [9:0] song_x, song_y;

            if (i == 0) begin
                song_x = SONG1_X;
                song_y = SONG1_Y;
            end else begin
                song_x = SONG2_X;
                song_y = SONG2_Y;
            end

            if (drawX >= song_x && drawX < song_x + CHAR_WIDTH * 32 &&
                drawY >= song_y && drawY < song_y + CHAR_HEIGHT) begin
                char_col = (drawX - song_x) / CHAR_WIDTH;
                char_row = (drawY - song_y) % CHAR_HEIGHT;
                case (i)
                    0: case (char_col)
                            0: char_code = 8'h4D; // 'M'
                            1: char_code = 8'h69; // 'i'
                            2: char_code = 8'h73; // 's'
                            3: char_code = 8'h73; // 's'
                            4: char_code = 8'h69; // 'i'
                            5: char_code = 8'h73; // 's'
                            6: char_code = 8'h73; // 's'
                            7: char_code = 8'h69; // 'i'
                            8: char_code = 8'h70; // 'p'
                            9: char_code = 8'h70; // 'p'
                            10: char_code = 8'h69; // 'i'
                            11: char_code = 8'h20; // ' '
                            12: char_code = 8'h51; // 'Q'
                            13: char_code = 8'h75; // 'u'
                            14: char_code = 8'h65; // 'e'
                            15: char_code = 8'h65; // 'e'
                            16: char_code = 8'h6E; // 'n'
                        default: char_code = 8'h20; // Space
                        endcase
                    1: case (char_col)
                            0: char_code = 8'h4C; // 'L'
                            1: char_code = 8'h69; // 'i'
                            2: char_code = 8'h6E; // 'n'
                            3: char_code = 8'h75; // 'u'
                            4: char_code = 8'h73; // 's'
                            5: char_code = 8'h20; // ' '
                            6: char_code = 8'h61; // 'a'
                            7: char_code = 8'h6E; // 'n'
                            8: char_code = 8'h64; // 'd'
                            9: char_code = 8'h20; // ' '
                            10: char_code = 8'h4C; // 'L'
                            11: char_code = 8'h75; // 'u'
                            12: char_code = 8'h63; // 'c'
                            13: char_code = 8'h79; // 'y'
                        default: char_code = 8'h20; // Space
                        endcase
                    default: char_code = 8'h20; // Space
                endcase
                font_addr = {char_code, char_row};
                pixel_on = font_data[7 - ((drawX - song_x) % CHAR_WIDTH)];
                if (pixel_on && active_nblank) begin
                        if (i == selected_song) begin
                            red = 4'h0;
                            green = 4'hF;
                            blue = 4'hF; // Cyan for selected
                        end else begin
                            red = 4'hF;
                            green = 4'hF;
                            blue = 4'hF; // White for non-selected
                        end
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