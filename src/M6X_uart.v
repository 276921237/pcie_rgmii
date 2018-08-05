module M6X_uart(
	input             clk_125m				,
	input             rst_n   				,
	input             uart_rx 				,
	output            uart_tx 				,
	
	output reg        ram_uart_up_wr_en		,
	output reg        ram_uart_up_wr_we		,
	output reg [12:0] ram_uart_up_wr_addr	,
	output reg [7:0]  ram_uart_up_wr_data	,
	output reg [12:0] ram_uart_up_len		,
	output reg        ram_uart_up_flag		,
	input             ram_uart_up_clr		,
	
	output reg        ram_uart_down_rd_en	,
	output reg        ram_uart_down_rd_we	,
	output reg [7:0]  ram_uart_down_rd_addr ,
	input      [7:0]  ram_uart_down_rd_data	,
	input             ram_uart_down_start	,
	input      [7:0]  ram_uart_down_len		,
	output reg        ram_uart_down_completed 
);

	wire [7:0] rx_data;
	wire       rx_data_vld;
	reg        start_cnt_rx_time;
	reg [20:0] cnt_rx_time;
	wire       add_cnt_rx_time;
	wire       end_cnt_rx_time;
	wire       keep_cnt_rx_time;
	reg        keep_cnt_rx_time_ff0;
	reg        keep_cnt_rx_time_ff1;
	wire       keep_cnt_rx_time_l2h;
	reg [15:0] rx_data_2byte;
	reg [7:0]  rx_data_1byte;
	wire       flag_0x0d0a;
	wire       flag_0x00;
	reg        ram_uart_up_clr_ff0;
	reg        ram_uart_up_clr_ff1;
	reg        ram_uart_up_clr_ff2;
	wire       ram_uart_up_clr_l2h;
	uart_rx u_uart_rx(
		.clk_125m	(clk_125m	),
		.rst_n   	(rst_n   	),
		.sel 	  	(4'd5 	  	),
		.odd_even	(4'd0		),
		.din     	(uart_rx   	),
		.dout    	(rx_data   	),
		.dout_vld	(rx_data_vld)
	);
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_uart_up_wr_en <= 0;
			ram_uart_up_wr_we <= 0;
		end
		else if(rx_data_vld)begin
			ram_uart_up_wr_en <= 1;
			ram_uart_up_wr_we <= 1;
		end
		else begin
			ram_uart_up_wr_en <= 0;
			ram_uart_up_wr_we <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_uart_up_wr_addr <= 0;
		end
		else if(ram_uart_up_clr_l2h)begin
			ram_uart_up_wr_addr <= 0;
		end
		else if(rx_data_vld)begin
			ram_uart_up_wr_addr <= ram_uart_up_wr_addr + 1'b1;
		end
	end
	
	always @ (*)begin
		ram_uart_up_len = ram_uart_up_wr_addr;
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_uart_up_wr_data <= 0;
		end
		else begin
			ram_uart_up_wr_data <= rx_data;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			start_cnt_rx_time <= 0;
		end
		else if(rx_data_vld)begin
			start_cnt_rx_time <= 1;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_rx_time <= 0;
		end
		else if(end_cnt_rx_time)begin
			cnt_rx_time <= 0;
		end
		else if(add_cnt_rx_time)begin
			if(keep_cnt_rx_time)
				cnt_rx_time <= cnt_rx_time;
			else
				cnt_rx_time <= cnt_rx_time + 1'b1;
		end
	end
	
	assign add_cnt_rx_time = start_cnt_rx_time && rx_data_vld == 0;
	assign end_cnt_rx_time = rx_data_vld == 1;
	// assign keep_cnt_rx_time = add_cnt_rx_time && cnt_rx_time == 125_000-1;//1ms
	assign keep_cnt_rx_time = add_cnt_rx_time && cnt_rx_time == 250_000-1;//2ms
	// assign keep_cnt_rx_time = add_cnt_rx_time && cnt_rx_time == 1_250_000-1;//10ms
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			keep_cnt_rx_time_ff0 <= 0;
			keep_cnt_rx_time_ff1 <= 0;
		end
		else begin
			keep_cnt_rx_time_ff0 <= keep_cnt_rx_time;
			keep_cnt_rx_time_ff1 <= keep_cnt_rx_time_ff0;
		end
	end
	
	assign keep_cnt_rx_time_l2h = keep_cnt_rx_time_ff1 == 0 && keep_cnt_rx_time_ff0 == 1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			rx_data_2byte <= 0;
			rx_data_1byte <= 0;
		end
		else if(rx_data_vld)begin
			rx_data_2byte <= {rx_data_2byte[7:0],rx_data};
			rx_data_1byte <= rx_data;
		end
	end
	
	assign flag_0x0d0a = (rx_data_vld && rx_data_2byte == 16'h0d0a) ? 1'b1 : 1'b0;
	assign flag_0x00   = (rx_data_vld && rx_data_1byte == 8'h00 ) ? 1'b1 : 1'b0;

	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_uart_up_flag <= 0;
		end
		// else if(keep_cnt_rx_time_l2h || flag_0x0d0a || flag_0x00)begin
		else if(keep_cnt_rx_time_l2h)begin
			ram_uart_up_flag <= 1;
		end
		else if(ram_uart_up_clr_l2h)begin
			ram_uart_up_flag <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_uart_up_clr_ff0 <= 0;
			ram_uart_up_clr_ff1 <= 0;
			ram_uart_up_clr_ff2 <= 0;
		end
		else begin
			ram_uart_up_clr_ff0 <= ram_uart_up_clr;
			ram_uart_up_clr_ff1 <= ram_uart_up_clr_ff0;
			ram_uart_up_clr_ff2 <= ram_uart_up_clr_ff1;
		end
	end
	
	assign ram_uart_up_clr_l2h = ram_uart_up_clr_ff2 == 0 && ram_uart_up_clr_ff1 == 1;
	
	
///////////////////////////////////////////////////////////////////////////////////////	
	reg       tx_data_vld;
	reg [7:0] tx_data;
	wire      rdy;
	reg [7:0] cnt_uart_tx;
	wire      add_cnt_uart_tx;
	wire      end_cnt_uart_tx;
	reg       ram_uart_down_start_ff0;
	reg       ram_uart_down_start_ff1;
	reg       ram_uart_down_start_ff2;
	wire      ram_uart_down_start_l2h;
	reg [7:0] uart_tx_len;
	reg [3:0] state;
	reg [3:0] cnt_completed;
    reg       flag_cnt_uart_tx;
	uart_tx u_uart_tx(
		.clk_125m	(clk_125m	   ),
		.rst_n   	(rst_n   	   ),
		.sel	  	(4'd5	  	   ),
		.odd_even	(4'd0		   ),
		.din     	(tx_data       ),
		.din_vld 	(tx_data_vld   ),
		.dout    	(uart_tx   	   ),
		.rdy     	(rdy     	   )
	);
    
    always @ (*)begin
		ram_uart_down_rd_en = add_cnt_uart_tx;
		ram_uart_down_rd_we = 0;
        ram_uart_down_rd_addr = cnt_uart_tx;
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			tx_data_vld <= 0;
		end
		else if(add_cnt_uart_tx)begin
			tx_data_vld <= 1;
		end
		else begin
			tx_data_vld <= 0;
		end
	end
    
    always @ (*)begin
		tx_data = ram_uart_down_rd_data;
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_uart_tx <= 0;
		end
		else if(add_cnt_uart_tx)begin
			if(end_cnt_uart_tx)
				cnt_uart_tx <= 0;
			else
				cnt_uart_tx <= cnt_uart_tx + 1'b1;
		end
	end
	
	assign add_cnt_uart_tx = flag_cnt_uart_tx && rdy == 1;
	assign end_cnt_uart_tx = add_cnt_uart_tx && cnt_uart_tx == uart_tx_len-1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_uart_down_start_ff0 <= 0;
			ram_uart_down_start_ff1 <= 0;
			ram_uart_down_start_ff2 <= 0;
		end
		else begin
			ram_uart_down_start_ff0 <= ram_uart_down_start;
			ram_uart_down_start_ff1 <= ram_uart_down_start_ff0;
			ram_uart_down_start_ff2 <= ram_uart_down_start_ff1;
		end
	end
	
	assign ram_uart_down_start_l2h = ram_uart_down_start_ff2 == 0 && ram_uart_down_start_ff1 == 1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			uart_tx_len <= 0;
		end
		else if(ram_uart_down_start_l2h)begin
			uart_tx_len <= ram_uart_down_len;
		end
	end
    
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			flag_cnt_uart_tx <= 0;
		end
		else if(ram_uart_down_start_l2h)begin
			flag_cnt_uart_tx <= 1;
		end
		else if(end_cnt_uart_tx)begin
			flag_cnt_uart_tx <= 0;
		end
	end
    
    /*	//测试
	reg [3:0] step;
	reg [27:0] cnt;
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			step <= 0;
			cnt <= 0;
			tx_data <= 0;
			tx_data_vld <= 0;
		end
		else begin
			case(step)
				0:begin
					if(cnt == 62_500_000-1)begin
						step <= 1;
						cnt <= 0;
						tx_data <= 8'h0d;
						tx_data_vld <= 1;
					end
					else begin
						step <= 0;
						cnt <= cnt + 1'b1;
						tx_data <= 0;
						tx_data_vld <= 0;
					end
				end
				1:begin
					step <= 2;
					cnt <= 0;
					tx_data <= 0;
					tx_data_vld <= 0;
				end
				2:begin
					if(rdy == 1)begin
						step <= 0;
						cnt <= 0;
						tx_data <= 8'h0a;
						tx_data_vld <= 1;
					end
				end
			endcase
		end
	end*/
	
endmodule
