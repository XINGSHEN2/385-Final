module cat_rom (
	input logic clock,
	input logic [16:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:76799] /* synthesis ram_init_file = "./cat/cat.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
