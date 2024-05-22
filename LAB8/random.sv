module random (
    input logic Clk,
    input logic Reset,
    output logic [2:0] count
);

    always_ff @(posedge Clk or posedge Reset) begin
        if (Reset) begin
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
