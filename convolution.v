`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:00:26 05/15/2017 
// Design Name: 
// Module Name:    convolution 
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
module convolution(
  	input clk,
	input signed [8:0] in1, //Signed bit number
	input signed [8:0] in2,
	input [8:0] height,
	input [8:0] width,
	input rst,
	input en,
	input clear,
	output reg [20:0] out,
	output reg done
    );
	 
	reg signed [26:0] data;
	reg [9:0] counter;
	
	always@(posedge clk) begin
		if(rst || clear)
			counter <= 0;
		else if(en) begin
			if(counter < (height*width)) begin
				counter <= counter + 1;
			end
			else begin
				//It is set to one because we also read in a value at the same time we reset counter
				counter <= 1;
			end
		end
	end
	
	always@(posedge clk) begin
		if(rst || clear) begin
			data <= 0;
			done <= 0;
		end
		else if(en) begin
			if(counter < (height*width)) begin
				data <= data + in1*in2;
				done <= 0;
			end
			else begin
				if(data > 1048575)
					out <= 1048575;
				else if (data < -1048576) 
					out <= -1048576;
				else
					out <= data; 
				data <= in1*in2;
				done <= 1; 
			end
		end
	end


endmodule
