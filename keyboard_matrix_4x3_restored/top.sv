module top (
    input  logic        CLOCK_50,
    input  logic [2:0]  COL_IN,
    input  logic        KEY,          // reset actif bas

    output logic        KEY_DOWN,
    output logic [3:0]  KEY_CODE,
    output logic [3:0]  ROW_OUT
);

    // --- signaux internes ---
    logic        scan_tick;
    logic        key_down_raw;
    logic [3:0]  key_code_raw;

    // --- générateur de tick (1 kHz) ---
    scan_tick_gen #(
        .CLOCK (50_000_000),
        .DIV   (1_000)
    ) tick_gen_inst (
        .clk       (CLOCK_50),
        .rst_n     (KEY),
        .scan_tick (scan_tick)
    );

    // --- scanner de clavier ---
    keypad_scan scan_inst (
        .clk       (CLOCK_50),
        .rst_n     (KEY),
        .scan_tick (scan_tick),
        .col_in    (COL_IN),
        .key_down  (key_down_raw),
        .key_code  (key_code_raw),
        .row_out   (ROW_OUT)
    );

    // --- FSM anti-rebonds + validation ---
    keypad_fsm fsm_inst (
        .clk        (CLOCK_50),
        .rst_n      (KEY),
        .scan_tick  (scan_tick),
        .key_down   (key_down_raw),
        .key_code   (key_code_raw),
        .key_action (KEY_DOWN),
        .key_value  (KEY_CODE)
    );

endmodule
