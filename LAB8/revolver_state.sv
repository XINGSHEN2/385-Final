module revolver_state (
    input logic Clk,
    input logic Reset,
    input logic start_game,
    input logic end_game,
    output logic [1:0] state
);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        CONTROLLED = 3'b001,
        FIRED = 3'b010,
        STAY = 3'b011,
    } state_t;

    state_t current_state, next_state;

    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (start_game)
                    next_state = RUNNING;
            end
        
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // 输出当前状态
    assign state = current_state;

endmodule
