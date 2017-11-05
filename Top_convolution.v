`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:47:59 05/15/2017 
// Design Name: 
// Module Name:    Top_convolution 
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
module Top_convolution(
 input clk,
	input rst,
	input start,
	input en,
	input [12:0] addr,
	output [20:0] out,
	output [20:0] max_pl,
	output reg done
    );
	
	assign out = out_pl;
	
	// Variables used to control array size
	reg [8:0] HT_SM, WT_SM;
	wire [8:0] ht_sm, wt_sm; 
	reg [8:0] HT_LG, WT_LG;
	wire [8:0] ht_lg, wt_lg;
	
	assign ht_sm = HT_SM;
	assign wt_sm = WT_SM;
	assign ht_lg = HT_LG;
	assign wt_lg = WT_LG;
	
	// Parameters for size of array
	parameter [8:0] height_fil = 30, width_fil = 27, side_lap = 3, height_filpro = 28, width_filpro = 25,
	height_image = 440, width_image = 340, height_impro = 438, width_impro = 338, factor = 5;
	
	// Parameters and variables for state
	parameter [3:0] idle = 0, setup = 1, conv_p1 = 2, conv_p2 = 3, delay_p1 = 4, delay_p2 = 5, maxpl = 6, read = 15;
	
	reg [3:0] current_state, next_state;
	
	// Control signals
	reg en_conv;
	wire en_maxpl;
	reg en_cnt_l1, en_cnt_l2, en_cnt_sm;
	reg clear;
	wire conv_done_l1, conv_done_l2;
	// 0 = Idle, 1 = Filter, 2 = Image, 3 = IMPRO, FILPRO
	reg [1:0] conv_sel;
	assign en_maxpl = (conv_sel==3)? done_conv:0;
	
	// Convolution Input and Output
	wire signed [8:0] in1, in2;
	wire [20:0] out_conv;
	wire done_conv;
	assign in1 = (conv_sel==2'b00)? 0: 
					(conv_sel==2'b01)? out_f: 
					(conv_sel==2'b10)? out_i:out_ip[10:2];
	assign in2 = (conv_sel==2'b00)? 0: 
					(conv_sel==2'b11)? out_fp[10:2]: out_lap;
		
	// Maxpool Input and Output
	wire signed [20:0] in_maxpl, max_pl, out_maxpl;
	assign in_maxpl = out_conv;
	
	//Address Data for Convolution Blocks and MaxPool
	reg [9:0] ADDR_SM;
	//wire [9:0] addr_sm;
	wire [17:0] addr_lg_l1;
	wire [17:0] addr_lg_l2;
	reg [17:0] ADDR_OUT;
	//assign addr_sm = ADDR_SM;
	
///////////////////////////////////////////////////////////////////////////////////////////////////		
// Memory Data
///////////////////////////////////////////////////////////////////////////////////////////////////	
	// Enable Signals
	wire en_f, en_i, en_fp, en_ip, en_lap, en_pl;
	// Write Signals
	reg wr_ip, wr_fp, wr_pl;
	// Addresses
	wire [9:0] addr_f;
	wire [17:0] addr_i;
	wire [9:0] addr_fp;
	wire [17:0] addr_ip;
	wire [12:0] addr_pl;
	wire [3:0] addr_lap;

	//Input signals
	wire [10:0] in_fp, in_ip;
	wire [10:0] out_fp, out_ip;
	wire signed [20:0] in_pl;
	assign in_fp = out_conv[10:0];
	assign in_ip = out_conv[10:0];
	assign in_pl = out_maxpl;
	//Output signals
	wire signed [8:0] out_lap;
	wire signed [7:0] out_i, out_f;	
	wire signed [20:0] out_pl;
	
	// Assignments
	assign en_lap = (conv_sel==3||conv_sel==0)? 0:1;
	assign en_f = (conv_sel==1)? 1:0;
	assign en_i = (conv_sel==2)? 1:0;
	assign en_fp = (conv_sel==0)? 0:
						(conv_sel==1)? done_conv:
						(conv_sel==3)? 1:0;
	assign en_ip = (conv_sel==0)? 0:
						(conv_sel==2)? done_conv:
						(conv_sel==3)? 1:0;
	assign en_pl = (done)? en:done_maxpl;
	assign addr_f = (conv_sel==1)? addr_lg_l1:0;
	assign addr_i = (conv_sel==2)? addr_lg_l1:0;
	assign addr_lap = (conv_sel==0||conv_sel==3)? 0:ADDR_SM;
	assign addr_ip = (conv_sel==0)? 0: 
						  (conv_sel==3)? addr_lg_l2:ADDR_OUT; 
	assign addr_fp = (conv_sel==0)? 0: 
						  (conv_sel==1)? ADDR_OUT[9:0]:ADDR_SM;
						  //(conv_sel==3)? ADDR_SM:ADDR_OUT[9:0];
	assign addr_pl = (done)? addr:ADDR_OUT[12:0];
	
	Filter Sobel (
    .clk(clk), 
    .rst(rst), 
    .en(en_lap), 
    .addr(addr_lap),  
    .out(out_lap)
    );
	 
	Pattern P (
  .clka(clk), // input clka
  .ena(en_f), // input ena
  .wea(1'b0), // input [0 : 0] wea
  .addra(addr_f), // input [9 : 0] addra
  .dina(7'b0), // input [7 : 0] dina
  .douta(out_f) // output [7 : 0] douta
);
	
	Image_doc I (
  .clka(clk), // input clka
  .ena(en_i), // input ena
  .wea(1'b0), // input [0 : 0] wea
  .addra(addr_i), // input [17 : 0] addra
  .dina(7'b0), // input [7 : 0] dina
  .douta(out_i) // output [7 : 0] douta
);

//	Image_doc2 I (
//  .clka(clk), // input clka
//  .ena(en_i), // input ena
//  .wea(1'b0), // input [0 : 0] wea
//  .addra(addr_i), // input [17 : 0] addra
//  .dina(7'b0), // input [7 : 0] dina
//  .douta(out_i) // output [7 : 0] douta
//);

//	Image_doc3 I (
//  .clka(clk), // input clka
//  .ena(en_i), // input ena
//  .wea(1'b0), // input [0 : 0] wea
//  .addra(addr_i), // input [17 : 0] addra
//  .dina(7'b0), // input [7 : 0] dina
//  .douta(out_i) // output [7 : 0] douta
//);


	Pattern_conv PC (
  .clka(clk), // input clka
  .ena(en_fp), // input ena
  .wea(wr_fp), // input [0 : 0] wea
  .addra(addr_fp), // input [9 : 0] addra
  .dina(in_fp), // input [10 : 0] dina
  .douta(out_fp) // output [10 : 0] douta
);
	Image_conv IC (
  .clka(clk), // input clka
  .ena(en_ip), // input ena
  .wea(wr_ip), // input [0 : 0] wea
  .addra(addr_ip), // input [17 : 0] addra
  .dina(in_ip), // input [10 : 0] dina
  .douta(out_ip) // output [10 : 0] douta
);

	maxpool_IP MPIP (
  .clka(clk), // input clka
  .ena(en_pl), // input ena
  .wea(wr_pl), // input [0 : 0] wea
  .addra(addr_pl), // input [12 : 0] addra
  .dina(in_pl), // input [20 : 0] dina
  .douta(out_pl) // output [20 : 0] douta
);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Address Control
///////////////////////////////////////////////////////////////////////////////////////////////////

	// Address control for output 1
	// Used by conv1 for layer 1
	wire out_trig;
	assign out_trig = (conv_sel==2'b11)? done_maxpl:done_conv;
	
	always@(posedge clk) begin
		if(rst || clear) begin
			ADDR_OUT <= 0;
		end
		else if(out_trig) begin
			ADDR_OUT <= ADDR_OUT + 1;
		end	
	end

	
	// Control larger addressing
	address_l1 addr_l1 (
    .clk(clk), 
    .rst(rst||clear), 
    .en(en_cnt_l1), 
    .ht_sm(ht_sm), 
    .ht_lg(ht_lg), 
    .wt_sm(wt_sm), 
    .wt_lg(wt_lg), 
    .count(ADDR_SM), 
    .address_lg(addr_lg_l1), 
    .conv_done(conv_done_l1)
    );
	
	// Large Address Control for Second Layer
	address_l2 addr_l2 (
    .clk(clk), 
    .rst(rst||clear), 
    .en(en_cnt_l2), 
    .ht_sm(ht_sm), 
    .ht_lg(ht_lg), 
    .wt_sm(wt_sm), 
    .wt_lg(wt_lg), 
	 .count1(ADDR_SM),
    .factor(factor), 
    .address_lg(addr_lg_l2), 
    .conv_done(conv_done_l2)
    );
	
	// Control the smaller array addresses
	always@(posedge clk) begin
		if(rst||clear) begin
			ADDR_SM <= 0;
		end
		else if(en_cnt_l1||en_cnt_l2) begin
			if(ADDR_SM < (ht_sm*wt_sm-1)) begin
				ADDR_SM <= ADDR_SM + 1;
			end
			else begin
				ADDR_SM <= 0;
			end	
		end
	end

///////////////////////////////////////////////////////////////////////////////////////////////////
// Multiplexer, Conv, and Maxpool Blocks
///////////////////////////////////////////////////////////////////////////////////////////////////	
	
	convolution convolution (
	 .clk(clk),
    .in1(in1), 
    .in2(in2), 
    .height(ht_sm), 
    .width(wt_sm), 
    .rst(rst), 
    .en(en_conv), 
	 .clear(clear),
    .out(out_conv), 
    .done(done_conv)
    );
	 
	maxpool maxpool (
    .in(in_maxpl), 
    .clk(clk), 
    .rst(rst), 
    .en(en_maxpl), 
    .factor(factor), 
    .done(done_maxpl), 
    .out(out_maxpl),
	 .max(max_pl)
    );
	

///////////////////////////////////////////////////////////////////////////////////////////////////
// State Logic
///////////////////////////////////////////////////////////////////////////////////////////////////
	
	//Update State
	/*
	always @(posedge clk) begin
		if (rst) begin
			current_state <= idle;
		end
		else begin
			current_state <= next_state;
		end
	end
	*/
	// Next State logic
	always @(posedge clk) begin 
		if (rst) begin
			HT_SM <= 0;
			WT_SM <= 0;
			HT_LG <= 0;
			WT_SM <= 0;
			en_conv <= 0;
			en_cnt_l1 <= 0;
			en_cnt_l2 <= 0;
			wr_ip <= 0;
			wr_fp <= 0;
			wr_pl <= 0;
			clear <= 0;
			conv_sel <= 2'b00;
			done <= 0;
			current_state <= idle;
			//next_state <= idle;
		end
		case(current_state)
			idle: begin
				if(start)
					// Start convolution
					current_state <= setup;
				else
					current_state <= idle;
			end
			setup: begin
				case(conv_sel) 
					0: begin
						HT_SM <= side_lap;
						WT_SM <= side_lap;
						HT_LG <= height_fil;
						WT_LG <= width_fil;
						en_cnt_l1 <= 1;
						wr_fp <= 1;
						conv_sel <= 2'b01;
					end
					1: begin
						HT_SM <= side_lap;
						WT_SM <= side_lap;
						HT_LG <= height_image;
						WT_LG <= width_image;
						en_cnt_l1 <= 1;
						wr_ip <= 1;
						conv_sel <= 2'b10;
					end
					2: begin
						HT_SM <= height_filpro;
						WT_SM <= width_filpro;
						HT_LG <= height_impro;
						WT_LG <= width_impro;
						en_cnt_l2 <= 1;
						wr_pl <= 1;
						conv_sel <= 2'b11;
					end
				endcase
				current_state <= conv_p1;
			end
			conv_p1: begin
				en_conv <= 1;
				if(conv_done_l1) begin
					en_cnt_l1 <= 0;
					current_state <= conv_p2;
				end
				else if(conv_sel != 3)
					current_state <= conv_p1;
				else
					current_state <= maxpl;
			end
			conv_p2: begin
				en_conv <= 0;
				current_state <= delay_p1;
			end
			maxpl: begin
				if(conv_done_l2) begin
					en_cnt_l2 <= 0;
					current_state <= delay_p1;
				end
				else
					current_state <= maxpl;
			end
			delay_p1: begin
				if(conv_sel==3) begin
					if(done_maxpl) begin
						clear <= 1;
						wr_pl <= 0;
						current_state <= delay_p2;
					end
					else 
						current_state <= delay_p1;
				end
				else begin
					clear <= 1;
					wr_fp <= 0;
					wr_ip <= 0;
					current_state <= delay_p2;
				end
			end
			delay_p2: begin
				clear <= 0;
				if (conv_sel != 3) 
					current_state <= setup;
				else begin
					current_state <= read;
					conv_sel <= 2'b00;
				end
			end
			read: begin
				conv_sel <= 2'b00;
				done <= 1;
			end
		endcase
	end
endmodule
