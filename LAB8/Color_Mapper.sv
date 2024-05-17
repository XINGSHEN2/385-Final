//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              is_ball,            // Whether current pixel belongs to ball 
                        input               Clk,
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY, Ball_x_dis, Ball_y_dis,      // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    logic [3:0] Red_cat, Green_cat, Blue_cat;
    logic [3:0] Red_Right, Green_Right, Blue_Right;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

    // change color to the destnation pixel
    buckshot_example cat_instance (.vga_clk(Clk), .DrawX(DrawX), .DrawY(DrawY), .blank(1'b1), .red(Red_cat), .blue(Blue_cat), .green(Green_cat));
    Right_example Right_instance (.vga_clk(Clk), .DrawX(Ball_x_dis + 10), .DrawY(Ball_y_dis + 10), .blank(1'b1), .red(Red_Right), .blue(Blue_Right), .green(Green_Right));


    // Assign color based on is_ball signal
    always_comb
    begin
        if (is_ball == 1'b1) 
        begin
            // Right
            if (Red_Right == 0 && Green_Right == 0 && Blue_Right == 0)
            begin
                Red = {Red_cat, 4'b0000};
                Green = {Green_cat, 4'b0000};
                Blue = {Blue_cat, 4'b0000};
            end
            else
            begin
                Red = {Red_Right, 4'b0000};
                Green = {Green_Right, 4'b0000};
                Blue = {Blue_Right, 4'b0000};
            end
        end
        else 
        begin
            // Background with nice color gradient
            Red = {Red_cat, 4'b0000};
            Green = {Green_cat, 4'b0000};
            Blue = {Blue_cat, 4'b0000};
        end
    end 
    
endmodule
