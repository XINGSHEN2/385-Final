//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
				 output logic [7:0]  LEDG,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;

	// new middle valiables
	logic [9:0] DrawX,DrawY,Ball_x_dis,Ball_y_dis;
	logic is_ball;
    logic [1:0]revolver_target;
    logic[3:0] next_game_state;
    logic[2:0] next_revolver_state;
    logic[3:0] cur_game_state;
    logic[2:0] cur_revolver_state;

    logic[2:0] random_num, bullet_place;//random number to determine if there is a bullet

    //timer related
    logic timer_start;
    logic timer_done;

    //turn related
    logic controllable; //is revolver controllable
    logic[1:0] last_player;
    logic pos_return; //reset pos of revolver

    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(.Clk, .Reset(Reset_h),.*);
    
    // Which signal should be frame_clk?
    ball ball_instance(.Clk, .Reset(Reset_h), .frame_clk(VGA_VS), .controllable, .DrawX, .DrawY, .keycode, .pos_return, .is_ball, .revolver_target, .Ball_x_dis, .Ball_y_dis);
    random random_instance(.Clk, .Reset(Reset_h), .count(random_num));
    timer timer_instance(.Clk, .Reset(Reset_h), .Start(timer_start), .Done(timer_done));
    game_state game_state_instance (.Clk, .Reset(Reset_h), .next_state(next_game_state), .state(cur_game_state));
    //revolver_state revolver_state_instance (.Clk, .Reset(Reset_h), .next_state(next_revolver_state), .state(cur_revolver_state));

    color_mapper color_instance(.*);
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (keycode[3:0], HEX0);
    HexDriver hex_inst_1 (keycode[7:4], HEX1);
    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
	  always_comb
		 begin
		 // default case
		  LEDG = 8'b0000;
        timer_start = 1'b0;
        if (last_player == 2'b00)
		  begin
			last_player = 2'b00;
		  end
		  else if (last_player == 2'b01)
		  begin
			last_player = 2'b01;
		  end
		  else
		  begin
			last_player = 2'b11;
		  end
        controllable = 1'b0;
        pos_return = 1'b0;
		  next_game_state = cur_game_state;
		  
        
		  case(keycode)
			  8'h04: begin
				  LEDG = 8'b0010;
				 end
			  8'h07: begin
				  LEDG = 8'b0001;
				 end
			  8'h1a: begin
				  LEDG = 8'b1000;
				 end
			  8'h16: begin
				  LEDG = 8'b0100;
				 end
		  endcase

         //Game State logic
        case (cur_game_state)
            4'b0000: begin // IDLE
                if (keycode == 8'h28) begin
                    next_game_state = 4'b0001;
                end else begin
                    next_game_state = 4'b0000;
                end
            end

            4'b0001: begin // Player 1's turn
                controllable = 1'b1;
                if (revolver_target != 2'd10)
                begin
                    if (keycode == 8'h2c) begin // presses space, meaning pull trigger
                        if (random_num == 3'd0) begin
                            // fire!
                            if (revolver_target == 2'd00) begin
                                next_game_state = 4'b0100;
                            end else begin
                                next_game_state = 4'b0101;
                            end
                        end else begin
                            //click. not fired
                            next_game_state = 4'b0011; // wait.
                        end
                    end else begin
                        next_game_state = 4'b0001;
                    end
                end
                else
                begin
                    next_game_state = 4'b0001;
                end
                last_player = 2'b00;
            end

            4'b0010: begin // Player 2's turn
                controllable = 1'b1;
                if (revolver_target != 2'b10)
                begin
                    if (keycode == 8'h2c) begin // presses space, meaning pull trigger
                        if (random_num == 3'd0) begin
                            // fire!
                            if (revolver_target == 2'd00) begin
                                next_game_state = 4'b0100;
                            end else begin
                                next_game_state = 4'b0101;
                            end
                        end else begin
                            // click. not fired
                            next_game_state = 4'b0011; // wait.
                        end
                    end else begin
                        next_game_state = 4'b0010;
                    end
                end
                else
                begin
                    next_game_state = 4'b0010;
                end

                last_player = 2'b01;
            end

            4'b0011: begin //Sleep: wait 2 seconds
                timer_start = 1'b1;
                if (timer_done == 1'b1)
                begin
                    if (last_player == 2'b00 && revolver_target == 2'b01)
                    begin
                        next_game_state = 4'b0010;
                    end
                    else if (last_player == 2'b01 && revolver_target == 2'b00)
                    begin
                        next_game_state = 4'b0001;
                    end
						  else
						  begin
							if (last_player == 2'b00)
							begin
								next_game_state = 4'b0001;
							end
							else
							begin
								next_game_state = 4'b0010;
							end
						  end
                end
                else
                begin
                    next_game_state = 4'b0011;
                end
            end

            4'b0100: begin //player 1 dead
                if (keycode == 8'h28) //press R to restart
                begin
                    next_game_state = 4'b0110;
                end
                else
                begin
                    next_game_state = 4'b0100;
                end
            end

            4'b0101: begin //player 2 dead
                if (keycode == 8'h28) //press R to restart
                begin
                    next_game_state = 4'b0110;
                end
                else
                begin
                    next_game_state = 4'b0101;
                end
            end

            4'b0110: begin //EndGameReset
                pos_return = 1'b1;
                if (last_player == 1'b0)
                begin
                    next_game_state = 4'b0010;
                end
                else
                begin 
                    next_game_state = 4'b0001;
                end
            end
            
            4'b1110: begin //exit
                if (keycode == 8'h52) 
                begin
                    next_game_state = 4'b1111;
                end
                else
                begin
                    next_game_state = 4'b1110;
                end
            end

            4'b1111: begin //menu
                if (keycode == 8'h28) //press R to restart
                begin
                    next_game_state = 4'b0000;
                end
                else if (keycode == 8'h51)
                begin
                    next_game_state = 4'b1110;
                end
                else
                begin
                    next_game_state = 4'b1111;
                end
            end

        endcase

		end

endmodule
