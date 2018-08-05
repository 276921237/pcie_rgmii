`timescale 1ns / 1ps
module rgmii_rx(
input clk_125m,
input rst_n,
//rgmii input
input rgmii_rxclk,
input rgmii_rxclk_n,
input [3:0]rgmii_rxd_i,
input rgmii_rxdv_i,
//GMII output
output reg [7:0]gmii_rxd,
output reg  gmii_rxdv
);

wire [7:0] gmii_rxd_ddr;
wire       gmii_rxdv_ddr;
//以下采用IDDR2 原语实现上升沿下降沿 双采样	 
IDDR2 #(
.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
.INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
.INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
) 
Iddr2_0(
      .Q0(gmii_rxd_ddr[0]), // 1-bit output captured with C0 clock
      .Q1(gmii_rxd_ddr[4]), // 1-bit output captured with C1 clock
      .C0(rgmii_rxclk), // 1-bit clock input
      .C1(rgmii_rxclk_n), // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rgmii_rxd_i[0]),   // 1-bit ddr data input
      .R(1'b0),   // 1-bit reset input
      .S(1'b0)    // 1-bit set input
   );	
	
IDDR2 #(
.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
.INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
.INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
) 
Iddr2_1(
      .Q0(gmii_rxd_ddr[1]), // 1-bit output captured with C0 clock
      .Q1(gmii_rxd_ddr[5]), // 1-bit output captured with C1 clock
      .C0(rgmii_rxclk), // 1-bit clock input
      .C1(rgmii_rxclk_n), // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rgmii_rxd_i[1]),   // 1-bit ddr data input
      .R(1'b0),   // 1-bit reset input
      .S(1'b0)    // 1-bit set input
   );	
	
IDDR2 #(
.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
.INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
.INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
) 
Iddr2_2(
      .Q0(gmii_rxd_ddr[2]), // 1-bit output captured with C0 clock
      .Q1(gmii_rxd_ddr[6]), // 1-bit output captured with C1 clock
      .C0(rgmii_rxclk), // 1-bit clock input
      .C1(rgmii_rxclk_n), // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rgmii_rxd_i[2]),   // 1-bit ddr data input
      .R(1'b0),   // 1-bit reset input
      .S(1'b0)    // 1-bit set input
   );
	
IDDR2 #(
.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
.INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
.INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
) 
Iddr2_3(
      .Q0(gmii_rxd_ddr[3]), // 1-bit output captured with C0 clock
      .Q1(gmii_rxd_ddr[7]), // 1-bit output captured with C1 clock
      .C0(rgmii_rxclk), // 1-bit clock input
      .C1(rgmii_rxclk_n), // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rgmii_rxd_i[3]),   // 1-bit ddr data input
      .R(1'b0),   // 1-bit reset input
      .S(1'b0)    // 1-bit set input
   );	

IDDR2 #(
.DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
.INIT_Q0(1'b0), // Sets initial state of the Q0 output to 1'b0 or 1'b1
.INIT_Q1(1'b0), // Sets initial state of the Q1 output to 1'b0 or 1'b1
.SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
) 
Iddr2_4(
      .Q0(), // 1-bit output captured with C0 clock
      .Q1(gmii_rxdv_ddr), // 1-bit output captured with C1 clock
      .C0(rgmii_rxclk), // 1-bit clock input
      .C1(rgmii_rxclk_n), // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(rgmii_rxdv_i),   // 1-bit ddr data input
      .R(1'b0),   // 1-bit reset input
      .S(1'b0)    // 1-bit set input
   );	
   
//////////////////////////////////////////////////////////////////////////////
reg  [8:0] wr_data;
reg        wr;
wire [8:0] rd_data;
reg        rd;
reg        flag_rd;
wire empty;
wire valid;
wire [5:0] rd_data_count;

rgmii_rx_fifo u_rgmii_rx_fifo(
	.rst			(rst_n			),
	.wr_clk			(rgmii_rxclk	),
	.rd_clk			(clk_125m		),
	.din			(wr_data		),
	.wr_en			(wr				),
	.rd_en			(rd				),
	.dout			(rd_data		),
	.full			(				),
	.almost_full	(				),
	.wr_ack			(				),
	.overflow		(				),
	.empty			(empty			),
	.almost_empty	(				),
	.valid			(valid			),
	.underflow		(				),
	.rd_data_count	(rd_data_count	),
	.wr_data_count	(				),
	.prog_full		(				),
	.prog_empty		(				)
);

	always @ (posedge rgmii_rxclk or negedge rst_n)begin
		if(!rst_n)begin
			wr <= 0;
		end
		else if(gmii_rxdv_ddr)begin
			wr <= 1;
		end
		else begin
			wr <= 0;
		end
	end
	
	always @ (posedge rgmii_rxclk or negedge rst_n)begin
		if(!rst_n)begin
			wr_data <= 0;
		end
		else begin
			wr_data <= {gmii_rxdv_ddr,gmii_rxd_ddr};
		end
	end
	
	always @ (*)begin
		if(flag_rd && empty == 0)begin
			rd = 1;
		end
		else begin
			rd = 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			flag_rd <= 0;
		end
		else if(rd_data_count > 7)begin
			flag_rd <= 1;
		end
		else if(empty)begin
			flag_rd <= 0;
		end
	end
	
	always @ (posedge clk_125m or negedge rst_n)begin
		if(!rst_n)begin
			gmii_rxdv <= 0;
			gmii_rxd <= 0; 
		end
		else if(valid)begin
			gmii_rxdv <= rd_data[8];
			gmii_rxd <= rd_data[7:0]; 
		end
		else begin
			gmii_rxdv <= 0;
			gmii_rxd <= 0; 
		end
	end
	
endmodule
