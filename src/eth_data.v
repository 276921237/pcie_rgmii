module eth_data(
	input             clk_125m,
	input             rst_n   ,
	output reg [7:0]  gmii_tx ,
	output reg        gmii_txv 
);
	
	reg [26:0] cnt;
	reg [7:0] data_tmp [75:0];
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			cnt <= 0;
		end
		else if(cnt == 125_000_00-1)begin
			cnt <= 0;
		end
		else begin
			cnt <= cnt + 1'b1;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			gmii_tx <= 0;
			gmii_txv <= 0;
		end
		else if(cnt > 0 && cnt <= 76)begin
			gmii_tx <= data_tmp[cnt-1];
			gmii_txv <= 1;
		end
		else begin
			gmii_tx <= 0;
			gmii_txv <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			data_tmp[0]  <= 0;
			data_tmp[1]  <= 0;
			data_tmp[2]  <= 0;
			data_tmp[3]  <= 0;
			data_tmp[4]  <= 0;
			data_tmp[5]  <= 0;
			data_tmp[6]  <= 0;
			data_tmp[7]  <= 0;
			data_tmp[8]  <= 0;
			data_tmp[9]  <= 0;
			data_tmp[10] <= 0;
			data_tmp[11] <= 0;
			data_tmp[12] <= 0;
			data_tmp[13] <= 0;
			data_tmp[14] <= 0;
			data_tmp[15] <= 0;
			data_tmp[16] <= 0;
			data_tmp[17] <= 0;
			data_tmp[18] <= 0;
			data_tmp[19] <= 0;
			data_tmp[20] <= 0;
			data_tmp[21] <= 0;
			data_tmp[22] <= 0;
			data_tmp[23] <= 0;
			data_tmp[24] <= 0;
			data_tmp[25] <= 0;
			data_tmp[26] <= 0;
			data_tmp[27] <= 0;
			data_tmp[28] <= 0;
			data_tmp[29] <= 0;
			data_tmp[30] <= 0;
			data_tmp[31] <= 0;
			data_tmp[32] <= 0;
			data_tmp[33] <= 0;
			data_tmp[34] <= 0;
			data_tmp[35] <= 0;
			data_tmp[36] <= 0;
			data_tmp[37] <= 0;
			data_tmp[38] <= 0;
			data_tmp[39] <= 0;
			data_tmp[40] <= 0;
			data_tmp[41] <= 0;
			data_tmp[42] <= 0;
			data_tmp[43] <= 0;
			data_tmp[44] <= 0;
			data_tmp[45] <= 0;
			data_tmp[46] <= 0;
			data_tmp[47] <= 0;
			data_tmp[48] <= 0;
			data_tmp[49] <= 0;
			data_tmp[50] <= 0;
			data_tmp[51] <= 0;
			data_tmp[52] <= 0;
			data_tmp[53] <= 0;
			data_tmp[54] <= 0;
			data_tmp[55] <= 0;
			data_tmp[56] <= 0;
			data_tmp[57] <= 0;
			data_tmp[58] <= 0;
			data_tmp[59] <= 0;
			data_tmp[60] <= 0;
			data_tmp[61] <= 0;
			data_tmp[62] <= 0;
			data_tmp[63] <= 0;
			data_tmp[64] <= 0;
			data_tmp[65] <= 0;
			data_tmp[66] <= 0;
			data_tmp[67] <= 0;
			data_tmp[68] <= 0;
			data_tmp[69] <= 0;
			data_tmp[70] <= 0;
			data_tmp[71] <= 0;		
			data_tmp[72] <= 0;		
			data_tmp[73] <= 0;		
			data_tmp[74] <= 0;		
			data_tmp[75] <= 0;		
		end
		else begin
			data_tmp[0]  <= 8'h55;
			data_tmp[1]  <= 8'h55;
			data_tmp[2]  <= 8'h55;
			data_tmp[3]  <= 8'h55;
			data_tmp[4]  <= 8'h55;
			data_tmp[5]  <= 8'h55;
			data_tmp[6]  <= 8'h55;
			data_tmp[7]  <= 8'hd5;
			data_tmp[8]  <= 8'hff;
			data_tmp[9]  <= 8'hff;
			data_tmp[10] <= 8'hff;
			data_tmp[11] <= 8'hff;
			data_tmp[12] <= 8'hff;
			data_tmp[13] <= 8'hff;
			data_tmp[14] <= 8'h00;
			data_tmp[15] <= 8'h11;
			data_tmp[16] <= 8'h22;
			data_tmp[17] <= 8'h33;
			data_tmp[18] <= 8'h44;
			data_tmp[19] <= 8'h56;
			data_tmp[20] <= 8'h08;
			data_tmp[21] <= 8'h00;
			data_tmp[22] <= 8'h45;
			data_tmp[23] <= 8'h00;
			data_tmp[24] <= 8'h00;
			data_tmp[25] <= 8'h32;
			data_tmp[26] <= 8'h21;
			data_tmp[27] <= 8'hb3;
			data_tmp[28] <= 8'h00;
			data_tmp[29] <= 8'h00;
			data_tmp[30] <= 8'h40;
			data_tmp[31] <= 8'h11;
			data_tmp[32] <= 8'hf5;
			data_tmp[33] <= 8'h27;
			data_tmp[34] <= 8'hac;
			data_tmp[35] <= 8'h12;
			data_tmp[36] <= 8'h05;
			data_tmp[37] <= 8'hdd;
			data_tmp[38] <= 8'hac;
			data_tmp[39] <= 8'h12;
			data_tmp[40] <= 8'h05;
			data_tmp[41] <= 8'hdf;
			data_tmp[42] <= 8'h05;
			data_tmp[43] <= 8'h21;
			data_tmp[44] <= 8'h05;
			data_tmp[45] <= 8'h21;
			data_tmp[46] <= 8'h00;
			data_tmp[47] <= 8'h1e;
			data_tmp[48] <= 8'h16;
			data_tmp[49] <= 8'hbf;
			data_tmp[50] <= 8'hef;
			data_tmp[51] <= 8'hec;
			data_tmp[52] <= 8'h3d;
			data_tmp[53] <= 8'hd6;
			data_tmp[54] <= 8'hc5;
			data_tmp[55] <= 8'h36;
			data_tmp[56] <= 8'h44;
			data_tmp[57] <= 8'h67;
			data_tmp[58] <= 8'h39;
			data_tmp[59] <= 8'h21;
			data_tmp[60] <= 8'hbc;
			data_tmp[61] <= 8'h64;
			data_tmp[62] <= 8'h6d;
			data_tmp[63] <= 8'hb3;
			data_tmp[64] <= 8'h97;
			data_tmp[65] <= 8'hc8;
			data_tmp[66] <= 8'h82;
			data_tmp[67] <= 8'hb5;
			data_tmp[68] <= 8'h50;
			data_tmp[69] <= 8'h41;
			data_tmp[70] <= 8'h75;
			data_tmp[71] <= 8'h76;
			data_tmp[72] <= 8'h5f;
			data_tmp[73] <= 8'hcc;
			data_tmp[74] <= 8'h1a;
			data_tmp[75] <= 8'h9c;	
		end
	end

endmodule
