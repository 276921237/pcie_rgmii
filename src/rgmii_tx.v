`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: �Ͼ��������ӿƼ����޹�˾
// Engineer:����Ԫ
// WEB:www.milinker.com
// BBS:www.osrc.cn
// Create Date:    07:28:50 07/31/2015 
// Design Name: 	 RGMII_PHY_TEST
// Module Name:    rgmii_tx
// Project Name: 	 RGMII_PHY_TEST
// Target Devices: Target Devices: XC6SLX45T -2 FTG484 Mis603
// Tool versions:  ISE14.7
// Description: 	 GMII����תRGMII PHY	
// Revision: 		 V1.0
// Additional Comments: 
//1) _i ����PIN ������  
//2) _o ����PIN �����
//3) _n����͵�ƽ��Ч
//4) _dg �����ڲ������ź�
//5) _r�����ӳټĴ�
//6) _s����״̬��
//////////////////////////////////////////////////////////////////////////////////
//mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
module rgmii_tx(
//input GMII
input rgmii_txclk,
input rgmii_txclk_tmp,
input rgmii_txclk_n,
input [7:0]gmii_txd,
input gmii_txdv,
//output RGMII
output rgmii_txclk_o,
output[3:0]rgmii_txd_o,
output rgmii_txdv_o
);

//ʱ��	
/*	ODDR2 #(
    .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
    .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
	) 
	ODDR2_clk (
	.Q(rgmii_txclk_o),   // 1-bit DDR output data
	.C0(rgmii_txclk),   // 1-bit clock input
	.C1(rgmii_txclk_n),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D0(1'b1), // 1-bit data input (associated with C0)
	.D1(1'b0), // 1-bit data input (associated with C1)
	.R(1'b0),   // 1-bit reset input
	.S(1'b0)    // 1-bit set input
	);	*/
	
	assign rgmii_txclk_o = rgmii_txclk_tmp;
   
//����
	ODDR2 #(
    .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
    .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
	) 
	ODDR2_0 (
	.Q(rgmii_txd_o[0]),   // 1-bit DDR output data
	.C0(rgmii_txclk),   // 1-bit clock input
	.C1(rgmii_txclk_n),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D0(gmii_txd[0]), // 1-bit data input (associated with C0)
	.D1(gmii_txd[4]), // 1-bit data input (associated with C1)
	.R(1'b0),   // 1-bit reset input
	.S(1'b0)    // 1-bit set input
	);	 
	 
	ODDR2 #(
    .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
    .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
	) 
	ODDR2_1 (
	.Q(rgmii_txd_o[1]),   // 1-bit DDR output data
	.C0(rgmii_txclk),   // 1-bit clock input
	.C1(rgmii_txclk_n),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D0(gmii_txd[1]), // 1-bit data input (associated with C0)
	.D1(gmii_txd[5]), // 1-bit data input (associated with C1)
	.R(1'b0),   // 1-bit reset input
	.S(1'b0)    // 1-bit set input
	);	 
	
	ODDR2 #(
    .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
    .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
	) 
	ODDR2_2 (
	.Q(rgmii_txd_o[2]),   // 1-bit DDR output data
	.C0(rgmii_txclk),   // 1-bit clock input
	.C1(rgmii_txclk_n),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D0(gmii_txd[2]), // 1-bit data input (associated with C0)
	.D1(gmii_txd[6]), // 1-bit data input (associated with C1)
	.R(1'b0),   // 1-bit reset input
	.S(1'b0)    // 1-bit set input
	);	 
	
	ODDR2 #(
    .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
    .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
	) 
	ODDR2_3 (
	.Q(rgmii_txd_o[3]),   // 1-bit DDR output data
	.C0(rgmii_txclk),   // 1-bit clock input
	.C1(rgmii_txclk_n),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D0(gmii_txd[3]), // 1-bit data input (associated with C0)
	.D1(gmii_txd[7]), // 1-bit data input (associated with C1)
	.R(1'b0),   // 1-bit reset input
	.S(1'b0)    // 1-bit set input
	);	 	 
	
//ʹ��	
	ODDR2 #(
    .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
    .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
    .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
	) 
	ODDR2_4 (
	.Q(rgmii_txdv_o),   // 1-bit DDR output data
	.C0(rgmii_txclk),   // 1-bit clock input
	.C1(rgmii_txclk_n),   // 1-bit clock input
	.CE(1'b1), // 1-bit clock enable input
	.D0(gmii_txdv), // 1-bit data input (associated with C0)
	.D1(gmii_txdv), // 1-bit data input (associated with C1)
	.R(1'b0),   // 1-bit reset input
	.S(1'b0)    // 1-bit set input
	);
	
endmodule
