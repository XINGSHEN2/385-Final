module red_die_rom (
	input logic clock,
	input logic [14:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:25599] /* synthesis ram_init_file = "./red_die/red_die.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
