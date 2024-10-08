module random (
    input logic Clk,
    input logic Reset,
    output logic [2:0] count
);
//    logic [2:0] counter;
//    assign count = counter;
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
        // if (counter >= 3'd5)
        // begin
        //     counter <= 3d'0;
        // end
        // else
        // begin
        //     counter <= counter + 3'd1;
        // end
    end

endmodule
