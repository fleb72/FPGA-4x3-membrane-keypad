`timescale 1ns/1ps

module testbench;

    // --- signaux du DUT ---
    logic        CLOCK_50;
    logic [2:0]  COL_IN;
    logic [0:0]  KEY;          // reset actif bas, largeur conforme au DUT
    logic        KEY_DOWN;
    logic [3:0]  KEY_CODE;
    logic [3:0]  ROW_OUT;

    // --- instanciation du design ---
    top dut (
        .CLOCK_50 (CLOCK_50),
        .COL_IN   (COL_IN),
        .KEY      (KEY),
        .KEY_DOWN (KEY_DOWN),
        .KEY_CODE (KEY_CODE),
        .ROW_OUT  (ROW_OUT)
    );

    // --- génération horloge 50 MHz ---
    initial CLOCK_50 = 0;
    always #500 CLOCK_50 = ~CLOCK_50;   // 20 ns → 50 MHz

    // --- séquence de reset ---
    initial begin
        KEY    = 0;          // reset actif
        COL_IN = 3'b111;     // aucune touche
        #10000;
        KEY    = 1;          // fin reset
    end

    // --- simulation d'un appui sur une touche ---
    // Exemple : touche "8" → row=2, col=1 → COL_IN = 3'b101 quand row=2 active
    initial begin
        // attendre fin reset
        #20000;

        // appui pendant 5 ms
        repeat (100) begin
            @(posedge CLOCK_50);

            // ligne 2 active ? (ROW_OUT = 4'b1011)
            if (ROW_OUT == 4'b1011)
                COL_IN <= 3'b101;   // col1 = 0 → touche "8"
            else
                COL_IN <= 3'b111;   // aucune touche
        end

        // relâchement
        COL_IN <= 3'b111;

        // fin simulation
        #30_000;
        $stop;
    end

    // --- affichage console ---
    always_ff @(posedge CLOCK_50) begin
        if (KEY_DOWN)
            $display("[%0t] Touche détectée : KEY_CODE = %0d", $time, KEY_CODE);
    end

endmodule
