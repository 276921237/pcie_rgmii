module pps_shift(
	input				clk_125m	,
	input				rst_n		,
	input				pps_in		,
	output reg			pps_out		
);

	reg			pps_in_ff0	;
	reg			pps_in_ff1	;
	reg			pps_in_ff2	;
	reg			pps_in_ff3	;
	reg	[27:0]	cnt_shift	;
	
	wire		pps_l2h		;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			pps_in_ff0 <= 0;
			pps_in_ff1 <= 0;
			pps_in_ff2 <= 0;
			pps_in_ff3 <= 0;
		end
		else begin
			pps_in_ff0 <= pps_in;
			pps_in_ff1 <= pps_in_ff0;
			pps_in_ff2 <= pps_in_ff1;
			pps_in_ff3 <= pps_in_ff2;
		end
	end

	assign pps_l2h = pps_in_ff3 == 0 && pps_in_ff2 == 1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt_shift <= 0;
		end
		else if(pps_l2h)begin
			cnt_shift <= 27'd20;
		end
		else if(cnt_shift == 27'd124_999_999)begin
			cnt_shift <= 27'd0;
		end
		else begin
			cnt_shift <= cnt_shift + 1'd1;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			pps_out <= 0;
		end
		else if(cnt_shift < 27'd62_500_000)begin
			pps_out <= 1;
		end
		else begin
			pps_out <= 0;
		end
	end
	
endmodule
