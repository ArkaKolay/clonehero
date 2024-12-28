module mb_usb_hdmi_top(
    input logic Clk,
    input logic reset_rtl_0,

    // USB signals
    input logic [0:0] gpio_usb_int_tri_i,
    output logic gpio_usb_rst_tri_o,
    input logic usb_spi_miso,
    output logic usb_spi_mosi,
    output logic usb_spi_sclk,
    output logic usb_spi_ss,

    // UART
    input logic uart_rtl_0_rxd,
    output logic uart_rtl_0_txd,

    // HDMI
    output logic hdmi_tmds_clk_n,
    output logic hdmi_tmds_clk_p,
    output logic [2:0] hdmi_tmds_data_n,
    output logic [2:0] hdmi_tmds_data_p,

    // HEX displays
    output logic [7:0] hex_segA,
    output logic [3:0] hex_gridA,
    output logic [7:0] hex_segB,
    output logic [3:0] hex_gridB
);

localparam int TOTAL_TICKS_1 = 1411; //mississippi queen
localparam int TOTAL_TICKS_2 = 1943; //linus and lucy
    // Game states
    typedef enum logic [1:0] {START_SCREEN, GAME_PLAY, GAME_OVER} game_state_t;

    // Internal signals
    game_state_t current_state, next_state;
    logic [31:0] keycode0_gpio, keycode1_gpio;
    logic clk_25MHz, clk_125MHz, locked, spacebar_pressed, spacebar_released, r_pressed;
    logic reset_ah = reset_rtl_0;
    logic [19:0] score;
    logic [3:0] multiplier;
    logic [9:0] streak;
    logic [9:0] drawX, drawY;
    logic vde, hsync, vsync;
    logic [4:0] tick_notes_1[0:23]; //fsm notes 1
    logic [4:0] tick_notes_2[0:23]; //fsm notes 2
    logic [4:0] tick_notes[0:23]; //final tick notes used in game
    logic [3:0] red, green, blue;
    logic game_active;
    logic [$clog2(TOTAL_TICKS_2):0] start_index_1; // from fsm_notes_1
    logic [$clog2(TOTAL_TICKS_2):0] start_index_2; //from fsm_notes_2
    logic [$clog2(TOTAL_TICKS_2):0] start_index; //final selected start_index
    logic [$clog2(TOTAL_TICKS_2):0] current_total_ticks; //selected song's total ticks
    logic game_reset;
    logic song_select; //0 = fsm_notes_1, 1 = fsm_notes_2
    logic [7:0] progress_percentage;
    
    
    // Song selection logic based on arrow keys
always_ff @(posedge Clk or posedge reset_rtl_0) begin
    if (reset_rtl_0) begin
        song_select <= 1'b0; // Default to Mississippi Queen
    end else if (current_state == START_SCREEN) begin
        // Allow song selection only during the START_SCREEN state
        if (keycode0_gpio[7:0] == 8'h52 || keycode1_gpio[7:0] == 8'h52) begin
            // Up arrow (keycode 0x52)
            song_select <= 1'b0;
        end else if (keycode0_gpio[7:0] == 8'h51 || keycode1_gpio[7:0] == 8'h51) begin
            // Down arrow (keycode 0x51)
            song_select <= 1'b1;
        end
    end
end
    
    
    // State machine logic
    always_comb begin
    next_state = current_state;
    game_reset = 0; // Default: no reset

    case (current_state)
        START_SCREEN: begin
            if (spacebar_pressed && spacebar_released) begin
                next_state = GAME_PLAY;
                game_reset = 1; // Reset game logic
            end
        end
        GAME_PLAY: begin
            if (r_pressed) begin
                next_state = START_SCREEN; // Transition to START_SCREEN when "R" is pressed
            end else if (start_index >= (current_total_ticks - 24)) begin
                next_state = GAME_OVER;    // Transition to GAME_OVER when notes finish displaying
            end
        end
        GAME_OVER: begin
            if (spacebar_pressed && spacebar_released) begin
                next_state = START_SCREEN; // back to start screen
            end
        end
    endcase
end


    // Mux for selecting current_total_ticks
    always_comb begin
        if (song_select == 1'b0) begin
            current_total_ticks = TOTAL_TICKS_1; // Total ticks for fsm_notes_1
        end else begin
            current_total_ticks = TOTAL_TICKS_2; // Total ticks for fsm_notes_2
        end
    end


    // Mux for selecting tick_notes
    always_comb begin
        if (song_select == 1'b0) begin
            tick_notes = tick_notes_1; // Use notes from fsm_notes_1
        end else begin
            tick_notes = tick_notes_2; // Use notes from fsm_notes_2
        end
    end
    
 //to select correct start_index   
    always_comb begin
    if (song_select == 1'b0) begin
        start_index = start_index_1; // Use start_index from fsm_notes_1
    end else begin
        start_index = start_index_2; // Use start_index from fsm_notes_2
    end
end


// State Machine: Sequential Logic to Update Current State
always_ff @(posedge clk_25MHz or posedge reset_rtl_0) begin
    if (reset_rtl_0) begin
        current_state <= START_SCREEN; // Reset to START_SCREEN
    end else begin
        current_state <= next_state; // Update current state
    end
end

    // Detect spacebar (keycode 0x2C)
    always_comb begin
        spacebar_pressed = (keycode0_gpio[7:0] == 8'h2C || keycode0_gpio[15:8] == 8'h2C ||
                            keycode0_gpio[23:16] == 8'h2C || keycode0_gpio[31:24] == 8'h2C ||
                            keycode1_gpio[7:0] == 8'h2C || keycode1_gpio[15:8] == 8'h2C ||
                            keycode1_gpio[23:16] == 8'h2C || keycode1_gpio[31:24] == 8'h2C);
    end
    
    always_comb begin
        r_pressed = (keycode0_gpio[7:0] == 8'h15 || keycode0_gpio[15:8] == 8'h15 ||
                            keycode0_gpio[23:16] == 8'h15 || keycode0_gpio[31:24] == 8'h15 ||
                            keycode1_gpio[7:0] == 8'h15 || keycode1_gpio[15:8] == 8'h15 ||
                            keycode1_gpio[23:16] == 8'h15 || keycode1_gpio[31:24] == 8'h15);
    end
    
    
    //spacebar released logic
    always_ff @(posedge clk_25MHz or posedge reset_rtl_0) begin
    if (reset_rtl_0) begin
        spacebar_released <= 1'b1; // Consider the spacebar released on reset
    end else if (!spacebar_pressed) begin
        spacebar_released <= 1'b1; // Set released when the spacebar is not pressed
    end else if (spacebar_pressed) begin
        spacebar_released <= 1'b0; // Reset released when the spacebar is pressed
    end
end

//progress bar percentage 
always_comb begin
    if (current_total_ticks > 0) begin
        progress_percentage = (start_index * 100) / current_total_ticks;
    end else begin
        progress_percentage = 0;
    end
end


    // HEX Drivers for Keycodes
    hex_driver HexA (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[31:28], keycode0_gpio[27:24], keycode0_gpio[23:20], keycode0_gpio[19:16]}),
        .hex_seg(hex_segA),
        .hex_grid(hex_gridA)
    );

    hex_driver HexB (
        .clk(Clk),
        .reset(reset_ah),
        .in({keycode0_gpio[15:12], keycode0_gpio[11:8], keycode0_gpio[7:4], keycode0_gpio[3:0]}),
        .hex_seg(hex_segB),
        .hex_grid(hex_gridB)
    );

    // USB Logic
    mb_usb mb_block_i (
        .clk_100MHz(Clk),
        .gpio_usb_int_tri_i(gpio_usb_int_tri_i),
        .gpio_usb_keycode_0_tri_o(keycode0_gpio),
        .gpio_usb_keycode_1_tri_o(keycode1_gpio),
        .gpio_usb_rst_tri_o(gpio_usb_rst_tri_o),
        .reset_rtl_0(~reset_ah),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .usb_spi_miso(usb_spi_miso),
        .usb_spi_mosi(usb_spi_mosi),
        .usb_spi_sclk(usb_spi_sclk),
        .usb_spi_ss(usb_spi_ss)
    );

    // Clock Wizard
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(Clk)
    );

    // VGA Controller
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );

    // HDMI Converter
    hdmi_tx_0 vga_to_hdmi (
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        .rst(reset_ah),
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        .TMDS_CLK_P(hdmi_tmds_clk_p),
        .TMDS_CLK_N(hdmi_tmds_clk_n),
        .TMDS_DATA_P(hdmi_tmds_data_p),
        .TMDS_DATA_N(hdmi_tmds_data_n)
    );

    // Game Display Logic
    vga_guitar_hero_combined combined_inst (
        .clk(clk_25MHz),
        .reset(reset_ah),
        .drawx(drawX),
        .drawy(drawY),
        .keycode0(keycode0_gpio),
        .keycode1(keycode1_gpio),
        .active_nblank(vde),
        .tick_notes(tick_notes),
        .score(score),
        .multiplier(multiplier),
        .streak(streak),
        .current_state(current_state),
        .progress_percentage(progress_percentage),
        .red(red),
        .green(green),
        .blue(blue)
    );

    // Score FSM
    score_fsm scoring (
        .clk(clk_25MHz),
        .reset(reset_rtl_0 || game_reset),
        .keycode0(keycode0_gpio),
        .tick_notes(tick_notes),
        .score(score),
        .multiplier(multiplier),
        .streak(streak)
    );

    // Notes FSM for mississippi queen
    fsm_notes_1 fsm_1 (
        .clk(clk_25MHz),
        .reset(reset_rtl_0 || game_reset),
        .tick_notes(tick_notes_1),
        .start_index(start_index_1)
    );

    // Notes FSM for linus and lucy
    fsm_notes_2 fsm_2 (
        .clk(clk_25MHz),
        .reset(reset_rtl_0 || game_reset),
        .tick_notes(tick_notes_2),
        .start_index(start_index_2)
    );

    //progress bar module display
    progress_bar_display progress_inst (
        .drawX(drawX),
        .drawY(drawY),
        .active_nblank(vde),
        .progress_percentage(progress_percentage),
        .game_play_active(current_state == GAME_PLAY), // Only active during GAME_PLAY
        .red(progress_red),
        .green(progress_green),
        .blue(progress_blue)
    );

    
endmodule