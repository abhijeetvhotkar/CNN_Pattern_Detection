`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:49:02 05/15/2017 
// Design Name: 
// Module Name:    Filter 
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
module Filter(
  	input clk,
	input rst,
	input en,
	input [3:0] addr,
	output reg [8:0] out
    );

reg signed [8:0] sobel [0:8];
initial begin
	sobel[0] = 0;
	sobel[1] = -1;
	sobel[2] = 0;
	sobel[3] = -1;
	sobel[4] = 4;
	sobel[5] = -1;
	sobel[6] = 0;
	sobel[7] = -1;
	sobel[8] = 0;
end
	
always@(posedge clk) begin
		if(rst) begin
			out <= 0;
		end
		if(en) begin
			out <= sobel[addr];
		end
	end

endmodule
