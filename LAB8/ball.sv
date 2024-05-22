//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
                             controllable,
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
               input [7:0]   keycode,
               output logic  is_ball,             // Whether current pixel belongs to ball or background
               output logic  [1:0] revolver_target,     // 0 for player A, 1 for player B, 2 for in the way
               output logic  [9:0] Ball_x_dis, Ball_y_dis
              );

    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd64;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd160;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd480;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd64;        // Ball size

    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_x, Ball_y;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;

    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////

    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;

        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge && controllable == 1)
            begin
                if( Ball_X_Pos >= Ball_X_Max )  // Ball is at the right edge, BOUNCE!
						 begin
							//   Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);  // 2's complement.
                       Ball_X_Motion_in = 0;  // 2's complement.
							  Ball_Y_Motion_in = 0;
						 end
                else if ( Ball_X_Pos <= Ball_X_Min)  // Ball is at the left edge, BOUNCE!
						 begin
							  Ball_X_Motion_in = 0;
							  Ball_Y_Motion_in = 0;
						 end

                case (keycode)
                    // W
                    // 8'h1a :
                    //     begin
                    //         Ball_X_Motion_in = 10'h000;
                    //         Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                    //     end
                    // A
                    8'h04 :
                        begin
                            if(Ball_X_Pos <= Ball_X_Min)
                            begin
                                Ball_X_Motion_in = 10'h000;
                                Ball_Y_Motion_in = 10'h000;
                            end
                            else
                            begin
                                Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                                Ball_Y_Motion_in = 10'h000;
                            end
                        end
                    // // S
                    // 8'h16 :
                    //     begin
                    //         Ball_X_Motion_in = 10'h000;
                    //         Ball_Y_Motion_in = Ball_Y_Step;
                    //     end
                    // D
                    8'h07 :
                        begin
                            if(Ball_X_Pos >= Ball_X_Max)
                            begin
                                Ball_X_Motion_in = 10'h000;
                                Ball_Y_Motion_in = 10'h000;
                            end
                            else
                            begin
                                Ball_X_Motion_in = Ball_X_Step;
                                Ball_Y_Motion_in = 10'h000;
                            end
                        end
                    default:
                        begin
                        end
                endcase

					 
                // Update the ball's position with its motion
                Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
                Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
            end

        /**************************************************************************************
            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
            Hidden Question #2/2:
               Notice that Ball_Y_Pos is updated using Ball_Y_Motion.
              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old?
              What is the difference between writing
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
              Give an answer in your Post-Lab.
        **************************************************************************************/
    end

    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size, revolver_state;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign Size = Ball_Size;
    assign revolver_target = revolver_state;
 
    always_comb begin
        if ( DistX >= ((~Size) + 1) && DistX <= Size && DistY >= ((~Size) + 1) && DistY <= Size)
        // if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) )
		begin
            is_ball = 1'b1;
            Ball_x_dis = DrawX - Ball_X_Pos;
            Ball_y_dis = DrawY - Ball_Y_Pos;
        end
        else
        begin
            is_ball = 1'b0;
            Ball_x_dis = 9'b0;
            Ball_y_dis = 9'b0;
        end

        if (Ball_X_Pos <= 160)
        begin
            revolver_state = 2'b00;
        end
        else if (Ball_X_Pos >=480)
        begin
            revolver_state = 2'b01;
        end
        else
        begin
            revolver_state = 2'b10;
        end
    end

endmodule
