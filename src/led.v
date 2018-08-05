`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:18:56 12/02/2017 
// Design Name: 
// Module Name:    led 
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
module led(
	input  clk,
	input  rgmii_clk,
	input  rst_n,
	output reg led1,
	output reg led2,
	output 	   led3 
);
	 
	reg [25:0]cnt1;
	always @ (posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			cnt1 <= 0;
			led1 <= 0;
		end
		else if(cnt1 == 12_500_000-1)begin
			cnt1 <= 0;
			led1 <= ~led1;
		end
		else begin
			cnt1 <= cnt1 + 1'b1;
			led1 <= led1;
		end
	end
	
	reg [25:0]cnt2;
	always @ (posedge rgmii_clk or negedge rst_n)begin
		if(!rst_n)begin
			cnt2 <= 0;
			led2 <= 0;
		end
		else if(cnt2 == 12_500_000-1)begin
			cnt2 <= 0;
			led2 <= ~led2;
		end
		else begin
			cnt2 <= cnt2 + 1'b1;
			led2 <= led2;
		end
	end
	
	assign led3 = 1'b0;
	
endmodule
