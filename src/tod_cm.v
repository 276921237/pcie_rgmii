module tod_cm(
	input	  		  clk_125m		,
	input	  		  rst_n			,
	input             pps			,
	input	   [7:0]  din			,
	input	  		  din_vld		,
	
	output reg [15:0] week	        ,
	output reg [31:0] week_sec      ,
	output reg [7:0]  leap_sec      ,
	output reg [7:0]  pps_state     ,
	output reg [7:0]  timesrc_type  ,
	output reg [7:0]  pps_precision ,
    
    output reg [15:0] year          ,
	output reg [7:0]  month         ,
	output reg [7:0]  day           ,
	output reg [7:0]  hour          ,
	output reg [7:0]  min           ,
	output reg [7:0]  sec           
);
	
	reg	[7:0]  state_c;
	reg	[7:0]  state_n;
	reg        pps_ff0;
	reg        pps_ff1;
	wire       pps_l2h;
	reg	[7:0]  cnt_tybe;
	wire	   add_cnt_tybe;
	wire	   end_cnt_tybe;
	
	reg [15:0] week_tmp;
	reg [31:0] week_sec_tmp;
	reg [7:0]  leap_sec_tmp;
	reg [7:0]  pps_state_tmp;
	reg [7:0]  timesrc_type_tmp;
	reg [7:0]  pps_precision_tmp;

	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			state_c <= 8'd0;
		end
		else begin
			state_c <= state_n;
		end
	end

	always @ (*)begin
		case(state_c)
			8'd0:begin
				if(din_vld && din == 8'h43)
					state_n = 8'd1;
				else
					state_n = 8'd0;
			end
			8'd1:begin
				if(din_vld && din == 8'h4d)
					state_n = 8'd2;
				else if(din_vld)
					state_n = 8'd0;
				else
					state_n = state_c;
			end
			8'd2:begin
				if(din_vld && din == 8'h01)
					state_n = 8'd3;
				else if(din_vld)
					state_n = 8'd0;
				else
					state_n = state_c;
			end
			8'd3:begin
				if(din_vld && din == 8'h20)
					state_n = 8'd4;
				else if(din_vld && din == 8'h03)
					state_n = 8'd5;
				else if(din_vld)
					state_n = 8'd0;
				else
					state_n = state_c;
			end
			8'd4:begin//时间消息
				if(end_cnt_tybe)
					state_n = 8'd0;
				else
					state_n = state_c;
			end
			8'd5:begin//状态消息
				if(end_cnt_tybe)
					state_n = 8'd0;
				else
					state_n = state_c;
			end
			default:begin
				state_n = 8'd0;
			end
		endcase
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			pps_ff0 <= 0;
			pps_ff1 <= 0;
		end
		else begin
			pps_ff0 <= pps;
			pps_ff1 <= pps_ff0;
		end
	end
	
	assign pps_l2h = pps_ff1 == 0 && pps_ff0 == 1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_tybe <= 0;
		end
		else if(end_cnt_tybe)begin
			cnt_tybe <= 0;
		end
		else if(add_cnt_tybe)begin
			cnt_tybe <= cnt_tybe + 1'b1;
		end
	end
	
	assign add_cnt_tybe = (state_c == 8'd4 ||  state_c == 8'd5) && din_vld;
	assign end_cnt_tybe = add_cnt_tybe && cnt_tybe == 19-1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			week_sec_tmp <= 0;
		end
		else if(state_c == 8'd4)begin
			if(din_vld && cnt_tybe >= 2 && cnt_tybe < 6)begin
				week_sec_tmp <= {week_sec_tmp[23:0],din};
			end
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			week_tmp <= 0;
		end
		else if(state_c == 8'd4)begin
			if(din_vld && cnt_tybe >= 10 && cnt_tybe < 12)begin
				week_tmp <= {week_tmp[7:0],din};
			end
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			week_sec <= 0;
		end
		else if(pps_l2h)begin
			if(week_sec_tmp == 604800-1)
				week_sec <= 0;
			else
				week_sec <= week_sec_tmp + 1'b1;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			week <= 0;
		end
		else if(pps_l2h)begin
			if(week_sec_tmp == 604800-1)
				week <= week_tmp + 1'b1;
			else
				week <= week_tmp;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			leap_sec_tmp <= 0;
		end
		else if(state_c == 8'd4)begin
			if(din_vld && cnt_tybe == 12)begin
				leap_sec_tmp <= din;
			end
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			pps_state_tmp <= 0;
		end
		else if(state_c == 8'd4)begin
			if(din_vld && cnt_tybe == 13)begin
				pps_state_tmp <= din;
			end
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			pps_precision_tmp <= 0;
		end
		else if(state_c == 8'd4)begin
			if(din_vld && cnt_tybe == 14)begin
				pps_precision_tmp <= din;
			end
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			timesrc_type_tmp <= 0;
		end
		else if(state_c == 8'd5)begin
			if(din_vld && cnt_tybe == 2)begin
				timesrc_type_tmp <= din;
			end
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			leap_sec      <= 0;
			pps_state     <= 0;
			timesrc_type  <= 0;
			pps_precision <= 0;			
		end
		else if(pps_l2h)begin
			leap_sec      <= leap_sec_tmp;
			pps_state     <= pps_state_tmp;
			timesrc_type  <= timesrc_type_tmp;
			pps_precision <= pps_precision_tmp;	
		end
	end
    
//////////////////////////////////////////////////////////////////////////////////////////
	wire [7:0]  year_bcd ;
	wire [7:0]  month_bcd;
	wire [7:0]  day_bcd  ;
	wire [7:0]  hour_bcd ;
	wire [7:0]  min_bcd  ;
	wire [7:0]  sec_bcd  ;
    tod_irigb u_tod_irigb(
        .clk_125m       (clk_125m           ),
        .rst_n          (rst_n              ),
        .din_vld        (state_c == 8'd4 && end_cnt_tybe),
        .tod_week       (week_tmp           ),
        .tod_sec        (week_sec_tmp[23:0] ),
        .leap           (leap_sec_tmp       ),
        .time_skew      (5'd0               ),
        .year_bcd       (year_bcd           ),
        .month_bcd      (month_bcd          ),
        .day_bcd        (day_bcd            ),
        .hour_bcd       (hour_bcd           ),
        .min_bcd        (min_bcd            ),
        .sec_bcd        (sec_bcd            )
    );
	
    always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			year    <= 0;
			month   <= 0;
			day     <= 0;
			hour    <= 0;
			min     <= 0;
			sec     <= 0;
		end
		else if(pps_l2h)begin
			year    <= {8'h20,year_bcd};
			month   <= month_bcd;
			day     <= day_bcd;
			hour    <= hour_bcd;
			min     <= min_bcd;
			sec     <= sec_bcd;
		end
	end
    
endmodule
