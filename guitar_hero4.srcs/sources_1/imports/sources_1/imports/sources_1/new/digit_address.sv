module digit_address (
    input  logic [19:0] score,         
    input  logic [3:0] multiplier,     
    input  logic [9:0] streak,        
    output logic [7:0] score_digit_addr[0:5], 
    output logic [7:0] multiplier_digit_addr[0:1], 
    output logic [7:0] streak_digit_addr[0:3] 
);
    logic [3:0] score_digits[0:5];
    logic [3:0] multiplier_digits[0:1];
    logic [3:0] streak_digits[0:3];

    logic [7:0] font_rom_addr[0:9];

    initial begin
        font_rom_addr[0] = 8'h30; // Address for digit 0
        font_rom_addr[1] = 8'h31; // Address for digit 1
        font_rom_addr[2] = 8'h32; // Address for digit 2
        font_rom_addr[3] = 8'h33; // Address for digit 3
        font_rom_addr[4] = 8'h34; // Address for digit 4
        font_rom_addr[5] = 8'h35; // Address for digit 5
        font_rom_addr[6] = 8'h36; // Address for digit 6
        font_rom_addr[7] = 8'h37; // Address for digit 7
        font_rom_addr[8] = 8'h38; // Address for digit 8
        font_rom_addr[9] = 8'h39; // Address for digit 9
    end

    // Score digit extraction
    always_comb begin
        score_digits[0] = (score / 100000);                     // Hundred-thousands place
        score_digits[1] = (score % 100000) / 10000;             // Ten-thousands place
        score_digits[2] = (score % 10000) / 1000;               // Thousands place
        score_digits[3] = (score % 1000) / 100;                 // Hundreds place
        score_digits[4] = (score % 100) / 10;                   // Tens place
        score_digits[5] = (score % 10);                         // Ones place

        foreach (score_digit_addr[i]) begin
            unique case (score_digits[i])
                4'd0: begin
                    score_digit_addr[i] = font_rom_addr[0];
                end
                4'd1: begin
                    score_digit_addr[i] = font_rom_addr[1];
                end
                4'd2: begin
                    score_digit_addr[i] = font_rom_addr[2];
                end
                4'd3: begin
                    score_digit_addr[i] = font_rom_addr[3];
                end
                4'd4: begin
                    score_digit_addr[i] = font_rom_addr[4];
                end
                4'd5: begin
                    score_digit_addr[i] = font_rom_addr[5];
                end
                4'd6: begin
                    score_digit_addr[i] = font_rom_addr[6];
                end
                4'd7: begin
                    score_digit_addr[i] = font_rom_addr[7];
                end
                4'd8: begin
                    score_digit_addr[i] = font_rom_addr[8];
                end
                4'd9: begin
                    score_digit_addr[i] = font_rom_addr[9];
                end
                default: score_digit_addr[i] = 8'hFF; 
            endcase
        end
    end

    // Multiplier digit extraction
    always_comb begin
        multiplier_digits[0] = (multiplier / 10);               // Tens place
        multiplier_digits[1] = (multiplier % 10);               // Ones place

        foreach (multiplier_digit_addr[i]) begin
            unique case (multiplier_digits[i])
                4'd0: multiplier_digit_addr[i] = font_rom_addr[0];
                4'd1: multiplier_digit_addr[i] = font_rom_addr[1];
                4'd2: multiplier_digit_addr[i] = font_rom_addr[2];
                4'd3: multiplier_digit_addr[i] = font_rom_addr[3];
                4'd4: multiplier_digit_addr[i] = font_rom_addr[4];
                4'd5: multiplier_digit_addr[i] = font_rom_addr[5];
                4'd6: multiplier_digit_addr[i] = font_rom_addr[6];
                4'd7: multiplier_digit_addr[i] = font_rom_addr[7];
                4'd8: multiplier_digit_addr[i] = font_rom_addr[8];
                4'd9: multiplier_digit_addr[i] = font_rom_addr[9];
                default: multiplier_digit_addr[i] = 8'hFF; 
            endcase
        end
    end

    // Streak digit extraction
    always_comb begin
        streak_digits[0] = (streak / 1000);             // Thousands place
        streak_digits[1] = (streak % 1000) / 100;       // Hundreds place
        streak_digits[2] = (streak % 100) / 10;         // Tens place
        streak_digits[3] = (streak % 10);               // Ones place

        foreach (streak_digit_addr[i]) begin
            unique case (streak_digits[i])
                4'd0: streak_digit_addr[i] = font_rom_addr[0];
                4'd1: streak_digit_addr[i] = font_rom_addr[1];
                4'd2: streak_digit_addr[i] = font_rom_addr[2];
                4'd3: streak_digit_addr[i] = font_rom_addr[3];
                4'd4: streak_digit_addr[i] = font_rom_addr[4];
                4'd5: streak_digit_addr[i] = font_rom_addr[5];
                4'd6: streak_digit_addr[i] = font_rom_addr[6];
                4'd7: streak_digit_addr[i] = font_rom_addr[7];
                4'd8: streak_digit_addr[i] = font_rom_addr[8];
                4'd9: streak_digit_addr[i] = font_rom_addr[9];
                default: streak_digit_addr[i] = 8'hFF; 
            endcase
        end
    end

endmodule
