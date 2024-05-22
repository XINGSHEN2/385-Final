module red_sit_rom (
	input logic clock,
	input logic [16:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:102399] /* synthesis ram_init_file = "./red_sit/red_sit.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
