module uart_rx(
    input             clk_125m,
    input             rst_n   ,
	input      [3:0]  sel 	  ,
	input      [3:0]  odd_even,
    input             din     ,
    output reg [7:0]  dout    ,
    output reg        dout_vld
);

    reg [16:0] bps;
	reg [3:0]  bit_num;
	reg [19:0] cnt_bps;
	wire       add_bps;
	wire       end_bps;
	wire       bps_2;
	
	reg [3:0] cnt_bit;
	wire      add_cnt_bit;
	wire      end_cnt_bit;
	
	reg		 flag_bps_count;
	reg		 din_ff0;
	reg		 din_ff1;
	reg		 din_ff2;
	reg		 din_ff3;
	wire	 h2l;
	
    wire     get_data;
	reg      check;
	wire     get_check;
	reg      get_check_ff0;
	reg      flag_true;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			bps <= 13_020;
		end
		else begin
			case(sel)
				0:bps <= 104_166;//1200
				1:bps <= 52_083;//2400
				2:bps <= 26_041;//4800
				3:bps <= 13_020;//9600
				4:bps <= 6_510;//19200
				5:bps <= 1_085;//115200
				default:bps <= 13_020;
			endcase
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			bit_num <= 4'hf;
		end
		else begin
			case(odd_even)
				0:bit_num <= 9;
				1:bit_num <= 10;
				2:bit_num <= 10;
				default:bit_num <= 9;
			endcase
		end
	end
	
    always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            cnt_bps <= 0;
        end
        else if(add_bps)begin
            if(end_bps)begin
                cnt_bps <= 0;
            end
            else begin
                cnt_bps <= cnt_bps + 1'b1;
            end
        end
    end

    assign add_bps = flag_bps_count;
    assign end_bps = add_bps && cnt_bps == bps-1;
    assign bps_2   = add_bps && cnt_bps == bps/2-1;
	
	always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            cnt_bit <= 0;
        end
        else if(add_cnt_bit)begin
            if(end_cnt_bit)begin
                cnt_bit <= 0;
            end
            else begin
                cnt_bit <= cnt_bit + 1'b1;
            end
        end
    end

    assign add_cnt_bit = end_bps;
    assign end_cnt_bit = add_cnt_bit && cnt_bit == bit_num-1;

    always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            din_ff0 <= 0;
            din_ff1 <= 0;
            din_ff2 <= 0;
            din_ff3 <= 0;
        end
        else begin
            din_ff0 <= din;
            din_ff1 <= din_ff0;
            din_ff2 <= din_ff1;
            din_ff3 <= din_ff2;
        end
    end

    assign h2l = din_ff3 == 1 && din_ff2 == 0;

    always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            flag_bps_count <= 0;
        end
        else if(h2l)begin
            flag_bps_count <= 1;
        end
        else if(end_cnt_bit)begin
            flag_bps_count <= 0;
        end
    end

    always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            dout <= 1;
        end
        else if(get_data)begin
            dout[cnt_bit-1] <= din_ff3;
        end
    end

    assign get_data = bps_2 && cnt_bit >= 1 && cnt_bit < 9;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			check <= 0;
		end
		else if(get_check)begin
			check <= din_ff3;
		end
	end
	
	assign get_check = bps_2 && cnt_bit == 9;
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			get_check_ff0 <= 0;
		end
		else begin
			get_check_ff0 <= get_check;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			flag_true <= 0;
		end
		else if(odd_even == 0)begin
			flag_true <= 1;
		end
		else begin
			if(get_check_ff0)begin
				if(odd_even == 4'd1)
					flag_true <= (^dout) ^ check;
				else if(odd_even == 4'd2)
					flag_true <= ~((^dout) ^ check);
				else
					flag_true <= 1;
			end
		end
	end

    always @ (posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            dout_vld <= 0;
        end
        else if(flag_true && end_cnt_bit)begin
            dout_vld <= 1;
        end
        else begin
            dout_vld <= 0;
        end
    end

endmodule
