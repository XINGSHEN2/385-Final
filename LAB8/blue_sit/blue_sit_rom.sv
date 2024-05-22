module blue_sit_rom (
	input logic clock,
	input logic [16:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:69999] /* synthesis ram_init_file = "./blue_sit/blue_sit.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
