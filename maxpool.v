`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:51:07 05/15/2017 
// Design Name: 
// Module Name:    maxpool 
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
module maxpool(
   	input signed [20:0] in,
	input clk,
	input rst,
	input en,
	input [3:0] factor,
	output reg done,
	output reg [20:0] out,
	output [20:0] max
    );
	 
	reg signed [20:0] cur_max;
	reg signed [20:0] abs_max;
	reg [7:0] counter;
	
	wire [7:0] size;
	wire [4:0] addr;
	wire [20:0] tempout;
	assign addr = counter;
	assign size = factor*factor;
	assign tempout = cur_max;
	assign max = abs_max;
	
	always@(posedge clk) begin
		if(rst) begin
			cur_max <= 21'b100000000000000000000;
			abs_max <= 0;
			counter <= 0;
			done <= 0;
		end
		// Resets done even if en is not on
		done <= 0;
		if(en) begin
			if(counter < size) begin
				counter <= counter + 1;
				if(in > cur_max) begin
					cur_max <= in;
				end
			end
			else begin
				done <= 1;
				counter <= 1;
				out <= cur_max;
				cur_max <= in;
			end
			if(in > abs_max) begin
				abs_max <= in;
			end
		end
	end
			

		
endmodule
