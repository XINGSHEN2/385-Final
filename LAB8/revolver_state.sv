module revolver_state (
    input logic Clk,
    input logic Reset,
    input state_t next_state,
    output state_t state
);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        CONTROLLED = 3'b001,
        FIRED = 3'b010,
        STAY = 3'b011,
    } state_t;

    state_t current_state;

    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    assign state = current_state;

endmodule
