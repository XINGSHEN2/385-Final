module Pistol_Scene_rom (
	input logic clock,
	input logic [13:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:16383] /* synthesis ram_init_file = "./Pistol_Scene/Pistol_Scene.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
