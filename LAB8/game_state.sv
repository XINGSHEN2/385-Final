module game_state (
    input logic Clk,
    input logic Reset,
    input logic start_game,
    input logic end_game,
    output logic [1:0] state
);

    typedef enum logic [3:0] {
        IDLE = 4'b0000,
        PLAYER1TURN = 4'b0001,
        PLAYER2TURN = 4'b0010,
        SLEEP = 4'b0011,
        PLAYER1DOWN = 4'b0100,
        PLAYER2DOWN = 4'b0101,
        ENDGAME = 4'b0110,
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

    assign state = current_state;

endmodule
