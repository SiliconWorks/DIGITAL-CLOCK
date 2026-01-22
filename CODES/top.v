`timescale 1ns / 1ps

module top(
    input  clock,            // 100 MHz
    input  reset,            // system reset

    input  alarm_reset_btn,  // alarm clear button

    output alarm_led,        // BLINKING LED

    // OLED interface
    output oled_spi_clk,
    output oled_spi_data,
    output oled_vdd,
    output oled_vbat,
    output oled_reset_n,
    output oled_dc_n,
    output buzzer
);

    // =========================================================
    // 1 SECOND TICK GENERATOR (100 MHz → 1 Hz)
    // =========================================================
    reg [26:0] sec_counter;
    reg one_sec;

    always @(posedge clock) begin
        if (reset) begin
            sec_counter <= 0;
            one_sec <= 0;
        end else if (sec_counter == 100_000_000-1) begin
            sec_counter <= 0;
            one_sec <= 1;
        end else begin
            sec_counter <= sec_counter + 1;
            one_sec <= 0;
        end
    end

    // =========================================================
    // TIME REGISTERS (BCD FORMAT)
    // =========================================================
    reg [3:0] sec_ones, sec_tens;
    reg [3:0] min_ones, min_tens;
    reg [3:0] hr_ones,  hr_tens;

    always @(posedge clock) begin
        if (reset) begin
            sec_ones <= 0; sec_tens <= 0;
            min_ones <= 0; min_tens <= 0;
            hr_ones  <= 0; hr_tens  <= 0;
        end else if (one_sec) begin
            if (sec_ones == 9) begin
                sec_ones <= 0;
                if (sec_tens == 5) begin
                    sec_tens <= 0;
                    if (min_ones == 9) begin
                        min_ones <= 0;
                        if (min_tens == 5) begin
                            min_tens <= 0;
                            if ({hr_tens, hr_ones} == 8'h23) begin
                                hr_tens <= 0;
                                hr_ones <= 0;
                            end else if (hr_ones == 9) begin
                                hr_ones <= 0;
                                hr_tens <= hr_tens + 1;
                            end else begin
                                hr_ones <= hr_ones + 1;
                            end
                        end else min_tens <= min_tens + 1;
                    end else min_ones <= min_ones + 1;
                end else sec_tens <= sec_tens + 1;
            end else sec_ones <= sec_ones + 1;
        end
    end

    // =========================================================
    // ALARM TIME (00:02:00)
    // =========================================================
    localparam [3:0] AL_HR_TENS  = 4'd0;
    localparam [3:0] AL_HR_ONES  = 4'd0;
    localparam [3:0] AL_MIN_TENS = 4'd0;
    localparam [3:0] AL_MIN_ONES = 4'd2;
    localparam [3:0] AL_SEC_TENS = 4'd0;
    localparam [3:0] AL_SEC_ONES = 4'd0;

    // =========================================================
    // ALARM RESET BUTTON SYNC
    // =========================================================
    reg ar_sync1, ar_sync2;
    always @(posedge clock) begin
        ar_sync1 <= alarm_reset_btn;
        ar_sync2 <= ar_sync1;
    end
    wire alarm_reset_sync = ar_sync2;

    // =========================================================
    // ALARM LATCH
    // =========================================================
    reg alarm_on;

    always @(posedge clock) begin
        if (reset || alarm_reset_sync)
            alarm_on <= 1'b0;
        else if (one_sec) begin
            if (hr_tens  == AL_HR_TENS  &&
                hr_ones  == AL_HR_ONES  &&
                min_tens == AL_MIN_TENS &&
                min_ones == AL_MIN_ONES &&
                sec_tens == AL_SEC_TENS &&
                sec_ones == AL_SEC_ONES)
                alarm_on <= 1'b1;
        end
    end

    // =========================================================
    // BLINKING ALARM LED (1 Hz)
    // =========================================================
    reg alarm_led_reg;

    always @(posedge clock) begin
        if (reset || alarm_reset_sync)
            alarm_led_reg <= 1'b0;
        else if (alarm_on && one_sec)
            alarm_led_reg <= ~alarm_led_reg;
        else if (!alarm_on)
            alarm_led_reg <= 1'b0;
    end

    assign alarm_led = alarm_led_reg;
    assign buzzer = alarm_led_reg;

    // =========================================================
    // BCD → ASCII
    // =========================================================
    function [7:0] to_ascii;
        input [3:0] bcd;
        begin
            to_ascii = 8'h30 + bcd;
        end
    endfunction

    // =========================================================
    // DISPLAY STRING "HH:MM:SS"
    // =========================================================
    localparam StringLen = 8;
    reg [7:0] displayStr [0:StringLen-1];

    always @(posedge clock) begin
        if (one_sec) begin
            displayStr[0] <= to_ascii(sec_ones);
            displayStr[1] <= to_ascii(sec_tens);
            displayStr[2] <= 8'h3A;
            displayStr[3] <= to_ascii(min_ones);
            displayStr[4] <= to_ascii(min_tens);
            displayStr[5] <= 8'h3A;
            displayStr[6] <= to_ascii(hr_ones);
            displayStr[7] <= to_ascii(hr_tens);
        end
    end

    // =========================================================
    // OLED SEND FSM (UNCHANGED)
    // =========================================================
    reg [1:0] state;
    reg [7:0] sendData;
    reg sendDataValid;
    integer byteCounter;
    wire sendDone;

    localparam IDLE = 0,
               SEND = 1,
               DONE = 2;

    always @(posedge clock) begin
        if (reset) begin
            state <= IDLE;
            byteCounter <= StringLen;
            sendDataValid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (!sendDone) begin
                        sendData <= displayStr[byteCounter-1];
                        sendDataValid <= 1'b1;
                        state <= SEND;
                    end
                end

                SEND: begin
                    if (sendDone) begin
                        sendDataValid <= 1'b0;
                        byteCounter <= byteCounter - 1;
                        if (byteCounter != 1)
                            state <= IDLE;
                        else begin
                            byteCounter <= StringLen;
                            state <= DONE;
                        end
                    end
                end

                DONE: begin
                    state <= IDLE; // continuous refresh
                end
            endcase
        end
    end

    // =========================================================
    // OLED CONTROLLER
    // =========================================================
    oledControl OC(
        .clock(clock),
        .reset(reset),
        .oled_spi_clk(oled_spi_clk),
        .oled_spi_data(oled_spi_data),
        .oled_vdd(oled_vdd),
        .oled_vbat(oled_vbat),
        .oled_reset_n(oled_reset_n),
        .oled_dc_n(oled_dc_n),
        .sendData(sendData),
        .sendDataValid(sendDataValid),
        .sendDone(sendDone)
    );

endmodule
