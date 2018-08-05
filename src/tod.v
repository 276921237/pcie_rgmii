module tod(
	input             clk_125m      	,
	input             rst_n         	,
	input             pps_in        	,
	input             tod_in        	,
	input 			  timer_stop		,
	
	output reg [15:0] ts_week	       	,
	output reg [31:0] ts_week_sec      	,
	output reg [31:0] ts_nano_sec      	,
	output reg [7:0]  ts_leap_sec      	,
	output reg [7:0]  ts_pps_state     	,
	output reg [7:0]  ts_timesrc_type  	,
	output reg [7:0]  ts_pps_precision 	,
	output reg [7:0]  ts_checksum		,

    input             uart_ustod_latch_flag,
    output reg [31:0] bar_year_month_day,
    output reg [31:0] bar_hour_min_sec  ,
    output reg [31:0] bar_nano_sec      ,
    
	output reg 		  ram_tod_up_wr_en	,
	output reg 		  ram_tod_up_wr_we	,
	output reg [8:0]  ram_tod_up_wr_addr,
	output reg [7:0]  ram_tod_up_wr_data,
	output reg [8:0]  ram_tod_up_len	,
	output reg        ram_tod_up_flag	,
	input             ram_tod_up_clr    
);

	wire 	    pps_out;
	wire [7:0]  rx_data;
	wire        rx_data_vld;
	wire [15:0] week;
	wire [31:0] week_sec;
	wire [7:0]  leap_sec;
	wire [7:0]  pps_state;
	wire [7:0]  timesrc_type;
	wire [7:0]  pps_precision;
	reg         pps_ff0;
	reg         pps_ff1;
	wire        pps_l2h;
	reg [31:0]  nano_sec;
	reg [8:0]   checksum0;
	reg [8:0]   checksum1;
	reg [8:0]   checksum2;
	reg [8:0]   checksum3;
	reg [8:0]   checksum4;
	reg [8:0]   checksum5;
	reg [8:0]   checksum6;
	reg [9:0]   checksum7;
	reg [9:0]   checksum8;
	reg [9:0]   checksum9;
	reg [8:0]   checksum10;
	reg [10:0]  checksum11;
	reg [10:0]  checksum12;
	reg [11:0]  checksum13;
	
	pps_shift u_pps_shift(
		.clk_125m		(clk_125m		),
		.rst_n			(rst_n			),
		.pps_in			(pps_in			),
		.pps_out		(pps_out		)
	);
	
	uart_rx u_uart_rx(
		.clk_125m		(clk_125m		),
		.rst_n   		(rst_n   		),
		.sel 	  		(4'd2 	  		),
		.odd_even		(4'd0			),
		.din     		(tod_in    		),
		.dout    		(rx_data		),
		.dout_vld		(rx_data_vld	)
	);
	
	tod_cm u_tod_cm(
		.clk_125m		(clk_125m		),
		.rst_n			(rst_n			),
		.pps			(pps_out		),
		.din			(rx_data		),
		.din_vld		(rx_data_vld	),
        
		.week	        (week	        ),
		.week_sec      	(week_sec      	),
		.leap_sec      	(leap_sec      	),
		.pps_state     	(pps_state     	),
		.timesrc_type  	(timesrc_type  	),
		.pps_precision 	(pps_precision 	),

        .year           (year           ),
        .month          (month          ),
        .day            (day            ),
        .hour           (hour           ),
        .min            (min            ),
        .sec            (sec            )
	);
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			pps_ff0 <= 0;
			pps_ff1 <= 0;
		end
		else begin
			pps_ff0 <= pps_out;
			pps_ff1 <= pps_ff0;
		end
	end
	
	assign pps_l2h = pps_ff1 == 0 && pps_ff0 == 1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			nano_sec <= 0;
		end
		else if(pps_l2h)begin
			nano_sec <= 0;
		end
		else if(nano_sec == 999_999_992)begin
			nano_sec <= nano_sec;
		end
		else begin
			nano_sec <= nano_sec + 4'd8;
		end
	end

	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ts_week	      	 <= 0;
			ts_week_sec      <= 0;
			ts_nano_sec      <= 0;
			ts_leap_sec      <= 0;
			ts_pps_state     <= 0;
			ts_timesrc_type  <= 0;
			ts_pps_precision <= 0;			
		end
		else if(timer_stop)begin
			ts_week	      	 <= week;
			ts_week_sec      <= week_sec;
			ts_nano_sec      <= nano_sec;
			ts_leap_sec      <= leap_sec;
			ts_pps_state     <= pps_state;
			ts_timesrc_type  <= timesrc_type;
			ts_pps_precision <= pps_precision;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			checksum0 <= 0;
			checksum1 <= 0;
			checksum2 <= 0;
			checksum3 <= 0;
			checksum4 <= 0;
			checksum5 <= 0;
			checksum6 <= 0;
		end
		else begin
			checksum0 <= ts_week[15:8] + ts_week[7:0];
			checksum1 <= ts_week_sec[31:24] + ts_week_sec[23:16];
			checksum2 <= ts_week_sec[15:8] + ts_week_sec[7:0];
			checksum3 <= ts_nano_sec[31:24] + ts_nano_sec[23:16];
			checksum4 <= ts_nano_sec[15:8] + ts_nano_sec[7:0];
			checksum5 <= ts_leap_sec + ts_pps_state;
			checksum6 <= ts_timesrc_type + ts_pps_precision;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			checksum7 <= 0;
			checksum8 <= 0;
			checksum9 <= 0;
			checksum10 <= 0;
		end
		else begin
			checksum7 <= checksum0 + checksum1;
			checksum8 <= checksum2 + checksum3;
			checksum9 <= checksum4 + checksum5;
			checksum10 <= checksum6;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			checksum11 <= 0;
			checksum12 <= 0;
		end
		else begin
			checksum11 <= checksum7 + checksum8;
			checksum12 <= checksum9 + checksum10;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			checksum13 <= 0;
		end
		else begin
			checksum13 <= checksum11 + checksum12;
		end
	end
	
	always @ (*)begin
		ts_checksum = checksum13[7:0];
	end
//////////////////////////////////////////////////////////////////////////////////////////
    reg uart_ustod_latch_ff0;
    reg uart_ustod_latch_ff1;
    reg uart_ustod_latch_ff2;
    wire uart_ustod_latch_l2h;
    reg [15:0] bar_year     ;
	reg [7:0]  bar_month    ;
	reg [7:0]  bar_day      ;
	reg [7:0]  bar_hour     ;
	reg [7:0]  bar_min      ;
	reg [7:0]  bar_sec      ;
    always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            uart_ustod_latch_ff0 <= 0;
            uart_ustod_latch_ff1 <= 0;
            uart_ustod_latch_ff2 <= 0;
        end
        else begin
            uart_ustod_latch_ff0 <= uart_ustod_latch_flag;
            uart_ustod_latch_ff1 <= uart_ustod_latch_ff0;
            uart_ustod_latch_ff2 <= uart_ustod_latch_ff1;
        end
    end
    
    assign uart_ustod_latch_l2h = uart_ustod_latch_ff2 == 0 && uart_ustod_latch_ff1 == 1;
    
    always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            bar_year    <= 0;
            bar_month   <= 0;
            bar_day     <= 0;
            bar_hour    <= 0;
            bar_min     <= 0;
            bar_sec     <= 0;
            bar_nano_sec<= 0;
        end
        else if(uart_ustod_latch_l2h)begin
            bar_year    <= year;
            bar_month   <= month;
            bar_day     <= day;
            bar_hour    <= hour;
            bar_min     <= min;
            bar_sec     <= sec;
            bar_nano_sec<= nano_sec;
        end
    end
    
    always @ (*)begin
        bar_year_month_day = {bar_year,bar_month,bar_day};
        bar_hour_min_sec = {8'h00,bar_hour,bar_min,bar_sec};
    end
//////////////////////////////////////////////////////////////////////////////////////////
	reg        start_cnt_rx_time;
	reg [20:0] cnt_rx_time;
	wire       add_cnt_rx_time;
	wire       end_cnt_rx_time;
	wire       keep_cnt_rx_time;
	reg        keep_cnt_rx_time_ff0;
	reg        keep_cnt_rx_time_ff1;
	wire       keep_cnt_rx_time_l2h;
	reg        ram_tod_up_clr_ff0;
	reg        ram_tod_up_clr_ff1;
	reg        ram_tod_up_clr_ff2;
	wire       ram_tod_up_clr_l2h;
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_tod_up_wr_en <= 0;
			ram_tod_up_wr_we <= 0;
		end
		else if(rx_data_vld)begin
			ram_tod_up_wr_en <= 1;
			ram_tod_up_wr_we <= 1;
		end
		else begin
			ram_tod_up_wr_en <= 0;
			ram_tod_up_wr_we <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_tod_up_wr_addr <= 0;
		end
		else if(ram_tod_up_clr_l2h)begin
			ram_tod_up_wr_addr <= 0;
		end
		else if(rx_data_vld)begin
			ram_tod_up_wr_addr <= ram_tod_up_wr_addr + 1'b1;
		end
	end
	
	always @ (*)begin
		ram_tod_up_len = ram_tod_up_wr_addr;
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_tod_up_wr_data <= 0;
		end
		else begin
			ram_tod_up_wr_data <= rx_data;
		end
	end

//10ms超时检测
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
	assign keep_cnt_rx_time = add_cnt_rx_time && cnt_rx_time == 1_250_000-1;
	
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
			ram_tod_up_flag <= 0;
		end
		else if(keep_cnt_rx_time_l2h)begin
			ram_tod_up_flag <= 1;
		end
		else if(ram_tod_up_clr_l2h)begin
			ram_tod_up_flag <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			ram_tod_up_clr_ff0 <= 0;
			ram_tod_up_clr_ff1 <= 0;
			ram_tod_up_clr_ff2 <= 0;
		end
		else begin
			ram_tod_up_clr_ff0 <= ram_tod_up_clr;
			ram_tod_up_clr_ff1 <= ram_tod_up_clr_ff0;
			ram_tod_up_clr_ff2 <= ram_tod_up_clr_ff1;
		end
	end
	
	assign ram_tod_up_clr_l2h = ram_tod_up_clr_ff2 == 0 && ram_tod_up_clr_ff1 == 1;
	
endmodule
