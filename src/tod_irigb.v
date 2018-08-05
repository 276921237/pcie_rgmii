module tod_irigb(
	input             clk_125m     ,
	input             rst_n        ,
	input             din_vld      ,
	input      [15:0] tod_week     ,
	input      [23:0] tod_sec      ,
	input      [7:0]  leap         ,
	input      [4:0]  time_skew    ,
	output reg [7:0]  year_bcd     ,
	output reg [7:0]  month_bcd    ,
	output reg [7:0]  day_bcd      ,
	output reg [7:0]  hour_bcd     ,
	output reg [7:0]  min_bcd      ,
	output reg [7:0]  sec_bcd      ,
	output reg [11:0] day_bcd_irigb
);
    reg [15:0] week_tmp;
	reg [23:0] week_sec_tmp;
	reg [15:0] time_skew_tmp;
	reg        time_skew_sign;
	reg [15:0] tod_week_shift;
	reg [23:0] tod_sec_shift;
	reg [15:0] week_leap;
	reg [23:0] week_sec_leap;
	
	reg [15:0] day_all_1;
	wire [15:0] day_all_2;
	reg [15:0] day_all;
	wire [16:0] sec_all;
	reg [7:0]  year_tmp;
	reg [15:0] day_tmp;
	wire [8:0] day_tmp2;
	wire [11:0] sec_hour;
	wire [7:0]  hour_tmp;
	wire [7:0]  min_tmp;
	wire [7:0]  sec_tmp;
	reg [8:0]  day;
	reg [7:0]  month;
	reg [3:0]  day_tmp_b;
	reg [7:0]  day_tmp_sg;
	wire [7:0] quotient;
	wire [3:0] remain;
	reg [7:0]  bcd;
	reg [13:0] cnt_100us;
	//----------补偿1s----------
    always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			week_sec_tmp <= 0;
            week_tmp <= 0;
		end
		else if(tod_sec == 604800-1)begin
			week_sec_tmp <= 0;
            week_tmp <= tod_week + 1'b1;
        end
        else begin
			week_sec_tmp <= tod_sec + 1'b1;
            week_tmp <= tod_week;
		end
	end

	//----------时区----------
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			time_skew_tmp <= 0;
			time_skew_sign <= 0;
		end
		else begin
			time_skew_tmp <= time_skew[3:0] * 12'd3600;
			time_skew_sign <= time_skew[4];
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			tod_sec_shift <= 0;
			tod_week_shift <= 0;
		end
		else if(time_skew_sign == 0)begin
			if(week_sec_tmp + time_skew_tmp >= 604800)begin
				tod_sec_shift <= week_sec_tmp + time_skew_tmp - 20'd604800;
				tod_week_shift <= week_tmp + 1'b1;
			end
			else begin
				tod_sec_shift <= week_sec_tmp + time_skew_tmp;
				tod_week_shift <= week_tmp;
			end
		end
		else begin
			if(week_sec_tmp < time_skew_tmp)begin
				tod_sec_shift <= (week_sec_tmp + 20'd604800) - time_skew_tmp;
				tod_week_shift <= week_tmp - 1'b1;
			end
			else begin
				tod_sec_shift <= week_sec_tmp - time_skew_tmp;
				tod_week_shift <= week_tmp;
			end
		end
	end
	
	//----------闰秒----------
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			week_sec_leap <= 0;
			week_leap <= 0;
		end
		else if(tod_sec_shift < leap)begin
			week_sec_leap <= tod_sec_shift + 20'd604800 - leap;
			week_leap <= tod_week_shift - 1'b1;
		end
		else begin
			week_sec_leap <= tod_sec_shift - leap;
			week_leap <= tod_week_shift;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			day_all_1 <= 0;
		end
		else begin
			day_all_1 <= (week_leap - 16'h078a) * 4'd7;
		end
	end
	
	div_86400 u_div_86400(
		.clk	 	(clk_125m		),
		.dividend	(week_sec_leap	),
		.divisor 	(17'd86400	    ),
		.quotient	(day_all_2		),
		.fractional (sec_all		)
	);  
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			day_all <= 0;
		end
		else begin
			day_all <= day_all_1 + day_all_2 + 1'b1;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			day_tmp <= 0;
			year_tmp <= 0;
		end
		else if(day_all <= 365)begin
			day_tmp <= day_all;
			year_tmp <= 8'd17;
		end
		else if(day_all <= 730)begin
			day_tmp <= day_all - 16'd365;
			year_tmp <= 8'd18;
		end
		else if(day_all <= 1095)begin
			day_tmp <= day_all - 16'd730;
			year_tmp <= 8'd19;
		end
		else if(day_all <= 1461)begin
			day_tmp <= day_all - 16'd1095;
			year_tmp <= 8'd20;
		end
		else if(day_all <= 1826)begin
			day_tmp <= day_all - 16'd1461;
			year_tmp <= 8'd21;
		end
		else if(day_all <= 2191)begin
			day_tmp <= day_all - 16'd1826;
			year_tmp <= 8'd22;
		end
		else if(day_all <= 2556)begin
			day_tmp <= day_all - 16'd2191;
			year_tmp <= 8'd23;
		end
		else if(day_all <= 2922)begin
			day_tmp <= day_all - 16'd2556;
			year_tmp <= 8'd24;
		end
		else if(day_all <= 3287)begin
			day_tmp <= day_all - 16'd2922;
			year_tmp <= 8'd25;
		end
		else if(day_all <= 3652)begin
			day_tmp <= day_all - 16'd3287;
			year_tmp <= 8'd26;
		end
		else if(day_all <= 4017)begin
			day_tmp <= day_all - 16'd3652;
			year_tmp <= 8'd27;
		end
		else if(day_all <= 4383)begin
			day_tmp <= day_all - 16'd4017;
			year_tmp <= 8'd28;
		end
		else if(day_all <= 4748)begin
			day_tmp <= day_all - 16'd4383;
			year_tmp <= 8'd29;
		end
		else if(day_all <= 5113)begin
			day_tmp <= day_all - 16'd4748;
			year_tmp <= 8'd30;
		end
		else if(day_all <= 5478)begin
			day_tmp <= day_all - 16'd5113;
			year_tmp <= 8'd31;
		end
		else if(day_all <= 5844)begin
			day_tmp <= day_all - 16'd5478;
			year_tmp <= 8'd32;
		end
		else if(day_all <= 6209)begin
			day_tmp <= day_all - 16'd5844;
			year_tmp <= 8'd33;
		end
		else if(day_all <= 6574)begin
			day_tmp <= day_all - 16'd6209;
			year_tmp <= 8'd34;
		end
		else if(day_all <= 6939)begin
			day_tmp <= day_all - 16'd6574;
			year_tmp <= 8'd35;
		end
		else if(day_all <= 7305)begin
			day_tmp <= day_all - 16'd6939;
			year_tmp <= 8'd36;
		end
		else if(day_all <= 7670)begin
			day_tmp <= day_all - 16'd7305;
			year_tmp <= 8'd37;
		end
	end
	
	div_3600 u_div_3600(
		.clk	 	(clk_125m		),
		.dividend	(sec_all		),
		.divisor	(12'd3600		),
		.quotient	(hour_tmp		),
		.fractional	(sec_hour		)
	);
	
	div_60 u_div_60(
		.clk	 	(clk_125m		),
		.dividend	(sec_hour		),
		.divisor	(6'd60		    ),
		.quotient	(min_tmp		),
		.fractional	(sec_tmp		)
	);
	
    assign day_tmp2 = day_tmp[8:0];
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			month <= 0;
			day <= 0;
		end
		else if(year_tmp[1:0] == 0)begin
			if(day_tmp2 <= 31)begin
				month <= 8'd1;
				day <= day_tmp2;
			end
			else if(day_tmp2 <= 60)begin
				month <= 8'd2;
				day <= day_tmp2 - 9'd31;
			end
			else if(day_tmp2 <= 91)begin
				month <= 8'd3;
				day <= day_tmp2 - 9'd60;
			end
			else if(day_tmp2 <= 121)begin
				month <= 8'd4;
				day <= day_tmp2 - 9'd91;
			end
			else if(day_tmp2 <= 152)begin
				month <= 8'd5;
				day <= day_tmp2 - 9'd121;
			end
			else if(day_tmp2 <= 182)begin
				month <= 8'd6;
				day <= day_tmp2 - 9'd152;
			end
			else if(day_tmp2 <= 213)begin
				month <= 8'd7;
				day <= day_tmp2 - 9'd182;
			end
			else if(day_tmp2 <= 244)begin
				month <= 8'd8;
				day <= day_tmp2 - 9'd213;
			end
			else if(day_tmp2 <= 274)begin
				month <= 8'd9;
				day <= day_tmp2 - 9'd244;
			end
			else if(day_tmp2 <= 305)begin
				month <= 8'd10;
				day <= day_tmp2 - 9'd274;
			end
			else if(day_tmp2 <= 335)begin
				month <= 8'd11;
				day <= day_tmp2 - 9'd305;
			end
			else if(day_tmp2 <= 366)begin
				month <= 8'd12;
				day <= day_tmp2 - 9'd335;
			end
		end
		else begin
			if(day_tmp2 <= 31)begin
				month <= 8'h1;
				day <= day_tmp2;
			end
			else if(day_tmp2 <= 59)begin
				month <= 8'h2;
				day <= day_tmp2 - 9'd31;
			end
			else if(day_tmp2 <= 90)begin
				month <= 8'h3;
				day <= day_tmp2 - 9'd59;
			end
			else if(day_tmp2 <= 120)begin
				month <= 8'h4;
				day <= day_tmp2 - 9'd90;
			end
			else if(day_tmp2 <= 151)begin
				month <= 8'h5;
				day <= day_tmp2 - 9'd120;
			end
			else if(day_tmp2 <= 181)begin
				month <= 8'h6;
				day <= day_tmp2 - 9'd151;
			end
			else if(day_tmp2 <= 212)begin
				month <= 8'h7;
				day <= day_tmp2 - 9'd181;
			end
			else if(day_tmp2 <= 243)begin
				month <= 8'h8;
				day <= day_tmp2 - 9'd212;
			end
			else if(day_tmp2 <= 273)begin
				month <= 8'h9;
				day <= day_tmp2 - 9'd243;
			end
			else if(day_tmp2 <= 304)begin
				month <= 8'h10;
				day <= day_tmp2 - 9'd273;
			end
			else if(day_tmp2 <= 334)begin
				month <= 8'h11;
				day <= day_tmp2 - 9'd304;
			end
			else if(day_tmp2 <= 365)begin
				month <= 8'h12;
				day <= day_tmp2 - 9'd334;
			end
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			day_tmp_b <= 0;
			day_tmp_sg <= 0;
		end
		else if(day_tmp > 299)begin
			day_tmp_sg <= day_tmp - 9'd300;
			day_tmp_b <= 4'd3;
		end
		else if(day_tmp > 199)begin
			day_tmp_sg <= day_tmp - 9'd200;
			day_tmp_b <= 4'd2;
		end
		else if(day_tmp > 99)begin
			day_tmp_sg <= day_tmp - 9'd100;
			day_tmp_b <= 4'd1;
		end
		else begin
			day_tmp_sg <= day_tmp;
			day_tmp_b <= 4'd0;
		end
	end
	
	div_10 u_div_10(
		.clk	 	(clk_125m		),
		.dividend	(bcd			),
		.divisor	(4'd10			),
		.quotient	(quotient		),
		.fractional	(remain			)
	);

	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_100us <= 0;
		end
		else if(din_vld)begin
			cnt_100us <= 0;
		end
		else if(cnt_100us == 12_500-1)begin
			cnt_100us <= cnt_100us;
		end
		else begin
			cnt_100us <= cnt_100us + 1'b1;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			bcd <= 0;
		end
		else if(cnt_100us == 4000-1)begin
			bcd <= year_tmp;
		end
		else if(cnt_100us == 5000-1)begin
			bcd <= day[7:0];
		end
		else if(cnt_100us == 6000-1)begin
			bcd <= hour_tmp;
		end
		else if(cnt_100us == 7000-1)begin
			bcd <= min_tmp;
		end
		else if(cnt_100us == 8000-1)begin
			bcd <= sec_tmp;
		end
		else if(cnt_100us == 9000-1)begin
			bcd <= day_tmp_sg;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			year_bcd <= 0;
		end
		else if(cnt_100us == 4500-1)begin
			year_bcd[7:4] <= quotient[3:0];
			year_bcd[3:0] <= remain;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			month_bcd <= 0;
		end
		else begin
			month_bcd <= month;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			day_bcd <= 0;
		end
		else if(cnt_100us == 5500-1)begin
			day_bcd[7:4] <= quotient[3:0];
			day_bcd[3:0] <= remain;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			hour_bcd <= 0;
		end
		else if(cnt_100us == 6500-1)begin
			hour_bcd[7:4] <= quotient[3:0];
			hour_bcd[3:0] <= remain;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			min_bcd <= 0;
		end
		else if(cnt_100us == 7500-1)begin
			min_bcd[7:4] <= quotient[3:0];
			min_bcd[3:0] <= remain;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			sec_bcd <= 0;
		end
		else if(cnt_100us == 8500-1)begin
			sec_bcd[7:4] <= quotient[3:0];
			sec_bcd[3:0] <= remain;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			day_bcd_irigb <= 0;
		end
		else if(cnt_100us == 9500-1)begin
			day_bcd_irigb[11:8] <= day_tmp_b;
			day_bcd_irigb[7:4] <= quotient[3:0];
			day_bcd_irigb[3:0] <= remain;
		end
	end
	
endmodule
