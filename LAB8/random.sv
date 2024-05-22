module random (
    input logic Clk,
    input logic Reset,
    output logic [2:0] count
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 3'd0;
        end else begin
            if (count == 3'd5) begin
                count <= 3'd0;
            end else begin
                count <= count + 3'd1;
            end
        end
    end

endmodule
