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
                       input        [3:0] cur_game_state,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    logic [3:0] Red_Right, Green_Right, Blue_Right;
    // logic [3:0] Red_buckshot, Green_buckshot, Blue_buckshot;
    logic [3:0] Red_background_empty, Green_background_empty, Blue_background_empty;
    logic [3:0] Red_blue, Green_blue, Blue_blue;
    logic [3:0] Red_red, Green_red, Blue_red;
    logic [3:0] Red_red_sit, Green_red_sit, Blue_red_sit;
    logic [3:0] Red_red_die, Green_red_die, Blue_red_die;
    logic [3:0] Red_blue_sit, Green_blue_sit, Blue_blue_sit;
    logic [3:0] Red_blue_die, Green_blue_die, Blue_blue_die;

    
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

    // change color to the destnation pixel
    // buckshot_example buckshot_instance (.vga_clk(Clk), .DrawX(DrawX), .DrawY(DrawY), .blank(1'b1), .red(Red_buckshot), .blue(Blue_buckshot), .green(Green_buckshot));
    Pistol_Scene_example Right_instance (.vga_clk(Clk), .DrawX(Ball_x_dis + 64), .DrawY(Ball_y_dis + 64), .blank(1'b1), .red(Red_Right), .blue(Blue_Right), .green(Green_Right));
    background_empty_example background_empty_instance (.vga_clk(Clk), .DrawX(DrawX), .DrawY(DrawY), .blank(1'b1), .red(Red_background_empty), .blue(Blue_background_empty), .green(Green_background_empty));
    blue_sit_example blue_sit_instance (.vga_clk(Clk), .DrawX(DrawX - 440), .DrawY(DrawY - 130), .blank(1'b1), .red(Red_blue_sit), .blue(Blue_blue_sit), .green(Green_blue_sit));
    blue_die_example blue_die_instance (.vga_clk(Clk), .DrawX(DrawX - 440), .DrawY(DrawY - 130), .blank(1'b1), .red(Red_blue_die), .blue(Blue_blue_die), .green(Green_blue_die));
    red_sit_example red_sit_instance (.vga_clk(Clk), .DrawX(DrawX), .DrawY(DrawY - 80), .blank(1'b1), .red(Red_red_sit), .blue(Blue_red_sit), .green(Green_red_sit));
    red_die_example red_die_instance (.vga_clk(Clk), .DrawX(DrawX), .DrawY(DrawY - 80), .blank(1'b1), .red(Red_red_die), .blue(Blue_red_die), .green(Green_red_die));
    always_comb
    begin
        case(cur_game_state)
        4'b0100 : // player 1 down
        begin
        Red_red = Red_red_die;
        Green_red = Green_red_die;
        Blue_red = Blue_red_die;
        Red_blue = Red_blue_sit;
        Green_blue = Green_blue_sit;
        Blue_blue = Blue_blue_sit;
        end
        4'b0101 : // player 2 down
        begin
        Red_red = Red_red_sit;
        Green_red = Green_red_sit;
        Blue_red = Blue_red_sit;
        Red_blue = Red_blue_die;
        Green_blue = Green_blue_die;
        Blue_blue = Blue_blue_die;
        end
        default :
        begin
        Red_red = Red_red_sit;
        Green_red = Green_red_sit;
        Blue_red = Blue_red_sit;
        Red_blue = Red_blue_sit;
        Green_blue = Green_blue_sit;
        Blue_blue = Blue_blue_sit;
        end
        endcase
    end


    always_comb
    begin
        Red = {Red_background_empty, 4'b0000};
        Green = {Green_background_empty, 4'b0000};
        Blue = {Blue_background_empty, 4'b0000};
        case(cur_game_state)
            // 4'b1111: // MENU, just show the menu
            //     begin
            //     Red = {Red_buckshot, 4'b0000};
            //     Green = {Green_buckshot, 4'b0000};
            //     Blue = {Blue_buckshot, 4'b0000};
            //     end
            4'b0000: // IDLE no revolver, only two players
                if (DrawY >= 80 && DrawY <= 400 && DrawX <= 320) // Red player
                begin
                    if (Red_red == 0 && Green_red == 0 && Blue_red == 0) // color is black, show the background
                    begin
                        Red = {Red_background_empty, 4'b0000};
                        Green = {Green_background_empty, 4'b0000};
                        Blue = {Blue_background_empty, 4'b0000};
                    end
                    else    // color is not black, show the red player
                    begin
                        Red = {Red_red, 4'b0000};
                        Green = {Green_red, 4'b0000};
                        Blue = {Blue_red, 4'b0000};
                    end
                end
                else if (DrawX >= 440 && DrawY >= 130) // Blue player
                begin
                    if (Red_blue == 0 && Green_blue == 0 && Blue_blue == 0) // color is black, show the background
                    begin
                        Red = {Red_background_empty, 4'b0000};
                        Green = {Green_background_empty, 4'b0000};
                        Blue = {Blue_background_empty, 4'b0000};
                    end
                    else    // color is not black, show the blue player
                    begin
                        Red = {Red_blue, 4'b0000};
                        Green = {Green_blue, 4'b0000};
                        Blue = {Blue_blue, 4'b0000};
                    end
                end
            default : // if there is a revolver on the top
                if (is_ball) // the pixel is the revolver
                begin
                    if (Red_Right == 0 && Green_Right == 0 && Blue_Right == 0) // black, draw the background
                    begin
                        Red = {Red_background_empty, 4'b0000};
                        Green = {Green_background_empty, 4'b0000};
                        Blue = {Blue_background_empty, 4'b0000};
                    end
                    else        // draw the revolver
                    begin
                        Red = {Red_Right, 4'b0000};
                        Green = {Green_Right, 4'b0000};
                        Blue = {Blue_Right, 4'b0000};
                    end
                end
                else        // not the revolver
                begin
                    if (DrawY >= 80 && DrawY <= 400 && DrawX <= 320) // Red player
                    begin
                        if (Red_red == 0 && Green_red == 0 && Blue_red == 0) // color is black, show the background
                        begin
                            Red = {Red_background_empty, 4'b0000};
                            Green = {Green_background_empty, 4'b0000};
                            Blue = {Blue_background_empty, 4'b0000};
                        end
                        else    // color is not black, show the red player
                        begin
                            Red = {Red_red, 4'b0000};
                            Green = {Green_red, 4'b0000};
                            Blue = {Blue_red, 4'b0000};
                        end
                    end
                    else if (DrawX >= 440 && DrawY >= 130) // Blue player
                    begin
                        if (Red_blue == 0 && Green_blue == 0 && Blue_blue == 0) // color is black, show the background
                        begin
                            Red = {Red_background_empty, 4'b0000};
                            Green = {Green_background_empty, 4'b0000};
                            Blue = {Blue_background_empty, 4'b0000};
                        end
                        else    // color is not black, show the blue player
                        begin
                            Red = {Red_blue, 4'b0000};
                            Green = {Green_blue, 4'b0000};
                            Blue = {Blue_blue, 4'b0000};
                        end
                    end
                end
        endcase

    end
    
endmodule
