module bullet_counter (
    input logic Clk,
    input logic Reset,
    input logic run,
    input logic [2:0] count
    output logic [2:0] bullet_place;
);

    always_ff @(posedge Reset) 
    begin
        bullet_place <= count;
    end

endmodule