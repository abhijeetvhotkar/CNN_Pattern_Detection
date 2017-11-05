`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:11:45 05/15/2017 
// Design Name: 
// Module Name:    vgaProject 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vgaProject(
  		 input clk,								// System clk
	input rst,
	input start,
	output reg [11:0] vga,					// display on VGA
	output VS,								// Vertical sync obtained from vgaPulse Vertical
	output HS,								// Horizontal sync obtained from vgaPulse Horizontal
	output done,
	output [9:0] debug_addr,
	output vFree,
	output hFree);

	assign debug_addr = addr_wr[12:4];
	// Addresses
	wire [10:0] x,y; 
	wire [12:0] coordinate;
	assign coordinate = (y-199)*62 + (x-289);
		
	vgaPulse Horizontal(.clk(pixelClk),
						  .stage1(22'd96),					// See reference manual for values
						  .stage2(22'd144),
						  .stage3(22'd784), //784
						  .endStage(22'd800), //800
						  .syncPulse(HS),
						  .free(hFree),			// Can display on screen
						  .position(x)
						  );				// Instantiate module vgaPulse


	vgaPulse Vertical(.clk(HS),	
						.stage1(22'd6),			// See reference manual for values
						.stage2(22'd35), //35
						.stage3(22'd515),//515
						.endStage(22'd525), //525
						.syncPulse(VS),
						.free(vFree),			// Can display on screen
						.position(y)
						);				// Instantiate module vgaPulse
	
	clockDiv pixel(.clk(clk),
					.div(32'd4),			// We need 20Mhz but system clock runs at 100Mhz
					.out(pixelClk)			// clock at 20Mhz
					);			// Instantiate module clockDiv

	// State Machine
	parameter [3:0] idle = 0, conv = 1, calc_p1 = 2, calc_p2 = 3, read = 4;
	reg [3:0] current_state, next_state;
	
	// Control Signals
	wire done_conv;
	reg done_cmp;
	reg en_rd, en_cmp;
	
	assign done = done_cmp;
	// Addresses
	reg [12:0] addr_rd, addr_wr;
	
	// Pool Signals
	wire [19:0] out_pl, max_pl;
	
	// Output
	reg [11:0] vga_pool [0:5083];
	/*
	pool_test pool (
  .clka(clk), // input clka
  .ena(en_rd), // input ena
  .wea(1'b0), // input [0 : 0] wea
  .addra(addr_rd), // input [12 : 0] addra
  .dina(20'b0), // input [19 : 0] dina
  .douta(out_pl) // output [19 : 0] douta
	);
	*/
	Top_convolution Conv (
    .clk(clk), 
    .rst(rst), 
    .start(start), 
    .en(en_rd), 
    .addr(addr_rd), 
    .out(out_pl), 
    .max_pl(max_pl), 
    .done(done_conv)
    );
	
	// Address Control
	 always@(posedge clk) begin
		if (rst) begin
			addr_rd <= 0;
			addr_wr <= 0;
			done_cmp <= 0;
		end
		else if (en_rd) begin
			if(addr_rd < 5083) begin
				addr_rd <= addr_rd + 1;
				addr_wr <= addr_rd;
			end
			else begin
				addr_wr <= addr_rd;
				addr_rd <= 0;
				done_cmp <= 1;
			end
		end
	 end
	 
	 // Threshold comparison
	 wire [19:0] threshold;
	 assign threshold = (max_pl >> 1) + (max_pl >> 3);
	 
	 always@(posedge clk) begin
		if (en_cmp) begin
			if (out_pl > threshold)
				vga_pool[addr_wr] = 12'b000000000000;
			else
				vga_pool[addr_wr] = 12'b111111111111;	
		end
	 end
		
	always@(posedge clk) begin
		if(rst) begin
			current_state <= idle;
		end
		else begin
			current_state <= next_state;
		end
	end	
	
	always@(posedge clk) begin
		if(rst) begin
			en_rd <= 0;
			en_cmp <= 0;
			next_state <= idle;
		end
		case(current_state)
			idle: begin
				if(start) 
					next_state <= conv;
				else
					next_state <= idle;
			end
			conv: begin
				if(done_conv)
					next_state <= calc_p1;
				else
					next_state <= conv;
			end
			calc_p1: begin
				en_rd <= 1;
				next_state <= calc_p2;
			end
			calc_p2: begin
				en_cmp <= 1;
				if(done_cmp) begin
					next_state <= read;
					en_rd <= 0;
				end
				else
					next_state <= calc_p2;
			end
			read: begin
				en_cmp <= 0;
				next_state <= read;
			end
		endcase
	end
	
	always @(posedge clk) begin
		//If statement sets vga to equal 0, or print black, when x or y is not within specified area
		if ((x<351)&&(x>=289)&&(y<281)&&(y>=199)&&(done_cmp))
			vga <= vga_pool[coordinate];
		else
			vga <= 0; 
		
	end


endmodule

