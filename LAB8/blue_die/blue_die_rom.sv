module blue_die_rom (
	input logic clock,
	input logic [14:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:17499] /* synthesis ram_init_file = "./blue_die/blue_die.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
