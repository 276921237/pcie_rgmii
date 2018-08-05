module uart_tx(
    input             clk_125m,
    input             rst_n   ,
	input       [3:0] sel	  ,
	input       [3:0] odd_even,
	input       [7:0] din     ,
	input             din_vld ,

    output reg        dout    ,
    output reg        rdy     
);

	reg [16:0] bps;
	reg [3:0]  bit_num;
	reg [7:0]  din_reg;
    reg [19:0] cnt_bps;
    wire       add_bps;
    wire       end_bps;
    wire       bps_2;
	
    reg [3:0]  cnt_bit;
    wire       add_cnt_bit;
    wire       end_cnt_bit;
    reg        flag_bps_count;
	
	reg		   check;
	
    wire                out_data1;
    wire                out_data2;
    wire                out_data3;
    wire                out_data4;

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
				0:bit_num <= 10;
				1:bit_num <= 11;
				2:bit_num <= 11;
				default:bit_num <= 10;
			endcase
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			din_reg <= 0;
		end
		else if(din_vld)begin
			din_reg <= din;
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
            flag_bps_count <= 0;
        end
        else if(din_vld)begin
            flag_bps_count <= 1;
        end
        else if(end_cnt_bit)begin
            flag_bps_count <= 0;
        end
    end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			check <= 0;
		end
		else if(din_vld)begin
			if(odd_even == 4'd1)
				check <= ~(^din);
			else if(odd_even == 4'd2)
				check <= ^din;
			else
				check <= 1;
		end
	end

    always  @(posedge clk_125m or negedge rst_n)begin
        if(!rst_n)begin
            dout <= 1;
        end
        else if(out_data1)begin
            dout <= 0;
        end
        else if(out_data2)begin
            dout <= din_reg[cnt_bit-1];
        end
        else if(out_data3)begin
            dout <= check;
        end
		else if(out_data4)begin
			dout <= 1;
		end
    end
   
    assign out_data1 = bps_2 && cnt_bit == 0;
    assign out_data2 = bps_2 && cnt_bit > 0 && cnt_bit < 9;
    assign out_data3 = bps_2 && cnt_bit == 9;
    assign out_data4 = bps_2 && cnt_bit > 9;

	always  @(*)begin
        if(din_vld)begin
            rdy = 0;
        end
        else if(flag_bps_count)begin
            rdy = 0;
        end
        else begin
            rdy = 1;
        end
    end

endmodule
