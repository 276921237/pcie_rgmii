module net_up(
	input             clk_125m			,
	input             rst_n   			,
	input  	   [7:0]  gmii_rxd			,
	input  	          gmii_rxdv			,
	output reg        timer_stop		,
	input      [15:0] ts_week	       	,
	input      [31:0] ts_week_sec      	,
	input      [31:0] ts_nano_sec      	,
	input      [7:0]  ts_leap_sec      	,
	input      [7:0]  ts_pps_state     	,
	input      [7:0]  ts_timesrc_type  	,
	input      [7:0]  ts_pps_precision 	,
	input      [7:0]  ts_checksum		,
	
	output reg 		  ram_ts_up_wr_en0,ram_ts_up_wr_en1,ram_ts_up_wr_en2,ram_ts_up_wr_en3,
	output reg 		  ram_ts_up_wr_en4,ram_ts_up_wr_en5,ram_ts_up_wr_en6,ram_ts_up_wr_en7,
	output reg 	      ram_ts_up_wr_we0,ram_ts_up_wr_we1,ram_ts_up_wr_we2,ram_ts_up_wr_we3,
	output reg 	      ram_ts_up_wr_we4,ram_ts_up_wr_we5,ram_ts_up_wr_we6,ram_ts_up_wr_we7,
	output reg [3:0]ram_ts_up_wr_addr0,reg[3:0]ram_ts_up_wr_addr1,reg[3:0]ram_ts_up_wr_addr2,reg[3:0]ram_ts_up_wr_addr3,
	output reg [3:0]ram_ts_up_wr_addr4,reg[3:0]ram_ts_up_wr_addr5,reg[3:0]ram_ts_up_wr_addr6,reg[3:0]ram_ts_up_wr_addr7,
	output reg [7:0]ram_ts_up_wr_data0,reg[7:0]ram_ts_up_wr_data1,reg[7:0]ram_ts_up_wr_data2,reg[7:0]ram_ts_up_wr_data3,
	output reg [7:0]ram_ts_up_wr_data4,reg[7:0]ram_ts_up_wr_data5,reg[7:0]ram_ts_up_wr_data6,reg[7:0]ram_ts_up_wr_data7,
	
	output reg 		  ram_net_up_wr_en0,ram_net_up_wr_en1,ram_net_up_wr_en2,ram_net_up_wr_en3,
	output reg 		  ram_net_up_wr_en4,ram_net_up_wr_en5,ram_net_up_wr_en6,ram_net_up_wr_en7,
	output reg 	      ram_net_up_wr_we0,ram_net_up_wr_we1,ram_net_up_wr_we2,ram_net_up_wr_we3,
	output reg 	      ram_net_up_wr_we4,ram_net_up_wr_we5,ram_net_up_wr_we6,ram_net_up_wr_we7,
	output reg [10:0] ram_net_up_wr_addr0,reg[10:0] ram_net_up_wr_addr1,reg[10:0] ram_net_up_wr_addr2,reg[10:0] ram_net_up_wr_addr3,
	output reg [10:0] ram_net_up_wr_addr4,reg[10:0] ram_net_up_wr_addr5,reg[10:0] ram_net_up_wr_addr6,reg[10:0] ram_net_up_wr_addr7,
	output reg [7:0]  ram_net_up_wr_data0,reg[7:0]  ram_net_up_wr_data1,reg[7:0]  ram_net_up_wr_data2,reg[7:0]  ram_net_up_wr_data3,
	output reg [7:0]  ram_net_up_wr_data4,reg[7:0]  ram_net_up_wr_data5,reg[7:0]  ram_net_up_wr_data6,reg[7:0]  ram_net_up_wr_data7,
	
(* KEEP="TRUE"*)	output reg [10:0] ram_net_up_len0,reg[10:0] ram_net_up_len1,reg[10:0] ram_net_up_len2,reg[10:0] ram_net_up_len3,
	output reg [10:0] ram_net_up_len4,reg[10:0] ram_net_up_len5,reg[10:0] ram_net_up_len6,reg[10:0] ram_net_up_len7,
	output reg        ram_net_up_flag0,ram_net_up_flag1,ram_net_up_flag2,ram_net_up_flag3,
	output reg        ram_net_up_flag4,ram_net_up_flag5,ram_net_up_flag6,ram_net_up_flag7,
	input             ram_net_up_clr0,ram_net_up_clr1,ram_net_up_clr2,ram_net_up_clr3,
	input             ram_net_up_clr4,ram_net_up_clr5,ram_net_up_clr6,ram_net_up_clr7
);
	
	reg [3:0] cnt_preamble;
	reg [2:0] cnt_group;
	wire      add_cnt_group;
	wire      end_cnt_group;
	reg       gmii_rxdv_ff0;
	wire      gmii_rxdv_h2l;
	wire      gmii_rxdv_l2h;
	reg       data_vld;
	reg [7:0] timer_stop_ff;
	reg [3:0] cnt_ts;
	wire      add_cnt_ts;
	wire      end_cnt_ts;
	reg       flag_cnt_ts;
	(* KEEP="TRUE"*)reg       ram_ts_up_wr_en_tmp;
	(* KEEP="TRUE"*)reg       ram_ts_up_wr_we_tmp;
	reg [3:0] ram_ts_up_wr_addr_tmp;
	reg [7:0] ram_ts_up_wr_data_tmp;
	
	reg [10:0] cnt_net;
	(* KEEP="TRUE"*)reg        ram_net_up_wr_en_tmp;
	(* KEEP="TRUE"*)reg        ram_net_up_wr_we_tmp;
	reg [10:0] ram_net_up_wr_addr_tmp;
	reg [7:0]  ram_net_up_wr_data_tmp;
	(* KEEP="TRUE"*)reg [10:0]  ram_net_up_len_tmp;
	(* KEEP="TRUE"*)wire [7:0] ram_net_up_flag_tmp;
	reg     [7:0]ram_net_up_clr_ff0;
	reg     [7:0]ram_net_up_clr_ff1;
	reg     [7:0]ram_net_up_clr_ff2;
	wire    ram_net_up_clr0_l2h;
	wire    ram_net_up_clr1_l2h;
	wire    ram_net_up_clr2_l2h;
	wire    ram_net_up_clr3_l2h;
	wire    ram_net_up_clr4_l2h;
	wire    ram_net_up_clr5_l2h;
	wire    ram_net_up_clr6_l2h;
	wire    ram_net_up_clr7_l2h;
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_preamble <= 0;
			timer_stop <= 0;
		end
		else if(gmii_rxdv && gmii_rxd == 8'h55 && cnt_preamble <= 6)begin
			cnt_preamble <= cnt_preamble + 1'b1;
			timer_stop <= 0;
		end
		else if(gmii_rxdv && gmii_rxd == 8'hd5 && cnt_preamble == 7)begin
			cnt_preamble <= cnt_preamble + 1'b1;
			timer_stop <= 1;
		end
		else begin
			cnt_preamble <= 0;
			timer_stop <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_group <= 0;
		end
		else if(add_cnt_group)begin
			if(end_cnt_group)
				cnt_group <= 0;
			else
				cnt_group <= cnt_group + 1'b1;
		end
	end
	
	assign add_cnt_group = gmii_rxdv_h2l && data_vld;
	assign end_cnt_group = add_cnt_group && cnt_group == 8-1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			gmii_rxdv_ff0 <= 0;
		end
		else begin
			gmii_rxdv_ff0 <= gmii_rxdv;
		end
	end
	
	assign gmii_rxdv_l2h = gmii_rxdv_ff0 == 0 && gmii_rxdv == 1;
	assign gmii_rxdv_h2l = gmii_rxdv_ff0 == 1 && gmii_rxdv == 0;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			data_vld <= 0;
		end
		else if(gmii_rxdv_l2h && ram_net_up_flag_tmp != 8'hff)begin
			data_vld <= 1;
		end
		else if(gmii_rxdv_h2l)begin
			data_vld <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_ts_up_wr_en0 <= 0;ram_ts_up_wr_en1 <= 0;ram_ts_up_wr_en2 <= 0;ram_ts_up_wr_en3 <= 0;
			ram_ts_up_wr_en4 <= 0;ram_ts_up_wr_en5 <= 0;ram_ts_up_wr_en6 <= 0;ram_ts_up_wr_en7 <= 0;
			ram_ts_up_wr_we0 <= 0;ram_ts_up_wr_we1 <= 0;ram_ts_up_wr_we2 <= 0;ram_ts_up_wr_we3 <= 0;
			ram_ts_up_wr_we4 <= 0;ram_ts_up_wr_we5 <= 0;ram_ts_up_wr_we6 <= 0;ram_ts_up_wr_we7 <= 0;
			ram_ts_up_wr_addr0 <= 0;ram_ts_up_wr_addr1 <= 0;ram_ts_up_wr_addr2 <= 0;ram_ts_up_wr_addr3 <= 0;
			ram_ts_up_wr_addr4 <= 0;ram_ts_up_wr_addr5 <= 0;ram_ts_up_wr_addr6 <= 0;ram_ts_up_wr_addr7 <= 0;
			ram_ts_up_wr_data0 <= 0;ram_ts_up_wr_data1 <= 0;ram_ts_up_wr_data2 <= 0;ram_ts_up_wr_data3 <= 0;
			ram_ts_up_wr_data4 <= 0;ram_ts_up_wr_data5 <= 0;ram_ts_up_wr_data6 <= 0;ram_ts_up_wr_data7 <= 0;
		end
		else if(data_vld)begin
			case(cnt_group)
				0:begin
					ram_ts_up_wr_en0   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we0   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr0 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data0 <= ram_ts_up_wr_data_tmp	;	
				end
				1:begin
					ram_ts_up_wr_en1   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we1   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr1 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data1 <= ram_ts_up_wr_data_tmp	;	
				end
				2:begin
					ram_ts_up_wr_en2   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we2   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr2 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data2 <= ram_ts_up_wr_data_tmp	;	
				end
				3:begin
					ram_ts_up_wr_en3   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we3   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr3 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data3 <= ram_ts_up_wr_data_tmp	;	
				end
				4:begin
					ram_ts_up_wr_en4   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we4   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr4 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data4 <= ram_ts_up_wr_data_tmp	;	
				end
				5:begin
					ram_ts_up_wr_en5   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we5   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr5 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data5 <= ram_ts_up_wr_data_tmp	;	
				end
				6:begin
					ram_ts_up_wr_en6   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we6   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr6 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data6 <= ram_ts_up_wr_data_tmp	;	
				end
				7:begin
					ram_ts_up_wr_en7   <= ram_ts_up_wr_en_tmp	;
					ram_ts_up_wr_we7   <= ram_ts_up_wr_we_tmp	;
					ram_ts_up_wr_addr7 <= ram_ts_up_wr_addr_tmp	;
					ram_ts_up_wr_data7 <= ram_ts_up_wr_data_tmp	;	
				end
			endcase
		end
		else begin
			ram_ts_up_wr_en0 <= 0;ram_ts_up_wr_en1 <= 0;ram_ts_up_wr_en2 <= 0;ram_ts_up_wr_en3 <= 0;
			ram_ts_up_wr_en4 <= 0;ram_ts_up_wr_en5 <= 0;ram_ts_up_wr_en6 <= 0;ram_ts_up_wr_en7 <= 0;
			ram_ts_up_wr_we0 <= 0;ram_ts_up_wr_we1 <= 0;ram_ts_up_wr_we2 <= 0;ram_ts_up_wr_we3 <= 0;
			ram_ts_up_wr_we4 <= 0;ram_ts_up_wr_we5 <= 0;ram_ts_up_wr_we6 <= 0;ram_ts_up_wr_we7 <= 0;
			ram_ts_up_wr_addr0 <= 0;ram_ts_up_wr_addr1 <= 0;ram_ts_up_wr_addr2 <= 0;ram_ts_up_wr_addr3 <= 0;
			ram_ts_up_wr_addr4 <= 0;ram_ts_up_wr_addr5 <= 0;ram_ts_up_wr_addr6 <= 0;ram_ts_up_wr_addr7 <= 0;
			ram_ts_up_wr_data0 <= 0;ram_ts_up_wr_data1 <= 0;ram_ts_up_wr_data2 <= 0;ram_ts_up_wr_data3 <= 0;
			ram_ts_up_wr_data4 <= 0;ram_ts_up_wr_data5 <= 0;ram_ts_up_wr_data6 <= 0;ram_ts_up_wr_data7 <= 0;		
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_net_up_wr_en0 <= 0;ram_net_up_wr_en1 <= 0;ram_net_up_wr_en2 <= 0;ram_net_up_wr_en3 <= 0;
			ram_net_up_wr_en4 <= 0;ram_net_up_wr_en5 <= 0;ram_net_up_wr_en6 <= 0;ram_net_up_wr_en7 <= 0;
			ram_net_up_wr_we0 <= 0;ram_net_up_wr_we1 <= 0;ram_net_up_wr_we2 <= 0;ram_net_up_wr_we3 <= 0;
			ram_net_up_wr_we4 <= 0;ram_net_up_wr_we5 <= 0;ram_net_up_wr_we6 <= 0;ram_net_up_wr_we7 <= 0;
			ram_net_up_wr_addr0 <= 0;ram_net_up_wr_addr1 <= 0;ram_net_up_wr_addr2 <= 0;ram_net_up_wr_addr3 <= 0;
			ram_net_up_wr_addr4 <= 0;ram_net_up_wr_addr5 <= 0;ram_net_up_wr_addr6 <= 0;ram_net_up_wr_addr7 <= 0;
			ram_net_up_wr_data0 <= 0;ram_net_up_wr_data1 <= 0;ram_net_up_wr_data2 <= 0;ram_net_up_wr_data3 <= 0;
			ram_net_up_wr_data4 <= 0;ram_net_up_wr_data5 <= 0;ram_net_up_wr_data6 <= 0;ram_net_up_wr_data7 <= 0;
			
			ram_net_up_len0 <= 0;ram_net_up_len1 <= 0;ram_net_up_len2 <= 0;ram_net_up_len3 <= 0;
			ram_net_up_len4 <= 0;ram_net_up_len5 <= 0;ram_net_up_len6 <= 0;ram_net_up_len7 <= 0;
		end
		else if(data_vld)begin
			case(cnt_group)
				0:begin
					ram_net_up_wr_en0	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we0	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr0 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data0 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len0 <= ram_net_up_len_tmp;
				end
				1:begin
					ram_net_up_wr_en1	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we1	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr1 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data1 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len1 <= ram_net_up_len_tmp;
				end
				2:begin
					ram_net_up_wr_en2	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we2	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr2 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data2 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len2 <= ram_net_up_len_tmp;
				end
				3:begin
					ram_net_up_wr_en3	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we3	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr3 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data3 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len3 <= ram_net_up_len_tmp;
				end
				4:begin
					ram_net_up_wr_en4	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we4	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr4 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data4 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len4 <= ram_net_up_len_tmp;
				end
				5:begin
					ram_net_up_wr_en5	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we5	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr5 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data5 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len5 <= ram_net_up_len_tmp;
				end
				6:begin
					ram_net_up_wr_en6	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we6	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr6 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data6 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len6 <= ram_net_up_len_tmp;
				end
				7:begin
					ram_net_up_wr_en7	<= ram_net_up_wr_en_tmp		;
					ram_net_up_wr_we7	<= ram_net_up_wr_we_tmp		;
					ram_net_up_wr_addr7 <= ram_net_up_wr_addr_tmp	;
					ram_net_up_wr_data7 <= ram_net_up_wr_data_tmp	;
			
					ram_net_up_len7 <= ram_net_up_len_tmp;
				end
			endcase
		end
		else begin
			ram_net_up_wr_en0 <= 0;ram_net_up_wr_en1 <= 0;ram_net_up_wr_en2 <= 0;ram_net_up_wr_en3 <= 0;
			ram_net_up_wr_en4 <= 0;ram_net_up_wr_en5 <= 0;ram_net_up_wr_en6 <= 0;ram_net_up_wr_en7 <= 0;
			ram_net_up_wr_we0 <= 0;ram_net_up_wr_we1 <= 0;ram_net_up_wr_we2 <= 0;ram_net_up_wr_we3 <= 0;
			ram_net_up_wr_we4 <= 0;ram_net_up_wr_we5 <= 0;ram_net_up_wr_we6 <= 0;ram_net_up_wr_we7 <= 0;
			ram_net_up_wr_addr0 <= 0;ram_net_up_wr_addr1 <= 0;ram_net_up_wr_addr2 <= 0;ram_net_up_wr_addr3 <= 0;
			ram_net_up_wr_addr4 <= 0;ram_net_up_wr_addr5 <= 0;ram_net_up_wr_addr6 <= 0;ram_net_up_wr_addr7 <= 0;
			ram_net_up_wr_data0 <= 0;ram_net_up_wr_data1 <= 0;ram_net_up_wr_data2 <= 0;ram_net_up_wr_data3 <= 0;
			ram_net_up_wr_data4 <= 0;ram_net_up_wr_data5 <= 0;ram_net_up_wr_data6 <= 0;ram_net_up_wr_data7 <= 0;		
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			timer_stop_ff <= 0;
		end
		else begin
			timer_stop_ff <= {timer_stop_ff[6:0],timer_stop};
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_ts <= 0;
		end
		else if(add_cnt_ts)begin
			if(end_cnt_ts)
				cnt_ts <= 0;
			else
				cnt_ts <= cnt_ts + 1'b1;
		end
	end
	
	assign add_cnt_ts = flag_cnt_ts;
	assign end_cnt_ts = add_cnt_ts && cnt_ts == 16-1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			flag_cnt_ts <= 0;
		end
		else if(timer_stop_ff[7])begin
			flag_cnt_ts <= 1;
		end
		else if(end_cnt_ts)begin
			flag_cnt_ts <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_ts_up_wr_en_tmp <= 0;
			ram_ts_up_wr_we_tmp <= 0;
		end
		else if(add_cnt_ts)begin
			ram_ts_up_wr_en_tmp <= 1;
			ram_ts_up_wr_we_tmp <= 1;
		end
		else begin
			ram_ts_up_wr_en_tmp <= 0;
			ram_ts_up_wr_we_tmp <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_ts_up_wr_addr_tmp <= 0;
		end
		else begin
			ram_ts_up_wr_addr_tmp <= cnt_ts[3:0];
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_ts_up_wr_data_tmp <= 0;
		end
		else begin
			case(cnt_ts)
				0 :ram_ts_up_wr_data_tmp <= ts_week_sec[31:24];
				1 :ram_ts_up_wr_data_tmp <= ts_week_sec[23:16];
				2 :ram_ts_up_wr_data_tmp <= ts_week_sec[15:8];
				3 :ram_ts_up_wr_data_tmp <= ts_week_sec[7:0];
				4 :ram_ts_up_wr_data_tmp <= ts_week[15:8];
				5 :ram_ts_up_wr_data_tmp <= ts_week[7:0];
				6 :ram_ts_up_wr_data_tmp <= ts_nano_sec[31:24];
				7 :ram_ts_up_wr_data_tmp <= ts_nano_sec[23:16];
				8 :ram_ts_up_wr_data_tmp <= ts_nano_sec[15:8];
				9 :ram_ts_up_wr_data_tmp <= ts_nano_sec[7:0];
				10:ram_ts_up_wr_data_tmp <= ts_leap_sec;
				11:ram_ts_up_wr_data_tmp <= ts_pps_state;
				12:ram_ts_up_wr_data_tmp <= ts_timesrc_type;
				13:ram_ts_up_wr_data_tmp <= ts_pps_precision;
				14:ram_ts_up_wr_data_tmp <= 8'h00;
				15:ram_ts_up_wr_data_tmp <= ts_checksum;
				default:ram_ts_up_wr_data_tmp <= 8'h00;
			endcase
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_net <= 0;
		end
		else if(gmii_rxdv_h2l)begin
			cnt_net <= 0;
		end
		else if(gmii_rxdv)begin
			cnt_net <= cnt_net + 1'b1;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_net_up_wr_en_tmp <= 0;
			ram_net_up_wr_we_tmp <= 0;
		end
		else if(gmii_rxdv)begin
			ram_net_up_wr_en_tmp <= 1;
			ram_net_up_wr_we_tmp <= 1;
		end
		else begin
			ram_net_up_wr_en_tmp <= 0;
			ram_net_up_wr_we_tmp <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_net_up_wr_addr_tmp <= 0;
		end
		else begin
			ram_net_up_wr_addr_tmp <= cnt_net;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_net_up_len_tmp <= 0;
		end
		else if(gmii_rxdv_h2l)begin
			ram_net_up_len_tmp <= cnt_net;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n )begin
		if(!rst_n)begin
			ram_net_up_wr_data_tmp <= 0;
		end
		else begin
			ram_net_up_wr_data_tmp <= gmii_rxd;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_net_up_flag0 <= 0;ram_net_up_flag1 <= 0;ram_net_up_flag2 <= 0;ram_net_up_flag3 <= 0;
			ram_net_up_flag4 <= 0;ram_net_up_flag5 <= 0;ram_net_up_flag6 <= 0;ram_net_up_flag7 <= 0;
		end
		else if(gmii_rxdv_h2l && data_vld)begin
			case(cnt_group)
				0:ram_net_up_flag0 <= 1;
				1:ram_net_up_flag1 <= 1;
				2:ram_net_up_flag2 <= 1;
				3:ram_net_up_flag3 <= 1;
				4:ram_net_up_flag4 <= 1;
				5:ram_net_up_flag5 <= 1;
				6:ram_net_up_flag6 <= 1;
				7:ram_net_up_flag7 <= 1;
			endcase
		end
		else if(ram_net_up_clr0_l2h)begin
			ram_net_up_flag0 <= 0;
		end
		else if(ram_net_up_clr1_l2h)begin
			ram_net_up_flag1 <= 0;
		end
		else if(ram_net_up_clr2_l2h)begin
			ram_net_up_flag2 <= 0;
		end
		else if(ram_net_up_clr3_l2h)begin
			ram_net_up_flag3 <= 0;
		end
		else if(ram_net_up_clr4_l2h)begin
			ram_net_up_flag4 <= 0;
		end
		else if(ram_net_up_clr5_l2h)begin
			ram_net_up_flag5 <= 0;
		end
		else if(ram_net_up_clr6_l2h)begin
			ram_net_up_flag6 <= 0;
		end
		else if(ram_net_up_clr7_l2h)begin
			ram_net_up_flag7 <= 0;
		end
	end
	
	assign ram_net_up_flag_tmp = {ram_net_up_flag7,ram_net_up_flag6,ram_net_up_flag5,ram_net_up_flag4,ram_net_up_flag3,ram_net_up_flag2,ram_net_up_flag1,ram_net_up_flag0};
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_net_up_clr_ff0 <= 0;
			ram_net_up_clr_ff1 <= 0;
			ram_net_up_clr_ff2 <= 0;
		end
		else begin
			ram_net_up_clr_ff0 <= {ram_net_up_clr7,ram_net_up_clr6,ram_net_up_clr5,ram_net_up_clr4,ram_net_up_clr3,ram_net_up_clr2,ram_net_up_clr1,ram_net_up_clr0};
			ram_net_up_clr_ff1 <= ram_net_up_clr_ff0;
			ram_net_up_clr_ff2 <= ram_net_up_clr_ff1;
		end
	end
	
	assign ram_net_up_clr0_l2h = ram_net_up_clr_ff2[0] == 0 && ram_net_up_clr_ff1[0] == 1;
	assign ram_net_up_clr1_l2h = ram_net_up_clr_ff2[1] == 0 && ram_net_up_clr_ff1[1] == 1;
	assign ram_net_up_clr2_l2h = ram_net_up_clr_ff2[2] == 0 && ram_net_up_clr_ff1[2] == 1;
	assign ram_net_up_clr3_l2h = ram_net_up_clr_ff2[3] == 0 && ram_net_up_clr_ff1[3] == 1;
	assign ram_net_up_clr4_l2h = ram_net_up_clr_ff2[4] == 0 && ram_net_up_clr_ff1[4] == 1;
	assign ram_net_up_clr5_l2h = ram_net_up_clr_ff2[5] == 0 && ram_net_up_clr_ff1[5] == 1;
	assign ram_net_up_clr6_l2h = ram_net_up_clr_ff2[6] == 0 && ram_net_up_clr_ff1[6] == 1;
	assign ram_net_up_clr7_l2h = ram_net_up_clr_ff2[7] == 0 && ram_net_up_clr_ff1[7] == 1;
	
endmodule
