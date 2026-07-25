module keypad_fsm (
    input  logic        clk,
    input  logic        rst_n,

    // tick du scanner : 1 kHz → 1 ms
    input  logic        scan_tick,

    // signaux venant du scanner
    input  logic        key_down,
    input  logic [3:0]  key_code,

    // sortie FSM
    output logic        key_action,   // impulsion unique
    output logic [3:0]  key_value     // valeur de la touche validée
);

    typedef enum logic [1:0] {
        IDLE,
        DEBOUNCE,
        HELD,
        RELEASED
    } state_t;

    state_t state, next_state;

    // 10 ms si scan_tick = 1 kHz
    localparam int DEBOUNCE_MAX = 10;

    logic [7:0] debounce_cnt;
    logic [3:0] locked_code;

    // registre d'état
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            debounce_cnt <= 0;
            locked_code  <= 4'd0;
        end else begin
            state <= next_state;

        // compteur anti-rebonds : incrémenté uniquement sur scan_tick
        if (state == DEBOUNCE && scan_tick)
            debounce_cnt <= debounce_cnt + 1;
        else if (state != DEBOUNCE)
            debounce_cnt <= 0;

        // verrouillage de la première touche
        if (state == IDLE && key_down)
            locked_code <= key_code;
        end
    end

    // logique combinatoire
    always_comb begin
        next_state = state;
        key_action = 1'b0;
        key_value  = locked_code;

        case (state)

            IDLE: begin
                if (key_down)
                    next_state = DEBOUNCE;
            end

            DEBOUNCE: begin
                if (!key_down)
                    next_state = IDLE; // rebond
                else if (debounce_cnt >= DEBOUNCE_MAX)
                    next_state = HELD; // touche stable
            end

            HELD: begin
                if (!key_down)
                    next_state = RELEASED;
            end

            RELEASED: begin
                key_action = 1'b1;   // impulsion unique
                next_state = IDLE;
            end

        endcase
    end

endmodule
