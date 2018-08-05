module net_down(
	input             clk_125m,
	input             rst_n   ,
	
	output reg [7:0]  gmii_txd,
	output reg        gmii_txdv,
	
	output reg        ram_net_down_rd_en	,
	output reg        ram_net_down_rd_we	,
	output reg [10:0] ram_net_down_rd_addr  ,
	input      [7:0]  ram_net_down_rd_data	,
	input             ram_net_down_start	,
	input      [10:0] ram_net_down_len		,
	output reg        ram_net_down_completed 
);

	reg [3:0]  state;
	reg [3:0]  cnt_completed;
	reg [10:0] cnt_net_tx;
	wire       add_cnt_net_tx;
	wire       end_cnt_net_tx;
	reg        ram_net_down_start_ff0;
	reg        ram_net_down_start_ff1;
	reg        ram_net_down_start_ff2;
	wire       ram_net_down_start_l2h;
	reg [10:0] net_tx_len;
	reg        flag_cnt_uart_tx;
	
	always @ (*)begin
		ram_net_down_rd_en = add_cnt_net_tx;
		ram_net_down_rd_we = 0;
        ram_net_down_rd_addr = cnt_net_tx;
	end
	
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			gmii_txdv <= 0;
		end
		else if(add_cnt_net_tx)begin
			gmii_txdv <= 1;
		end
		else begin
			gmii_txdv <= 0;
		end
	end
    
    always @ (*)begin
        gmii_txd = ram_net_down_rd_data;
    end
	
/*	//测试
	reg [3:0] step;
	reg [27:0] cnt;
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			step <= 0;
			cnt <= 0;
			gmii_txd <= 0;
			gmii_txdv <= 0;
		end
		else begin
			case(step)
				0:begin
					if(cnt == 62_500_000-1)begin
						step <= 1;
						cnt <= 0;
						gmii_txd <= 8'h0d;
						gmii_txdv <= 1;
					end
					else begin
						step <= 0;
						cnt <= cnt + 1'b1;
						gmii_txd <= 0;
						gmii_txdv <= 0;
					end
				end
				1:begin
					step <= 2;
					cnt <= 0;
					gmii_txd <= 0;
					gmii_txdv <= 0;
				end
				2:begin
					if(rdy == 1)begin
						step <= 0;
						cnt <= 0;
						gmii_txd <= 8'h0a;
						gmii_txdv <= 1;
					end
				end
			endcase
		end
	end*/
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			state <= 0;
			cnt_completed <= 0;
			ram_net_down_completed <= 0;
		end
		else begin
			case(state)
				0:begin
					if(end_cnt_net_tx)begin
						state <= 1;
						cnt_completed <= 0;
						ram_net_down_completed <= 0;
					end
				end
				1:begin
					if(cnt_completed == 8-1)begin
						state <= 0;
						cnt_completed <= 0;
						ram_net_down_completed <= 0;
					end
					else begin
						state <= 1;
						cnt_completed <= cnt_completed + 1'b1;
						ram_net_down_completed <= 1;
					end
				end
			endcase
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_net_tx <= 0;
		end
		else if(add_cnt_net_tx)begin
			if(end_cnt_net_tx)
				cnt_net_tx <= 0;
			else
				cnt_net_tx <= cnt_net_tx + 1'b1;
		end
	end
	
	assign add_cnt_net_tx = flag_cnt_uart_tx;
	assign end_cnt_net_tx = add_cnt_net_tx && cnt_net_tx == net_tx_len-1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_net_down_start_ff0 <= 0;
			ram_net_down_start_ff1 <= 0;
			ram_net_down_start_ff2 <= 0;
		end
		else begin
			ram_net_down_start_ff0 <= ram_net_down_start;
			ram_net_down_start_ff1 <= ram_net_down_start_ff0;
			ram_net_down_start_ff2 <= ram_net_down_start_ff1;
		end
	end
	
	assign ram_net_down_start_l2h = ram_net_down_start_ff2 == 0 && ram_net_down_start_ff1 == 1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			net_tx_len <= 0;
		end
		else if(ram_net_down_start_l2h)begin
			net_tx_len <= ram_net_down_len;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			flag_cnt_uart_tx <= 0;
		end
		else if(ram_net_down_start_l2h)begin
			flag_cnt_uart_tx <= 1;
		end
		else if(end_cnt_net_tx)begin
			flag_cnt_uart_tx <= 0;
		end
	end
	
endmodule
