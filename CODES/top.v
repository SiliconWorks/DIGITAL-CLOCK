`timescale 1ns / 1ps

module top(
    input  clock,
    input  reset,

    input  alarm_reset_btn,
    input  snooze_btn,

    // TIME SET BUTTONS
    input  set_btn,     // R16
    input  inc_btn,     // T18

    output alarm_led,

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
    // 1 SECOND TICK
    // =========================================================
    reg [26:0] sec_counter;
    reg one_sec;

    always @(posedge clock) begin
        if (reset) begin
            sec_counter <= 0;
            one_sec <= 0;
        end
        else if (sec_counter == 100_000_000-1) begin
            sec_counter <= 0;
            one_sec <= 1;
        end
        else begin
            sec_counter <= sec_counter + 1;
            one_sec <= 0;
        end
    end

    // =========================================================
    // BUTTON SYNCHRONIZERS
    // =========================================================
    reg ar_sync1, ar_sync2;
    always @(posedge clock) begin
        ar_sync1 <= alarm_reset_btn;
        ar_sync2 <= ar_sync1;
    end
    wire alarm_reset_sync = ar_sync2;

    reg sz_sync1, sz_sync2;
    always @(posedge clock) begin
        sz_sync1 <= snooze_btn;
        sz_sync2 <= sz_sync1;
    end
    wire snooze_sync = sz_sync2;

    reg set_sync1, set_sync2;
    always @(posedge clock) begin
        set_sync1 <= set_btn;
        set_sync2 <= set_sync1;
    end
    wire set_sync = set_sync2;

    reg inc_sync1, inc_sync2;
    always @(posedge clock) begin
        inc_sync1 <= inc_btn;
        inc_sync2 <= inc_sync1;
    end
    wire inc_sync = inc_sync2;

    // =========================================================
    // EDGE DETECT (ONE PRESS = ONE PULSE)
    // =========================================================
    reg set_prev, inc_prev;
    wire set_pulse, inc_pulse;

    always @(posedge clock) begin
        set_prev <= set_sync;
        inc_prev <= inc_sync;
    end

    assign set_pulse =  set_sync & ~set_prev;
    assign inc_pulse =  inc_sync & ~inc_prev;

    // =========================================================
    // TIME REGISTERS
    // =========================================================
    reg [3:0] sec_ones, sec_tens;
    reg [3:0] min_ones, min_tens;
    reg [3:0] hr_ones,  hr_tens;

    // =========================================================
    // TIME SET CONTROL
    // =========================================================
    reg set_mode;        // 1 = freeze clock
    reg set_select;     // 0 = hours , 1 = minutes

    // =========================================================
    // MAIN TIME + TIME SET CONTROLLER
    // =========================================================
    always @(posedge clock) begin
        if (reset) begin
            sec_ones <= 0; sec_tens <= 0;
            min_ones <= 0; min_tens <= 0;
            hr_ones  <= 0; hr_tens  <= 0;
            set_mode <= 0;
            set_select <= 0;
        end
        else begin

            // -------- SET BUTTON --------
            if (set_pulse) begin
                if (!set_mode) begin
                    set_mode   <= 1'b1;   // enter set mode
                    set_select <= 1'b0;   // hours first
                end
                else if (set_select == 1'b0) begin
                    set_select <= 1'b1;   // now minutes
                end
                else begin
                    set_mode   <= 1'b0;   // exit set mode
                    set_select <= 1'b0;
                end
            end

            // -------- INC BUTTON (ORDERED INCREMENT) --------
            else if (set_mode && inc_pulse) begin

                // SET HOURS
                if (set_select == 1'b0) begin
                    if ({hr_tens, hr_ones} == 8'h23) begin
                        hr_tens <= 0;
                        hr_ones <= 0;
                    end
                    else if (hr_ones == 9) begin
                        hr_ones <= 0;
                        hr_tens <= hr_tens + 1;
                    end
                    else hr_ones <= hr_ones + 1;
                end

                // SET MINUTES
                else begin
                    if (min_ones == 9) begin
                        min_ones <= 0;
                        if (min_tens == 5)
                            min_tens <= 0;
                        else
                            min_tens <= min_tens + 1;
                    end
                    else min_ones <= min_ones + 1;
                end
            end

            // -------- NORMAL CLOCK RUN --------
            else if (one_sec && !set_mode) begin
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
                                end
                                else if (hr_ones == 9) begin
                                    hr_ones <= 0;
                                    hr_tens <= hr_tens + 1;
                                end
                                else hr_ones <= hr_ones + 1;
                            end
                            else min_tens <= min_tens + 1;
                        end
                        else min_ones <= min_ones + 1;
                    end
                    else sec_tens <= sec_tens + 1;
                end
                else sec_ones <= sec_ones + 1;
            end
        end
    end

    // =========================================================
    // ALARM TIME = 00:01:00
    // =========================================================
    localparam [3:0] AL_HR_TENS  = 4'd0;
    localparam [3:0] AL_HR_ONES  = 4'd5;
    localparam [3:0] AL_MIN_TENS = 4'd1;
    localparam [3:0] AL_MIN_ONES = 4'd5;
    localparam [3:0] AL_SEC_TENS = 4'd0;
    localparam [3:0] AL_SEC_ONES = 4'd0;

    // =========================================================
    // SNOOZE REGISTERS
    // =========================================================
    reg [3:0] snooze_sec_ones, snooze_sec_tens;
    reg [3:0] snooze_min_ones, snooze_min_tens;
    reg [3:0] snooze_hr_ones,  snooze_hr_tens;
    reg snooze_active;

    // =========================================================
    // ALARM + SNOOZE CONTROLLER  (UNCHANGED)
    // =========================================================
    reg alarm_on;

    always @(posedge clock) begin
        if (reset || alarm_reset_sync) begin
            alarm_on <= 1'b0;
            snooze_active <= 1'b0;
        end
        else begin

            // ---------- SNOOZE ----------
            if (alarm_on && snooze_sync) begin
                alarm_on <= 1'b0;
                snooze_active <= 1'b1;

                snooze_sec_ones <= sec_ones;
                snooze_sec_tens <= sec_tens;
                snooze_min_ones <= min_ones;
                snooze_min_tens <= min_tens;
                snooze_hr_ones  <= hr_ones;
                snooze_hr_tens  <= hr_tens;

                if (sec_tens < 3) begin
                    snooze_sec_tens <= sec_tens + 3;
                    snooze_sec_ones <= sec_ones;
                end
                else begin
                    snooze_sec_tens <= sec_tens - 3;
                    snooze_sec_ones <= sec_ones;

                    if (min_ones == 9) begin
                        snooze_min_ones <= 0;
                        if (min_tens == 5) begin
                            snooze_min_tens <= 0;

                            if ({hr_tens, hr_ones} == 8'h23) begin
                                snooze_hr_tens <= 0;
                                snooze_hr_ones <= 0;
                            end
                            else if (hr_ones == 9) begin
                                snooze_hr_ones <= 0;
                                snooze_hr_tens <= hr_tens + 1;
                            end
                            else snooze_hr_ones <= hr_ones + 1;

                        end
                        else snooze_min_tens <= min_tens + 1;
                    end
                    else snooze_min_ones <= min_ones + 1;
                end
            end

            // ---------- NORMAL ALARM ----------
            else if (!snooze_active && one_sec &&
                     hr_tens  == AL_HR_TENS  &&
                     hr_ones  == AL_HR_ONES  &&
                     min_tens == AL_MIN_TENS &&
                     min_ones == AL_MIN_ONES &&
                     sec_tens == AL_SEC_TENS &&
                     sec_ones == AL_SEC_ONES) begin

                alarm_on <= 1'b1;
            end

            // ---------- SNOOZE ALARM ----------
            else if (snooze_active && one_sec &&
                     hr_tens  == snooze_hr_tens  &&
                     hr_ones  == snooze_hr_ones  &&
                     min_tens == snooze_min_tens &&
                     min_ones == snooze_min_ones &&
                     sec_tens == snooze_sec_tens &&
                     sec_ones == snooze_sec_ones) begin

                alarm_on <= 1'b1;
                snooze_active <= 1'b0;
            end
        end
    end

    // =========================================================
    // LED + BUZZER
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
    assign buzzer    = alarm_led_reg;

    // =========================================================
    // OLED DISPLAY STRING "HH:MM:SS"
    // =========================================================
    function [7:0] to_ascii;
        input [3:0] bcd;
        begin
            to_ascii = 8'h30 + bcd;
        end
    endfunction

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
    // OLED SEND FSM
    // =========================================================
    reg [1:0] state;
    reg [7:0] sendData;
    reg sendDataValid;
    integer byteCounter;
    wire sendDone;

    localparam IDLE = 0, SEND = 1, DONE = 2;

    always @(posedge clock) begin
        if (reset) begin
            state <= IDLE;
            byteCounter <= StringLen;
            sendDataValid <= 1'b0;
        end
        else begin
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
                DONE: state <= IDLE;
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
