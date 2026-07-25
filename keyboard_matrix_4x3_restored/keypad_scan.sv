module keypad_scan (
    input  logic        clk,
    input  logic        rst_n,
	 input logic			scan_tick,

    // lignes en sortie vers le clavier
    output logic [3:0]  row_out,	// 4 lignes

    // colonnes en entrée depuis le clavier
    input  logic [2:0]  col_in, // 3 colonnes

    // résultat monotouche
    output logic        key_down,     // 1 si une seule touche valide
    output logic [3:0]  key_code     // code 0..15 de la touche
);

	integer r_sel;
	integer c_sel;
	integer r, c;


    // indice de ligne
    logic [1:0] row_idx;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            row_idx <= 0;
        else if (scan_tick)
            row_idx <= row_idx + 1;
    end

    // activation des lignes (une seule à 0)
    always_comb begin
        case (row_idx)
            2'd0: row_out = 4'b1110;
            2'd1: row_out = 4'b1101;
            2'd2: row_out = 4'b1011;
            2'd3: row_out = 4'b0111;
        endcase
    end

    // synchronisation des colonnes sur le signal d'horloge
    logic [2:0] col_state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            col_state <= 3'b111;
        else
            col_state <= col_in;
    end

    // mémorisation de l'état des colonnes pour chaque ligne
    logic [2:0] row_sample [3:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_sample[0] <= 3'b111;
            row_sample[1] <= 3'b111;
            row_sample[2] <= 3'b111;
            row_sample[3] <= 3'b111;
        end else if (scan_tick) begin
            row_sample[row_idx] <= col_state;
        end
    end

    // décision à la fin du cycle (quand row_idx == 3)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_down <= 1'b0;
            key_code <= 4'd0;
        end else if (scan_tick && (row_idx == 2'd3)) begin
            r_sel       = -1;
            c_sel       = -1;

				for (int r = 0; r < 4; r++) begin
					 for (int c = 0; c < 3; c++) begin
						  if (row_sample[r][c] == 1'b0) begin
								// mémoriser la position du premier zéro
								if (r_sel == -1) begin
									r_sel = r;
									c_sel = c;
								end
						  end
					 end
				end

			  if (r_sel != -1) begin
					key_down <= 1'b1;
					key_code <= {r_sel[1:0], c_sel[1:0]};
			  end else begin
					key_down <= 1'b0;
					key_code <= 4'd0;
			  end
        end
    end

endmodule
