module game_state (
    input logic Clk,
    input logic Reset,
    input logic[3:0] next_state,    output logic[3:0] state
);

    logic[3:0] current_state;

    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset)
            current_state <= 4'b0000;
        else
            current_state <= next_state;
    end
    
    assign state = current_state;

endmodule
