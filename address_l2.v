`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:59:27 05/15/2017 
// Design Name: 
// Module Name:    address_l2 
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
module address_l2(
	input clk,
	input rst,
	input en,
	input [8:0] ht_sm,
	input [8:0] ht_lg,
	input [8:0] wt_sm,
	input [8:0] wt_lg,
	input [9:0] count1,
	input [8:0] factor,
	output [17:0] address_lg,
	output reg conv_done
    );
	
	wire [8:0] addrx, addry;
	reg [8:0] ADDRX, ADDRY;
	reg [8:0] OFFSET_X1, OFFSET_Y1, OFFSET_X2, OFFSET_Y2;
	wire [9:0] limit1;
	wire [9:0] limit2;
	assign limit1 = ht_sm*wt_sm-1;
	assign limit2 = factor*factor-1;
	assign addrx = ADDRX + OFFSET_X1 + OFFSET_X2;
	assign addry = ADDRY + OFFSET_Y1 + OFFSET_Y2;
	assign address_lg = addrx + addry*wt_lg;
	
	reg [9:0] count2;
	
	always @(posedge clk) begin
		if (rst) begin
			count2 <= 0;
		end
		else if (en) begin
			if(count1 == limit1) begin
				if(count2 < limit2) begin
					count2 <= count2 + 1;
				end
				else 
					count2 <= 0;
			end
		end
	end
	
	/*
	always @(posedge clk) begin
		if (rst) begin
			count1 <= 0;
			count2 <= 0;
		end
		else if (en) begin
			if(count1 <(ht_sm*wt_sm-1)) begin
				count1 <= count1 + 1;
			end
			else begin
				count1 <= 0;
				if(count2 <factor*factor-1) begin
					count2 <= count2 + 1;
				end
				else 
					count2 <= 0;
			end
		end
	end
	*/
	// Control the larger array address
	always@(posedge clk) begin
		if(rst) begin
			ADDRX <= 0;
			ADDRY <= 0;
			OFFSET_X1 <= 0;
			OFFSET_Y1 <= 0;
			OFFSET_X2 <= 0;
			OFFSET_Y2 <= 0;
			conv_done <= 0; 
		end
		else if(en) begin
			// Check if we should increment addrx
			if(ADDRX < (wt_sm-1)) begin
				ADDRX <= ADDRX + 1;
				conv_done <= 0;
			end
			else begin
				// If addrx gets reset, we need to increment y value
				ADDRX <= 0;
				if(ADDRY < (ht_sm-1)) begin
					ADDRY <= ADDRY + 1;
				end
				else begin
					ADDRY <= 0;
				end
			end
			// Control offsets
			if (count1==limit1) begin
				//If addry needs to be reset, then we need to update offset_x
				if(OFFSET_X1 < factor-1) begin
					OFFSET_X1 <= OFFSET_X1 + 1;
				end
				else begin
					OFFSET_X1 <= 0;
					// IF OFFSET_X is resetted, then OFFSET_Y needs to be incremented
					if(OFFSET_Y1 < factor-1) begin
						OFFSET_Y1 <= OFFSET_Y1 + 1;
					end
					else begin
						OFFSET_X1 <= 0;
						OFFSET_Y1 <= 0;
					end
				end
				if (count2==limit2) begin
					if(OFFSET_X2 < (wt_lg-wt_sm-factor*2+1)) begin
						OFFSET_X2 <= OFFSET_X2 + factor;
					end
					else begin
						OFFSET_X2 <= 0;
						if(OFFSET_Y2 < (ht_lg-ht_sm-factor*2+1)) begin
							OFFSET_Y2 <= OFFSET_Y2 + factor;
						end
						else begin
							ADDRX <= 0;
							ADDRY <= 0;
							OFFSET_X1 <= 0;
							OFFSET_Y1 <= 0;
							OFFSET_Y2 <= 0;
							conv_done <= 1;
						end
					end
				end
			end
		end
	end
endmodule

