`timescale 1ns / 1ps

module sel_dat(
				input				    user_clk,
				input				    user_reset,
                
                input                   dma_wrdone,
                output reg [10:0]       dmawr_len,
                input [87:0]			ram_dat_len,
                
                input [255:0]           wrfifo_dat,
                input [7:0]             wrfifo_en,
                
                output                  wrbuf_clr,
                output reg              wrbuf_en,
                output reg[31:0]        wrbuf_dat,
                
                output  reg [2:0]       ram_ptr
                );


reg [5:0]       dma_wrdone_r;
wire            dma_wrdone_p;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        dma_wrdone_r    <= 2'b0;
    else
        dma_wrdone_r    <= {dma_wrdone_r[0],dma_wrdone};
end

assign  wrbuf_clr    = ~dma_wrdone_r[1] & dma_wrdone_r[0];

assign  dma_wrdone_p = ~dma_wrdone_r[5] & dma_wrdone_r[4];

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        ram_ptr         <= 3'd0;
    else if( dma_wrdone_p == 1'b1 )    
        ram_ptr         <= ram_ptr + 1'b1;
    else
        ram_ptr         <= ram_ptr;
end 

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        wrbuf_en                <= 1'b0;
    else begin
        case( ram_ptr )
            3'd0 : wrbuf_en     <= wrfifo_en[0];
            3'd1 : wrbuf_en     <= wrfifo_en[1];
            3'd2 : wrbuf_en     <= wrfifo_en[2];
            3'd3 : wrbuf_en     <= wrfifo_en[3];
            3'd4 : wrbuf_en     <= wrfifo_en[4];
            3'd5 : wrbuf_en     <= wrfifo_en[5];
            3'd6 : wrbuf_en     <= wrfifo_en[6];
            3'd7 : wrbuf_en     <= wrfifo_en[7];
            default : wrbuf_en  <= 1'b0;
        endcase
    end
end    

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
            dmawr_len            <= 11'd0;
    else begin
        case( ram_ptr )
            3'd0 : dmawr_len     <= ram_dat_len[0*11 + 10:0*11];
            3'd1 : dmawr_len     <= ram_dat_len[1*11 + 10:1*11];
            3'd2 : dmawr_len     <= ram_dat_len[2*11 + 10:2*11];
            3'd3 : dmawr_len     <= ram_dat_len[3*11 + 10:3*11];
            3'd4 : dmawr_len     <= ram_dat_len[4*11 + 10:4*11];
            3'd5 : dmawr_len     <= ram_dat_len[5*11 + 10:5*11];
            3'd6 : dmawr_len     <= ram_dat_len[6*11 + 10:6*11];
            3'd7 : dmawr_len     <= ram_dat_len[7*11 + 10:7*11];
            default : dmawr_len  <= 11'd0;
        endcase
    end
end


always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        wrbuf_dat                <= 32'h0;
    else begin
        case( ram_ptr )
            3'd0 : wrbuf_dat     <= wrfifo_dat[31:0];
            3'd1 : wrbuf_dat     <= wrfifo_dat[63:32];
            3'd2 : wrbuf_dat     <= wrfifo_dat[95:64];
            3'd3 : wrbuf_dat     <= wrfifo_dat[127:96];
            3'd4 : wrbuf_dat     <= wrfifo_dat[159:128];
            3'd5 : wrbuf_dat     <= wrfifo_dat[191:160];
            3'd6 : wrbuf_dat     <= wrfifo_dat[223:192];
            3'd7 : wrbuf_dat     <= wrfifo_dat[255:224];
            default : wrbuf_dat  <= 32'h0;
        endcase
    end
end


endmodule 



