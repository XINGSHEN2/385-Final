module revolver_state (
    input logic Clk,
    input logic Reset,
    input logic [2:0] next_state,
    output logic [2:0] state
);

    logic [2:0] current_state;

    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset)
            current_state <= 3'b000;
        else
            current_state <= next_state;
    end

    assign state = current_state;

endmodule
