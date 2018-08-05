`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:18:21 12/04/2017 
// Design Name: 
// Module Name:    eth_ts 
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
module M6X(
	input			user_clk				,
	input			user_rst				,
	output          clk_125m				,
	output          rgmii_clk_125m			,

	input			uart_rx					,
	output			uart_tx					,
	input			pps_in					,
	input			tod_in					,

	input			rgmii_rxdv				,//输入有效信号
	input			rgmii_rxclk				,//输入时钟
	input	[3:0]	rgmii_rxd				,//数据输入

	output			rgmii_txdv				,//输出有效信号
	output			rgmii_txclk				,//输出时钟
	output	[3:0]	rgmii_txd				,//数据输出
	
	//NET数据上行方向
	output			ram_net_up_flag0		,
	input			ram_net_up_clr0			,
	output	[10:0]	ram_net_up_len0			,
	input			ram_net_up_rd_clk0		,
	input			ram_net_up_rd_en0		,
	input			ram_net_up_rd_we0		,
	input	[8:0]	ram_net_up_rd_addr0		,
	output	[31:0]	ram_net_up_rd_data0		,
	input			ram_ts_up_rd_clk0		,
	input			ram_ts_up_rd_en0		,
	input			ram_ts_up_rd_we0		,
	input	[1:0]	ram_ts_up_rd_addr0		,
	output	[31:0]	ram_ts_up_rd_data0		,
	
	output			ram_net_up_flag1		,
	input			ram_net_up_clr1			,
	output	[10:0]	ram_net_up_len1			,
	input			ram_net_up_rd_clk1		,
	input			ram_net_up_rd_en1		,
	input			ram_net_up_rd_we1		,
	input	[8:0]	ram_net_up_rd_addr1		,
	output	[31:0]	ram_net_up_rd_data1		,
	input			ram_ts_up_rd_clk1		,
	input			ram_ts_up_rd_en1		,
	input			ram_ts_up_rd_we1		,
	input	[1:0]	ram_ts_up_rd_addr1		,
	output	[31:0]	ram_ts_up_rd_data1		,
	
	output			ram_net_up_flag2		,
	input			ram_net_up_clr2			,
	output	[10:0]	ram_net_up_len2			,
	input			ram_net_up_rd_clk2		,
	input			ram_net_up_rd_en2		,
	input			ram_net_up_rd_we2		,
	input	[8:0]	ram_net_up_rd_addr2		,
	output	[31:0]	ram_net_up_rd_data2		,
	input			ram_ts_up_rd_clk2		,
	input			ram_ts_up_rd_en2		,
	input			ram_ts_up_rd_we2		,
	input	[1:0]	ram_ts_up_rd_addr2		,
	output	[31:0]	ram_ts_up_rd_data2		,
	
	output			ram_net_up_flag3		,
	input			ram_net_up_clr3			,
	output	[10:0]	ram_net_up_len3			,
	input			ram_net_up_rd_clk3		,
	input			ram_net_up_rd_en3		,
	input			ram_net_up_rd_we3		,
	input	[8:0]	ram_net_up_rd_addr3		,
	output	[31:0]	ram_net_up_rd_data3		,
	input			ram_ts_up_rd_clk3		,
	input			ram_ts_up_rd_en3		,
	input			ram_ts_up_rd_we3		,
	input	[1:0]	ram_ts_up_rd_addr3		,
	output	[31:0]	ram_ts_up_rd_data3		,
	
	output			ram_net_up_flag4		,
	input			ram_net_up_clr4			,
	output	[10:0]	ram_net_up_len4			,
	input			ram_net_up_rd_clk4		,
	input			ram_net_up_rd_en4		,
	input			ram_net_up_rd_we4		,
	input	[8:0]	ram_net_up_rd_addr4		,
	output	[31:0]	ram_net_up_rd_data4		,
	input			ram_ts_up_rd_clk4		,
	input			ram_ts_up_rd_en4		,
	input			ram_ts_up_rd_we4		,
	input	[1:0]	ram_ts_up_rd_addr4		,
	output	[31:0]	ram_ts_up_rd_data4		,
	
	output			ram_net_up_flag5		,
	input			ram_net_up_clr5			,
	output	[10:0]	ram_net_up_len5			,
	input			ram_net_up_rd_clk5		,
	input			ram_net_up_rd_en5		,
	input			ram_net_up_rd_we5		,
	input	[8:0]	ram_net_up_rd_addr5		,
	output	[31:0]	ram_net_up_rd_data5		,
	input			ram_ts_up_rd_clk5		,
	input			ram_ts_up_rd_en5		,
	input			ram_ts_up_rd_we5		,
	input	[1:0]	ram_ts_up_rd_addr5		,
	output	[31:0]	ram_ts_up_rd_data5		,
	
	output			ram_net_up_flag6		,
	input			ram_net_up_clr6			,
	output	[10:0]	ram_net_up_len6			,
	input			ram_net_up_rd_clk6		,
	input			ram_net_up_rd_en6		,
	input			ram_net_up_rd_we6		,
	input	[8:0]	ram_net_up_rd_addr6		,
	output	[31:0]	ram_net_up_rd_data6		,
	input			ram_ts_up_rd_clk6		,
	input			ram_ts_up_rd_en6		,
	input			ram_ts_up_rd_we6		,
	input	[1:0]	ram_ts_up_rd_addr6		,
	output	[31:0]	ram_ts_up_rd_data6		,
	
	output			ram_net_up_flag7		,
	input			ram_net_up_clr7			,
	output	[10:0]	ram_net_up_len7			,
	input			ram_net_up_rd_clk7		,
	input			ram_net_up_rd_en7		,
	input			ram_net_up_rd_we7		,
	input	[8:0]	ram_net_up_rd_addr7		,
	output	[31:0]	ram_net_up_rd_data7		,
	input			ram_ts_up_rd_clk7		,
	input			ram_ts_up_rd_en7		,
	input			ram_ts_up_rd_we7		,
	input	[1:0]	ram_ts_up_rd_addr7		,
	output	[31:0]	ram_ts_up_rd_data7		,
	
	//NET数据下行方向
	input			ram_net_down_wr_clk		,
	input			ram_net_down_wr_en		,
	input			ram_net_down_wr_we		,
	input	[8:0]	ram_net_down_wr_addr	,
	input	[31:0]	ram_net_down_wr_data	,
	input			ram_net_down_start		,
	input	[10:0]	ram_net_down_len		,
	output			ram_net_down_completed	,
	
	//TOD串口数据上行方向
	input			ram_tod_up_rd_clk		,
	input			ram_tod_up_rd_en		,
	input			ram_tod_up_rd_we		,
	input	[6:0]	ram_tod_up_rd_addr		,
	output	[31:0]	ram_tod_up_rd_data		,
	output	[8:0]	ram_tod_up_len			,
	output			ram_tod_up_flag			,
	input			ram_tod_up_clr			,

    input           uart_ustod_latch_flag   ,
    output  [31:0]  bar_year_month_day      ,
    output  [31:0]  bar_hour_min_sec        ,
    output  [31:0]  bar_nano_sec            ,
    
	//M6X uart 上行方向
	input			ram_uart_up_rd_clk		,
	input			ram_uart_up_rd_en		,
	input			ram_uart_up_rd_we		,
	input	[10:0]	ram_uart_up_rd_addr		,
	output	[31:0]	ram_uart_up_rd_data		,
	output	[12:0]	ram_uart_up_len			,
	output			ram_uart_up_flag		,
	input			ram_uart_up_clr			,
	
	//M6X uart 下行方向
	input			ram_uart_down_wr_clk	,
	input			ram_uart_down_wr_en		,
	input			ram_uart_down_wr_we		,
	input	[5:0]	ram_uart_down_wr_addr	,
	input	[31:0]	ram_uart_down_wr_data	,
	input			ram_uart_down_start		,
	input	[7:0]	ram_uart_down_len		,
	output			ram_uart_down_completed	
);

	wire rgmii_clk_dcm_90d		;
	wire rgmii_clk_dcm_270d		;
	wire user_clk_dcm			;
	wire user_clk_dcm_180d		;
	wire user_clk_dcm_180dd		;
	(* KEEP="TRUE"*)wire [7:0] gmii_rxd;
	(* KEEP="TRUE"*)wire 	   gmii_rxdv;
	(* KEEP="TRUE"*)wire 		ram_ts_up_wr_en0,ram_ts_up_wr_en1,ram_ts_up_wr_en2,ram_ts_up_wr_en3;
	(* KEEP="TRUE"*)wire 		ram_ts_up_wr_en4,ram_ts_up_wr_en5,ram_ts_up_wr_en6,ram_ts_up_wr_en7;
	(* KEEP="TRUE"*)wire 	    ram_ts_up_wr_we0,ram_ts_up_wr_we1,ram_ts_up_wr_we2,ram_ts_up_wr_we3;
	(* KEEP="TRUE"*)wire 	    ram_ts_up_wr_we4,ram_ts_up_wr_we5,ram_ts_up_wr_we6,ram_ts_up_wr_we7;
	(* KEEP="TRUE"*)wire [3:0]  ram_ts_up_wr_addr0,ram_ts_up_wr_addr1,ram_ts_up_wr_addr2,ram_ts_up_wr_addr3;
	(* KEEP="TRUE"*)wire [3:0]  ram_ts_up_wr_addr4,ram_ts_up_wr_addr5,ram_ts_up_wr_addr6,ram_ts_up_wr_addr7;
	(* KEEP="TRUE"*)wire [7:0]  ram_ts_up_wr_data0,ram_ts_up_wr_data1,ram_ts_up_wr_data2,ram_ts_up_wr_data3;
	(* KEEP="TRUE"*)wire [7:0]  ram_ts_up_wr_data4,ram_ts_up_wr_data5,ram_ts_up_wr_data6,ram_ts_up_wr_data7;
	(* KEEP="TRUE"*)wire 		ram_net_up_wr_en0,ram_net_up_wr_en1,ram_net_up_wr_en2,ram_net_up_wr_en3;
	(* KEEP="TRUE"*)wire 		ram_net_up_wr_en4,ram_net_up_wr_en5,ram_net_up_wr_en6,ram_net_up_wr_en7;
	(* KEEP="TRUE"*)wire 	    ram_net_up_wr_we0,ram_net_up_wr_we1,ram_net_up_wr_we2,ram_net_up_wr_we3;
	(* KEEP="TRUE"*)wire 	    ram_net_up_wr_we4,ram_net_up_wr_we5,ram_net_up_wr_we6,ram_net_up_wr_we7;
	(* KEEP="TRUE"*)wire [10:0] ram_net_up_wr_addr0,ram_net_up_wr_addr1,ram_net_up_wr_addr2,ram_net_up_wr_addr3;
	(* KEEP="TRUE"*)wire [10:0] ram_net_up_wr_addr4,ram_net_up_wr_addr5,ram_net_up_wr_addr6,ram_net_up_wr_addr7;
	(* KEEP="TRUE"*)wire [7:0]  ram_net_up_wr_data0,ram_net_up_wr_data1,ram_net_up_wr_data2,ram_net_up_wr_data3;
	(* KEEP="TRUE"*)wire [7:0]  ram_net_up_wr_data4,ram_net_up_wr_data5,ram_net_up_wr_data6,ram_net_up_wr_data7;

	(* KEEP="TRUE"*)wire [7:0]  gmii_txd;
	(* KEEP="TRUE"*)wire        gmii_txdv;
	wire        ram_net_down_rd_en		;
	wire        ram_net_down_rd_we		;
	wire [10:0] ram_net_down_rd_addr	;
	wire [7:0]  ram_net_down_rd_data	;
	wire [15:0] ts_week	      	 		;
	wire [31:0] ts_week_sec      		;
	wire [31:0] ts_nano_sec      		;
	wire [7:0]  ts_leap_sec      		;
	wire [7:0]  ts_pps_state     		;
	wire [7:0]  ts_timesrc_type  		;
	wire [7:0]  ts_pps_precision 		;
	wire [7:0]  ts_checksum	  	 		;
	wire 		ram_tod_up_wr_en		;
	wire 		ram_tod_up_wr_we		;
	wire [8:0]  ram_tod_up_wr_addr		;
	wire [7:0]  ram_tod_up_wr_data		;
	wire        ram_uart_up_wr_en		;
	wire        ram_uart_up_wr_we		;
	wire [12:0] ram_uart_up_wr_addr		;
	wire [7:0]  ram_uart_up_wr_data		;
	wire        ram_uart_down_rd_en		;
	wire        ram_uart_down_rd_we		;
	wire [7:0]  ram_uart_down_rd_addr 	;
	wire [7:0]  ram_uart_down_rd_data	;

	assign clk_125m = user_clk_dcm;
	assign rgmii_clk_125m = rgmii_clk_dcm_90d;
//////////////////////////////////////////////////////////////////////////////////
// 锁相环
//////////////////////////////////////////////////////////////////////////////////	
	dcm_rgmii u_dcm_rgmii(
		.CLK_IN1			(rgmii_rxclk			),
		.CLK_OUT1			(						),
		.CLK_OUT2			(rgmii_clk_dcm_90d		),
		.CLK_OUT3			(						),
		.CLK_OUT4			(rgmii_clk_dcm_270d		),
		.CLK_OUT5			(						)
	);
	
	dcm u_dcm(
		.CLK_IN1			(user_clk				),
		.CLK_OUT1			(user_clk_dcm			),
		.CLK_OUT2			(						),
		.CLK_OUT3			(user_clk_dcm_180d		),
		.CLK_OUT4			(						),
		.CLK_OUT5			(user_clk_dcm_180dd		)
	);
//////////////////////////////////////////////////////////////////////////////////
// 网络信息解析
//////////////////////////////////////////////////////////////////////////////////
	rgmii_rx u_rgmii_rx(
		.clk_125m			(user_clk_dcm			),
		.rst_n				(user_rst				),
		.rgmii_rxclk		(rgmii_clk_dcm_90d		),
		.rgmii_rxclk_n		(rgmii_clk_dcm_270d		),
		.rgmii_rxd_i		(rgmii_rxd				),
		.rgmii_rxdv_i		(rgmii_rxdv				),
		.gmii_rxd			(gmii_rxd				),
		.gmii_rxdv			(gmii_rxdv				)
	);

/*	//测试
	reg [26:0] cnt;
	reg ram_net_up_clr0;
	reg ram_net_up_clr1;
	reg ram_net_up_clr2;
	reg ram_net_up_clr3;
	reg ram_net_up_clr4;
	reg ram_net_up_clr5;
	reg ram_net_up_clr6;
	reg ram_net_up_clr7;
	always @ (posedge user_clk_dcm or negedge user_rst)begin
		if(!user_rst)begin
			cnt <= 0;
		end
		else if(cnt == 125_000_000-1)begin
			cnt <= 0;
		end
		else begin
			cnt <= cnt + 1'b1;
		end
	end
	always @ (posedge user_clk_dcm or negedge user_rst)begin
		if(!user_rst)begin
			ram_net_up_clr0 <= 0;
			ram_net_up_clr1 <= 0;
			ram_net_up_clr2 <= 0;
			ram_net_up_clr3 <= 0;
			ram_net_up_clr4 <= 0;
			ram_net_up_clr5 <= 0;
			ram_net_up_clr6 <= 0;
			ram_net_up_clr7 <= 0;
		end
		else if(cnt == 0)begin
			ram_net_up_clr0 <= 1;
		end
		else if(cnt == 1)begin
			ram_net_up_clr1 <= 1;
		end
		else if(cnt == 2)begin
			ram_net_up_clr2 <= 1;
		end
		else if(cnt == 3)begin
			ram_net_up_clr3 <= 1;
		end
		else if(cnt == 4)begin
			ram_net_up_clr4 <= 1;
		end
		else if(cnt == 5)begin
			ram_net_up_clr5 <= 1;
		end
		else if(cnt == 6)begin
			ram_net_up_clr6 <= 1;
		end
		else if(cnt == 7)begin
			ram_net_up_clr7 <= 1;
		end
		else begin
			ram_net_up_clr0 <= 0;
			ram_net_up_clr1 <= 0;
			ram_net_up_clr2 <= 0;
			ram_net_up_clr3 <= 0;
			ram_net_up_clr4 <= 0;
			ram_net_up_clr5 <= 0;
			ram_net_up_clr6 <= 0;
			ram_net_up_clr7 <= 0;
		end
	end*/
	
	net_up u_net_up(
		.clk_125m			(user_clk_dcm			),
		.rst_n   			(user_rst				),
		.gmii_rxd			(gmii_rxd				),
		.gmii_rxdv			(gmii_rxdv				),
		.timer_stop			(timer_stop				),
		.ts_week	       	(ts_week	       		),
		.ts_week_sec      	(ts_week_sec      		),
		.ts_nano_sec      	(ts_nano_sec      		),
		.ts_leap_sec      	(ts_leap_sec      		),
		.ts_pps_state     	(ts_pps_state     		),
		.ts_timesrc_type  	(ts_timesrc_type  		),
		.ts_pps_precision 	(ts_pps_precision 		),
		.ts_checksum		(ts_checksum			),
		.ram_ts_up_wr_en0	(ram_ts_up_wr_en0		),
		.ram_ts_up_wr_we0	(ram_ts_up_wr_we0		),
		.ram_ts_up_wr_addr0	(ram_ts_up_wr_addr0		),
		.ram_ts_up_wr_data0	(ram_ts_up_wr_data0		),
		.ram_net_up_wr_en0	(ram_net_up_wr_en0		),
		.ram_net_up_wr_we0	(ram_net_up_wr_we0		),
		.ram_net_up_wr_addr0(ram_net_up_wr_addr0	),
		.ram_net_up_wr_data0(ram_net_up_wr_data0	),
		.ram_net_up_len0	(ram_net_up_len0		),
		.ram_net_up_flag0	(ram_net_up_flag0		),
		.ram_net_up_clr0	(ram_net_up_clr0    	),
		.ram_ts_up_wr_en1	(ram_ts_up_wr_en1		),
		.ram_ts_up_wr_we1	(ram_ts_up_wr_we1		),
		.ram_ts_up_wr_addr1	(ram_ts_up_wr_addr1		),
		.ram_ts_up_wr_data1	(ram_ts_up_wr_data1		),
		.ram_net_up_wr_en1	(ram_net_up_wr_en1		),
		.ram_net_up_wr_we1	(ram_net_up_wr_we1		),
		.ram_net_up_wr_addr1(ram_net_up_wr_addr1	),
		.ram_net_up_wr_data1(ram_net_up_wr_data1	),
		.ram_net_up_len1	(ram_net_up_len1		),
		.ram_net_up_flag1	(ram_net_up_flag1		),
		.ram_net_up_clr1	(ram_net_up_clr1    	),
		.ram_ts_up_wr_en2	(ram_ts_up_wr_en2		),
		.ram_ts_up_wr_we2	(ram_ts_up_wr_we2		),
		.ram_ts_up_wr_addr2	(ram_ts_up_wr_addr2		),
		.ram_ts_up_wr_data2	(ram_ts_up_wr_data2		),
		.ram_net_up_wr_en2	(ram_net_up_wr_en2		),
		.ram_net_up_wr_we2	(ram_net_up_wr_we2		),
		.ram_net_up_wr_addr2(ram_net_up_wr_addr2	),
		.ram_net_up_wr_data2(ram_net_up_wr_data2	),
		.ram_net_up_len2	(ram_net_up_len2		),
		.ram_net_up_flag2	(ram_net_up_flag2		),
		.ram_net_up_clr2	(ram_net_up_clr2    	),
		.ram_ts_up_wr_en3	(ram_ts_up_wr_en3		),
		.ram_ts_up_wr_we3	(ram_ts_up_wr_we3		),
		.ram_ts_up_wr_addr3	(ram_ts_up_wr_addr3		),
		.ram_ts_up_wr_data3	(ram_ts_up_wr_data3		),
		.ram_net_up_wr_en3	(ram_net_up_wr_en3		),
		.ram_net_up_wr_we3	(ram_net_up_wr_we3		),
		.ram_net_up_wr_addr3(ram_net_up_wr_addr3	),
		.ram_net_up_wr_data3(ram_net_up_wr_data3	),
		.ram_net_up_len3	(ram_net_up_len3		),
		.ram_net_up_flag3	(ram_net_up_flag3		),
		.ram_net_up_clr3	(ram_net_up_clr3    	),
		.ram_ts_up_wr_en4	(ram_ts_up_wr_en4		),
		.ram_ts_up_wr_we4	(ram_ts_up_wr_we4		),
		.ram_ts_up_wr_addr4	(ram_ts_up_wr_addr4		),
		.ram_ts_up_wr_data4	(ram_ts_up_wr_data4		),
		.ram_net_up_wr_en4	(ram_net_up_wr_en4		),
		.ram_net_up_wr_we4	(ram_net_up_wr_we4		),
		.ram_net_up_wr_addr4(ram_net_up_wr_addr4	),
		.ram_net_up_wr_data4(ram_net_up_wr_data4	),
		.ram_net_up_len4	(ram_net_up_len4		),
		.ram_net_up_flag4	(ram_net_up_flag4		),
		.ram_net_up_clr4	(ram_net_up_clr4    	),
		.ram_ts_up_wr_en5	(ram_ts_up_wr_en5		),
		.ram_ts_up_wr_we5	(ram_ts_up_wr_we5		),
		.ram_ts_up_wr_addr5	(ram_ts_up_wr_addr5		),
		.ram_ts_up_wr_data5	(ram_ts_up_wr_data5		),
		.ram_net_up_wr_en5	(ram_net_up_wr_en5		),
		.ram_net_up_wr_we5	(ram_net_up_wr_we5		),
		.ram_net_up_wr_addr5(ram_net_up_wr_addr5	),
		.ram_net_up_wr_data5(ram_net_up_wr_data5	),
		.ram_net_up_len5	(ram_net_up_len5		),
		.ram_net_up_flag5	(ram_net_up_flag5		),
		.ram_net_up_clr5	(ram_net_up_clr5    	),
		.ram_ts_up_wr_en6	(ram_ts_up_wr_en6		),
		.ram_ts_up_wr_we6	(ram_ts_up_wr_we6		),
		.ram_ts_up_wr_addr6	(ram_ts_up_wr_addr6		),
		.ram_ts_up_wr_data6	(ram_ts_up_wr_data6		),
		.ram_net_up_wr_en6	(ram_net_up_wr_en6		),
		.ram_net_up_wr_we6	(ram_net_up_wr_we6		),
		.ram_net_up_wr_addr6(ram_net_up_wr_addr6	),
		.ram_net_up_wr_data6(ram_net_up_wr_data6	),
		.ram_net_up_len6	(ram_net_up_len6		),
		.ram_net_up_flag6	(ram_net_up_flag6		),
		.ram_net_up_clr6	(ram_net_up_clr6    	),
		.ram_ts_up_wr_en7	(ram_ts_up_wr_en7		),
		.ram_ts_up_wr_we7	(ram_ts_up_wr_we7		),
		.ram_ts_up_wr_addr7	(ram_ts_up_wr_addr7		),
		.ram_ts_up_wr_data7	(ram_ts_up_wr_data7		),
		.ram_net_up_wr_en7	(ram_net_up_wr_en7		),
		.ram_net_up_wr_we7	(ram_net_up_wr_we7		),
		.ram_net_up_wr_addr7(ram_net_up_wr_addr7	),
		.ram_net_up_wr_data7(ram_net_up_wr_data7	),
		.ram_net_up_len7	(ram_net_up_len7		),
		.ram_net_up_flag7	(ram_net_up_flag7		),
		.ram_net_up_clr7	(ram_net_up_clr7    	)
	);

	ram_2048 u_ram_net_up0(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en0		),
		.wea	(ram_net_up_wr_we0		),
		.addra	(ram_net_up_wr_addr0 	),
		.dina	(ram_net_up_wr_data0	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk0		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en0		),
		.web	(ram_net_up_rd_we0		),
		.addrb	(ram_net_up_rd_addr0 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data0	)
	);
	
	ram_16 u_ram_ts_up0(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en0		),
		.wea	(ram_ts_up_wr_we0		),
		.addra	(ram_ts_up_wr_addr0 	),
		.dina	(ram_ts_up_wr_data0		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk0		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en0		),
		.web	(ram_ts_up_rd_we0		),
		.addrb	(ram_ts_up_rd_addr0 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data0		)
	);
	
	ram_2048 u_ram_net_up1(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en1		),
		.wea	(ram_net_up_wr_we1		),
		.addra	(ram_net_up_wr_addr1 	),
		.dina	(ram_net_up_wr_data1	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk1		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en1		),
		.web	(ram_net_up_rd_we1		),
		.addrb	(ram_net_up_rd_addr1 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data1	)
	);
	
	ram_16 u_ram_ts_up1(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en1		),
		.wea	(ram_ts_up_wr_we1		),
		.addra	(ram_ts_up_wr_addr1 	),
		.dina	(ram_ts_up_wr_data1		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk1		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en1		),
		.web	(ram_ts_up_rd_we1		),
		.addrb	(ram_ts_up_rd_addr1 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data1		)
	);
	
	ram_2048 u_ram_net_up2(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en2		),
		.wea	(ram_net_up_wr_we2		),
		.addra	(ram_net_up_wr_addr2 	),
		.dina	(ram_net_up_wr_data2	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk2		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en2		),
		.web	(ram_net_up_rd_we2		),
		.addrb	(ram_net_up_rd_addr2 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data2	)
	);
	
	ram_16 u_ram_ts_up2(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en2		),
		.wea	(ram_ts_up_wr_we2		),
		.addra	(ram_ts_up_wr_addr2 	),
		.dina	(ram_ts_up_wr_data2		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk2		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en2		),
		.web	(ram_ts_up_rd_we2		),
		.addrb	(ram_ts_up_rd_addr2 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data2		)
	);
	
	ram_2048 u_ram_net_up3(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en3		),
		.wea	(ram_net_up_wr_we3		),
		.addra	(ram_net_up_wr_addr3 	),
		.dina	(ram_net_up_wr_data3	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk3		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en3		),
		.web	(ram_net_up_rd_we3		),
		.addrb	(ram_net_up_rd_addr3 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data3	)
	);
	
	ram_16 u_ram_ts_up3(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en3		),
		.wea	(ram_ts_up_wr_we3		),
		.addra	(ram_ts_up_wr_addr3 	),
		.dina	(ram_ts_up_wr_data3		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk3		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en3		),
		.web	(ram_ts_up_rd_we3		),
		.addrb	(ram_ts_up_rd_addr3 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data3		)
	);
	
	ram_2048 u_ram_net_up4(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en4		),
		.wea	(ram_net_up_wr_we4		),
		.addra	(ram_net_up_wr_addr4 	),
		.dina	(ram_net_up_wr_data4	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk4		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en4		),
		.web	(ram_net_up_rd_we4		),
		.addrb	(ram_net_up_rd_addr4 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data4	)
	);
	
	ram_16 u_ram_ts_up4(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en4		),
		.wea	(ram_ts_up_wr_we4		),
		.addra	(ram_ts_up_wr_addr4 	),
		.dina	(ram_ts_up_wr_data4		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk4		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en4		),
		.web	(ram_ts_up_rd_we4		),
		.addrb	(ram_ts_up_rd_addr4 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data4		)
	);
	
	ram_2048 u_ram_net_up5(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en5		),
		.wea	(ram_net_up_wr_we5		),
		.addra	(ram_net_up_wr_addr5 	),
		.dina	(ram_net_up_wr_data5	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk5		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en5		),
		.web	(ram_net_up_rd_we5		),
		.addrb	(ram_net_up_rd_addr5 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data5	)
	);
	
	ram_16 u_ram_ts_up5(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en5		),
		.wea	(ram_ts_up_wr_we5		),
		.addra	(ram_ts_up_wr_addr5 	),
		.dina	(ram_ts_up_wr_data5		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk5		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en5		),
		.web	(ram_ts_up_rd_we5		),
		.addrb	(ram_ts_up_rd_addr5 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data5		)
	);
	
	ram_2048 u_ram_net_up6(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en6		),
		.wea	(ram_net_up_wr_we6		),
		.addra	(ram_net_up_wr_addr6 	),
		.dina	(ram_net_up_wr_data6	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk6		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en6		),
		.web	(ram_net_up_rd_we6		),
		.addrb	(ram_net_up_rd_addr6 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data6	)
	);
	
	ram_16 u_ram_ts_up6(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en6		),
		.wea	(ram_ts_up_wr_we6		),
		.addra	(ram_ts_up_wr_addr6 	),
		.dina	(ram_ts_up_wr_data6		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk6		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en6		),
		.web	(ram_ts_up_rd_we6		),
		.addrb	(ram_ts_up_rd_addr6 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data6		)
	);
	
	ram_2048 u_ram_net_up7(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_up_wr_en7		),
		.wea	(ram_net_up_wr_we7		),
		.addra	(ram_net_up_wr_addr7 	),
		.dina	(ram_net_up_wr_data7	),
		.douta	(	),
		.clkb	(ram_net_up_rd_clk7		),
		.rstb	(~user_rst				),
		.enb	(ram_net_up_rd_en7		),
		.web	(ram_net_up_rd_we7		),
		.addrb	(ram_net_up_rd_addr7 	),
		.dinb	(32'd0	),
		.doutb	(ram_net_up_rd_data7	)
	);
	
	ram_16 u_ram_ts_up7(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_ts_up_wr_en7		),
		.wea	(ram_ts_up_wr_we7		),
		.addra	(ram_ts_up_wr_addr7 	),
		.dina	(ram_ts_up_wr_data7		),
		.douta	(	),
		.clkb	(ram_ts_up_rd_clk7		),
		.rstb	(~user_rst				),
		.enb	(ram_ts_up_rd_en7		),
		.web	(ram_ts_up_rd_we7		),
		.addrb	(ram_ts_up_rd_addr7 	),
		.dinb	(32'd0	),
		.doutb	(ram_ts_up_rd_data7		)
	);

	rgmii_tx u_rgmii_tx(
		.rgmii_txclk	(user_clk_dcm_180d		),
		.rgmii_txclk_tmp(user_clk_dcm_180dd		),
		.rgmii_txclk_n	(user_clk_dcm			),
		.gmii_txd		(gmii_txd				),
		.gmii_txdv		(gmii_txdv				),
		.rgmii_txclk_o	(rgmii_txclk			),
		.rgmii_txd_o	(rgmii_txd				),
		.rgmii_txdv_o	(rgmii_txdv				)
	);
	
	net_down u_net_down(
		.clk_125m				(user_clk_dcm			),
		.rst_n   				(user_rst				),
		.gmii_txd				(gmii_txd				),
		.gmii_txdv				(gmii_txdv				),
		.ram_net_down_rd_en		(ram_net_down_rd_en		),
		.ram_net_down_rd_we		(ram_net_down_rd_we		),
		.ram_net_down_rd_addr 	(ram_net_down_rd_addr 	),
		.ram_net_down_rd_data	(ram_net_down_rd_data	),
		.ram_net_down_start		(ram_net_down_start		),
		.ram_net_down_len		(ram_net_down_len		),
		.ram_net_down_completed (ram_net_down_completed )
	);
	
	ram_2048 u_ram_net_down(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_net_down_rd_en		),
		.wea	(ram_net_down_rd_we		),
		.addra	(ram_net_down_rd_addr 	),
		.dina	(8'd0					),
		.douta	(ram_net_down_rd_data	),
		.clkb	(ram_net_down_wr_clk	),
		.rstb	(~user_rst				),
		.enb	(ram_net_down_wr_en		),
		.web	(ram_net_down_wr_we		),
		.addrb	(ram_net_down_wr_addr 	),
		.dinb	(ram_net_down_wr_data	),
		.doutb	(	)
	);

//////////////////////////////////////////////////////////////////////////////////
// TOD信息解析
//////////////////////////////////////////////////////////////////////////////////
	tod u_tod(
		.clk_125m      		    (user_clk_dcm      	    ),
		.rst_n         		    (user_rst         	    ),
		.pps_in        		    (pps_in        		    ),
		.tod_in        		    (tod_in        		    ),

		.timer_stop			    (timer_stop			    ),
		.ts_week	       	    (ts_week	       	    ),
		.ts_week_sec      	    (ts_week_sec      	    ),
		.ts_nano_sec      	    (ts_nano_sec      	    ),
		.ts_leap_sec      	    (ts_leap_sec      	    ),
		.ts_pps_state     	    (ts_pps_state     	    ),
		.ts_timesrc_type  	    (ts_timesrc_type  	    ),
		.ts_pps_precision 	    (ts_pps_precision 	    ),
		.ts_checksum		    (ts_checksum	   	    ),

        .uart_ustod_latch_flag  (uart_ustod_latch_flag  ),
        .bar_year_month_day     (bar_year_month_day     ),
        .bar_hour_min_sec       (bar_hour_min_sec       ),
        .bar_nano_sec           (bar_nano_sec           ),

		.ram_tod_up_wr_en	    (ram_tod_up_wr_en	    ),
		.ram_tod_up_wr_we	    (ram_tod_up_wr_we	    ),
		.ram_tod_up_wr_addr	    (ram_tod_up_wr_addr	    ),
		.ram_tod_up_wr_data	    (ram_tod_up_wr_data	    ),
		.ram_tod_up_len		    (ram_tod_up_len		    ),
		.ram_tod_up_flag	    (ram_tod_up_flag	    ),
		.ram_tod_up_clr         (ram_tod_up_clr         )
	);
	
	ram_512 u_ram_tod_up(
		.clka	(user_clk_dcm		),
		.rsta	(~user_rst			),
		.ena	(ram_tod_up_wr_en	),
		.wea	(ram_tod_up_wr_we	),
		.addra	(ram_tod_up_wr_addr	),
		.dina	(ram_tod_up_wr_data	),
		.douta	(		),
		.clkb	(ram_tod_up_rd_clk	),
		.rstb	(~user_rst			),
		.enb	(ram_tod_up_rd_en	),
		.web	(ram_tod_up_rd_we	),
		.addrb	(ram_tod_up_rd_addr	),
		.dinb	(32'd0				),
		.doutb	(ram_tod_up_rd_data)
	);
//////////////////////////////////////////////////////////////////////////////////
// M6X串口
//////////////////////////////////////////////////////////////////////////////////
	M6X_uart u_M6X_uart(
		.clk_125m				(user_clk_dcm			),
		.rst_n   				(user_rst				),
		.uart_rx 				(uart_rx				),
		.uart_tx 				(uart_tx				),
		.ram_uart_up_wr_en		(ram_uart_up_wr_en		),
		.ram_uart_up_wr_we		(ram_uart_up_wr_we		),
		.ram_uart_up_wr_addr	(ram_uart_up_wr_addr	),
		.ram_uart_up_wr_data	(ram_uart_up_wr_data	),
		.ram_uart_up_len		(ram_uart_up_len		),
		.ram_uart_up_flag		(ram_uart_up_flag		),
		.ram_uart_up_clr		(ram_uart_up_clr		),
		.ram_uart_down_rd_en	(ram_uart_down_rd_en	),
		.ram_uart_down_rd_we	(ram_uart_down_rd_we	),
		.ram_uart_down_rd_addr  (ram_uart_down_rd_addr  ),
		.ram_uart_down_rd_data	(ram_uart_down_rd_data	),
		.ram_uart_down_start	(ram_uart_down_start	),
		.ram_uart_down_len		(ram_uart_down_len		),
		.ram_uart_down_completed(ram_uart_down_completed)
	);
	
	ram_8192 u_ram_uart_up(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_uart_up_wr_en		),
		.wea	(ram_uart_up_wr_we		),
		.addra	(ram_uart_up_wr_addr	),
		.dina	(ram_uart_up_wr_data	),
		.douta	(		),
		.clkb	(ram_uart_up_rd_clk		),
		.rstb	(~user_rst				),
		.enb	(ram_uart_up_rd_en		),
		.web	(ram_uart_up_rd_we		),
		.addrb	(ram_uart_up_rd_addr	),
		.dinb	(32'd0					),
		.doutb	(ram_uart_up_rd_data	)
	);
	
	ram_256 u_ram_uart_down(
		.clka	(user_clk_dcm			),
		.rsta	(~user_rst				),
		.ena	(ram_uart_down_rd_en	),
		.wea	(ram_uart_down_rd_we	),
		.addra	(ram_uart_down_rd_addr	),
		.dina	(8'd0					),
		.douta	(ram_uart_down_rd_data	),
		.clkb	(ram_uart_down_wr_clk	),
		.rstb	(~user_rst				),
		.enb	(ram_uart_down_wr_en	),
		.web	(ram_uart_down_wr_we	),
		.addrb	(ram_uart_down_wr_addr	),
		.dinb	(ram_uart_down_wr_data	),
		.doutb	(	)
	);

	
endmodule
