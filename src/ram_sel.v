`timescale 1ns / 1ps


module  ram_sel(
				input				    user_clk,
				input				    user_reset,
                
                input                   dma_wrdone,
                output [10:0]           dmawr_len,
                //read fifo interface
                input                   buf_rst,
                input                   buf_rd,
                output [31:0]           buf_dat,
                
                //upstream ram interface
                input [7:0]		        ram_data_flag,
                output[7:0]	            ram_data_flag_clr,
                                        
                //0                     
                input [10:0]	        ram_dat_len0,
                output 			        eth_ram_clk0,
                output			        eth_ram_we0,
                output			        eth_ram_en0,
                output [10:0]	        eth_ram_add0,
                input [31:0]	        eth_ram_dat0,
                                        
                output 			        ts_ram_clk0,
                output			        ts_ram_we0,
                output			        ts_ram_en0,
                output [3:0]	        ts_ram_add0,
                input [31:0]	        ts_ram_dat0,
                //1                     
                input [10:0]	        ram_dat_len1,
                output 			        eth_ram_clk1,
                output			        eth_ram_we1,
                output			        eth_ram_en1,
                output [10:0]	        eth_ram_add1,
                input [31:0]	        eth_ram_dat1,
                                        
                output 			        ts_ram_clk1,
                output			        ts_ram_we1,
                output			        ts_ram_en1,
                output [3:0]	        ts_ram_add1,
                input [31:0]	        ts_ram_dat1,
                //2                     
                input [10:0]	        ram_dat_len2,
                output 			        eth_ram_clk2,
                output			        eth_ram_we2,
                output			        eth_ram_en2,
                output [10:0]	        eth_ram_add2,
                input [31:0]	        eth_ram_dat2,
                                        
                output 			        ts_ram_clk2,
                output			        ts_ram_we2,
                output			        ts_ram_en2,
                output [3:0]	        ts_ram_add2,
                input [31:0]	        ts_ram_dat2,					
                //3                     
                input [10:0]	        ram_dat_len3,
                output 			        eth_ram_clk3,
                output			        eth_ram_we3,
                output			        eth_ram_en3,
                output [10:0]	        eth_ram_add3,
                input [31:0]	        eth_ram_dat3,
                                        
                output 			        ts_ram_clk3,
                output			        ts_ram_we3,
                output			        ts_ram_en3,
                output [3:0]	        ts_ram_add3,
                input [31:0]	        ts_ram_dat3,
                //4                     
                input [10:0]	        ram_dat_len4,
                output 			        eth_ram_clk4,
                output			        eth_ram_we4,
                output			        eth_ram_en4,
                output [10:0]	        eth_ram_add4,
                input [31:0]	        eth_ram_dat4,
                                        
                output 			        ts_ram_clk4,
                output			        ts_ram_we4,
                output			        ts_ram_en4,
                output [3:0]	        ts_ram_add4,
                input [31:0]	        ts_ram_dat4,
                //5                     
                input [10:0]	        ram_dat_len5,
                output 			        eth_ram_clk5,
                output			        eth_ram_we5,
                output			        eth_ram_en5,
                output [10:0]	        eth_ram_add5,
                input [31:0]	        eth_ram_dat5,
                                        
                output 			        ts_ram_clk5,
                output			        ts_ram_we5,
                output			        ts_ram_en5,
                output [3:0]	        ts_ram_add5,
                input [31:0]	        ts_ram_dat5,
                //6                     
                input [10:0]	        ram_dat_len6,
                output 			        eth_ram_clk6,
                output			        eth_ram_we6,
                output			        eth_ram_en6,
                output [10:0]	        eth_ram_add6,
                input [31:0]	        eth_ram_dat6,
                                        
                output 			        ts_ram_clk6,
                output			        ts_ram_we6,
                output			        ts_ram_en6,
                output [3:0]	        ts_ram_add6,
                input [31:0]	        ts_ram_dat6,	
                //7                     
                input [10:0]	        ram_dat_len7,
                output 			        eth_ram_clk7,
                output			        eth_ram_we7,
                output			        eth_ram_en7,
                output [10:0]	        eth_ram_add7,
                input [31:0]	        eth_ram_dat7,
                                        
                output 			        ts_ram_clk7,
                output			        ts_ram_we7,
                output			        ts_ram_en7,
                output [3:0]	        ts_ram_add7,
                input [31:0]	        ts_ram_dat7                
                
                
                );
                
wire [15:0]     ts_add;
wire [71:0]     eth_add;
wire [7:0]      flag_clr;

wire [255:0]    ts_dat;
wire [255:0]    eth_dat;

wire [255:0]    wrfifo_dat;
wire [7:0]      wrfifo_en;

wire [2:0]      ram_ptr;                        
wire            wrbuf_en;
wire [31:0]     wrbuf_dat;

wire [87:0]     ram_dat_len;
                
assign  eth_ram_clk0    = user_clk;
assign  eth_ram_en0     = 1'b1;
assign  eth_ram_we0     = 1'b0;
assign  eth_ram_add0    = {eth_add[8:0],2'b00};
assign  ts_ram_clk0     = user_clk;
assign  ts_ram_en0      = 1'b1;
assign  ts_ram_we0      = 1'b0;
assign  ts_ram_add0     = {ts_add[1:0],2'b00};

assign  eth_ram_clk1    = user_clk;
assign  eth_ram_en1     = 1'b1;
assign  eth_ram_we1     = 1'b0;
assign  eth_ram_add1    = {eth_add[17:9],2'b00};
assign  ts_ram_clk1     = user_clk;
assign  ts_ram_en1      = 1'b1;
assign  ts_ram_we1      = 1'b0;
assign  ts_ram_add1     = {ts_add[3:2],2'b00};

assign  eth_ram_clk2    = user_clk;
assign  eth_ram_en2     = 1'b1;
assign  eth_ram_we2     = 1'b0;
assign  eth_ram_add2    = {eth_add[26:18],2'b00};
assign  ts_ram_clk2     = user_clk;
assign  ts_ram_en2      = 1'b1;
assign  ts_ram_we2      = 1'b0;
assign  ts_ram_add2     = {ts_add[5:4],2'b00};

assign  eth_ram_clk3    = user_clk;
assign  eth_ram_en3     = 1'b1;
assign  eth_ram_we3     = 1'b0;
assign  eth_ram_add3    = {eth_add[35:27],2'b00};
assign  ts_ram_clk3     = user_clk;
assign  ts_ram_en3      = 1'b1;
assign  ts_ram_we3      = 1'b0;
assign  ts_ram_add3     = {ts_add[7:6],2'b00};

assign  eth_ram_clk4    = user_clk;
assign  eth_ram_en4     = 1'b1;
assign  eth_ram_we4     = 1'b0;
assign  eth_ram_add4    = {eth_add[44:36],2'b00};
assign  ts_ram_clk4     = user_clk;
assign  ts_ram_en4      = 1'b1;
assign  ts_ram_we4      = 1'b0;
assign  ts_ram_add4     = {ts_add[9:8],2'b00};

assign  eth_ram_clk5    = user_clk;
assign  eth_ram_en5     = 1'b1;
assign  eth_ram_we5     = 1'b0;
assign  eth_ram_add5    = {eth_add[53:45],2'b00};
assign  ts_ram_clk5     = user_clk;
assign  ts_ram_en5      = 1'b1;
assign  ts_ram_we5      = 1'b0;
assign  ts_ram_add5     = {ts_add[11:10],2'b00};

assign  eth_ram_clk6    = user_clk;
assign  eth_ram_en6     = 1'b1;
assign  eth_ram_we6     = 1'b0;
assign  eth_ram_add6    = {eth_add[62:54],2'b00};
assign  ts_ram_clk6     = user_clk;
assign  ts_ram_en6      = 1'b1;
assign  ts_ram_we6      = 1'b0;
assign  ts_ram_add6     = {ts_add[13:12],2'b00};

assign  eth_ram_clk7    = user_clk;
assign  eth_ram_en7     = 1'b1;
assign  eth_ram_we7     = 1'b0;
assign  eth_ram_add7    = {eth_add[71:63],2'b00};
assign  ts_ram_clk7     = user_clk;
assign  ts_ram_en7      = 1'b1;
assign  ts_ram_we7      = 1'b0;
assign  ts_ram_add7     = {ts_add[15:14],2'b00};

assign  ram_data_flag_clr = flag_clr;

wire            clr_buf;




assign  ts_dat  = { ts_ram_dat7 , ts_ram_dat6 ,
                    ts_ram_dat5 , ts_ram_dat4 ,
                    ts_ram_dat3 , ts_ram_dat2 ,
                    ts_ram_dat1 , ts_ram_dat0 };
                    
assign  eth_dat = { eth_ram_dat7,eth_ram_dat6,
                    eth_ram_dat5,eth_ram_dat4,
                    eth_ram_dat3,eth_ram_dat2,
                    eth_ram_dat1,eth_ram_dat0};

assign ram_dat_len = {  ram_dat_len7,ram_dat_len6,
                        ram_dat_len5,ram_dat_len4,
                        ram_dat_len3,ram_dat_len2,
                        ram_dat_len1,ram_dat_len0};

genvar  i;

generate
    for( i = 0 ; i < 8 ; i = i + 1 ) begin : select_ram_group
        sel_group 
        sel_group_inst (
                        .user_clk       ( user_clk                      ), 
                        .user_reset     ( user_reset                    ), 
                                          
                        .ram_data_flag  ( ram_data_flag[i]              ), 
                        .ram_ptr        ( ram_ptr                       ),
                        .group_id       ( i                             ),                        
                        .ts_add         ( ts_add[2*i + 1 : 2*i]         ), 
                        .eth_add        ( eth_add[9*i + 8 : 9*i]        ), 
                        .flag_clr       ( flag_clr[i]                   ), 
                                          
                        .ram_dat_len    ( ram_dat_len[11*i +10 : 11*i]  ),
                                          
                        .ts_dat         ( ts_dat[32*i + 31 : 32*i]      ),
                        .eth_dat        ( eth_dat[32*i + 31 : 32*i]     ), 
                                          
                        .wrfifo_dat     ( wrfifo_dat[32*i + 31 : 32*i]  ),                   
                        .wrfifo_en      ( wrfifo_en[i]                  )
                        );

end

endgenerate

sel_dat sel_dat_inst (
                        .user_clk       (user_clk), 
                        .user_reset     (user_reset), 
                        
                        .ram_dat_len    (ram_dat_len),
                        .dmawr_len      (dmawr_len),
								
                        .dma_wrdone     (dma_wrdone), 
                        .wrfifo_dat     (wrfifo_dat), 
                        .wrfifo_en      (wrfifo_en), 
                        
                        .wrbuf_clr      ( clr_buf  ),
                        .wrbuf_en       ( wrbuf_en ), 
                        .wrbuf_dat      ( wrbuf_dat), 
                        .ram_ptr        ( ram_ptr  )
                        );
                        

        
                        
tx_buf tx_buf_inst (
                        .clk            ( user_clk          ), // input clk
                        .rst            ( buf_rst | clr_buf ), // input srst
                        
                        .din            ( wrbuf_dat ), // input [31 : 0] din
                        .wr_en          ( wrbuf_en  ), // input wr_en
                        
                        .rd_en          ( buf_rd    ), // input rd_en
                        .dout           ( buf_dat   ), // output [31 : 0] dout
                        .full           (), // output full
                        .empty          (), // output empty
                        .data_count     () // output [9 : 0] data_count
                        );                        

                        
//for debug   



// reg [31:0]  wr_dat;
// reg         wr_en;
// wire        full;


// always  @(posedge user_clk) begin
    // if( user_reset == 1'b1 ) begin
        // wr_dat  <= 32'd0;
        // wr_en   <= 1'b0;
    // end
    // else if( dma_wrdone_r[2] & ~dma_wrdone_r[3] ) begin
        // wr_dat  <= 32'd0;
        // wr_en   <= 1'b0;
    // end    
    // else if( ~full ) begin
        // wr_dat  <= wr_dat + 1'b1;
        // wr_en   <= 1'b1;
    // end    
    // else begin
        // wr_dat  <= 32'd0;
        // wr_en   <= 1'b0;    
    // end
// end

// always  @(posedge user_clk) begin
    // dma_wrdone_r        <= {dma_wrdone_r[2:0],dma_wrdone};
// end                        
          
                     
// tx_buf tx_buf_inst (
                        // .clk            ( user_clk   ), // input clk
                        // .rst            ( user_reset | dma_wrdone_r[2] & ~dma_wrdone_r[3]  ), // input srst
                        
                        // .din            ( wr_dat ), // input [31 : 0] din
                        // .wr_en          ( wr_en  ), // input wr_en
                        
                        // .rd_en          ( buf_rd ), // input rd_en
                        // .dout           ( buf_dat), // output [31 : 0] dout
                        // .full           ( full   ), // output full
                        // .empty          (        ), // output empty
                        // .data_count     (        ) // output [9 : 0] data_count
                        // );                          
                        
                        
endmodule 


