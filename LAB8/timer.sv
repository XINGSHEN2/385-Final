module timer (
    input logic Clk,      // 时钟信号
    input logic Reset,    // 重置信号
    input logic Start,    // 开始计时信号
    output logic Done     // 计时完成信号
);

    // 定义计数器宽度以便存储100,000,000
    logic [26:0] counter; // 27位计数器，能计到134,217,728

    // 计时器状态定义
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        RUNNING = 2'b01,
        DONE = 2'b10,
        WAIT = 2'b11
    } state_t;

    state_t cur_state, next_state;

    // 状态转移逻辑
    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            cur_state <= IDLE;
            counter <= 27'd0;
        end else begin
            cur_state <= next_state;
            if (cur_state == RUNNING) begin
                counter <= counter + 1;
            end else if (cur_state != DONE) begin
                counter <= 27'd0;
            end
        end
    end

    // 下一个状态逻辑和输出逻辑
    always_comb begin
        next_state = cur_state;
        Done = 1'b0;
        case (cur_state)
            IDLE: begin
                if (Start) begin
                    next_state = RUNNING;
                end
            end
            RUNNING: begin
                if (counter == 27'd25000000 - 1) begin
                    next_state = DONE;
                end
            end
            DONE: begin
                Done = 1'b1;
                next_state = WAIT;
            end
            WAIT: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
