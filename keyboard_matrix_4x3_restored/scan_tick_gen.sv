module scan_tick_gen	// module générateur de ticks
	#(
		parameter int CLOCK = 50_000_000,	// fréquence d'entrée 50 MHz
		parameter int DIV = 1_000
	)
	(
		input logic clk,
		input logic rst_n,
		output logic scan_tick
	);

    localparam int CNT_MAX = CLOCK / DIV;

    logic [$clog2(CNT_MAX)-1:0] cnt;

    always_ff @(posedge clk or negedge rst_n) begin // reset asynchrone
        if (!rst_n) begin	// reset
            cnt     <= 0;
            scan_tick <= 1'b0;
        end else begin
            if (cnt == CNT_MAX-1) begin
                cnt     <= 0;
                scan_tick <= 1'b1;   // tick
            end else begin
                cnt <= cnt + 1;
					 scan_tick <= 1'b0;
            end
        end
    end
endmodule