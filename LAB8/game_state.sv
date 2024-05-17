module game_state (
    input logic Clk,
    input logic Reset,
    input state_t next_state,    output state_t state
);

    typedef enum logic [3:0] {
        IDLE = 4'b0000,
        PLAYER1TURN = 4'b0001,
        PLAYER2TURN = 4'b0010,
        SLEEP = 4'b0011,
        PLAYER1DOWN = 4'b0100,
        PLAYER2DOWN = 4'b0101,
        ENDGAME = 4'b0110,
        MENU = 4'b1111
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
