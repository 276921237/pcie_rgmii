
`timescale  1ns/1ps


module pcie_tx(
                input                   clk,
                input                   rst_n,
                input                   pcie_reset,

                inout [35:0]            CONTROL,
                
                input                   mwr_64b_add_en,
                
                input [2:0]             max_req_size,
                // AXIS
                input                   s_axis_tx_tready,
                output  reg [31:0]      s_axis_tx_tdata,
                output  reg [3:0]       s_axis_tx_tkeep,
                output  reg             s_axis_tx_tlast,
                output  reg             s_axis_tx_tvalid,
                output [3:0]            s_axis_tx_tuser,

                input                   req_compl_i,
                input                   req_compld_i,
                output reg              compl_done_o,

                input       [2:0]       req_tc_i,
                input                   req_td_i,
                input                   req_ep_i,
                input       [1:0]       req_attr_i,
                input       [9:0]       req_len_i,
                input       [15:0]      req_rid_i,
                input       [7:0]       req_tag_i,
                input       [7:0]       req_be_i,
                input       [31:0]      req_addr_i,

                output      [15:0]      rd_addr_o,
                input       [31:0]      rd_data_i,

                input       [15:0]      completer_id_i,
                
                //dma
                input                   dmard_start,
                input [10:0]            dmard_len,  //bytes
                input [63:0]            dmard_add,
                
                input                   dmawr_start,
                input [10:0]            dmawr_len,  //bytes
                input [63:0]            dmawr_add,
                output reg              dmawr_completed, //single c
                
                output reg              dmawr_rdfifo_rst,
                output reg              dmawr_rdfifo_en,
                input [31:0]            dmawr_rdfifo_dat
                
              );

// TLP Header format/type values
localparam CPLD_FMT_TYPE   = 7'b10_01010;
localparam CPL_FMT_TYPE    = 7'b00_01010;

parameter	MEM_RD64_FMT_TYPE = 7'b01_00000;    //
parameter	MEM_WR64_FMT_TYPE = 7'b11_00000;//

parameter	MEM_RD32_FMT_TYPE = 7'b00_00000;
parameter	MEM_WR32_FMT_TYPE = 7'b10_00000;

assign  rd_addr_o = {req_addr_i[15:2],2'b00};

assign  s_axis_tx_tuser = 4'b0000;


reg [10:0]      max_reqsize_dw;

always  @(posedge clk) begin
    if( ~rst_n | ~rst_dma_n )
        max_reqsize_dw  <= 11'd0;
    else begin
        case( max_req_size )
            3'b000 : max_reqsize_dw     <= 11'd32;
            3'b001 : max_reqsize_dw     <= 11'd64;
            3'b010 : max_reqsize_dw     <= 11'd128;
            3'b011 : max_reqsize_dw     <= 11'd256;
            3'b100 : max_reqsize_dw     <= 11'd512;
            3'b101 : max_reqsize_dw     <= 11'd1024;
            default : max_reqsize_dw    <= 11'd32;
        endcase
    end
end

reg [6:0]   lower_addr;
reg [11:0]  byte_count;

always @* begin
    casex ({req_compld_i, req_be_i[3:0]})
        5'b0_xxxx : lower_addr = 8'h0;
        5'bx_0000 : lower_addr = {req_addr_i[6:2], 2'b00};
        5'bx_xxx1 : lower_addr = {req_addr_i[6:2], 2'b00};
        5'bx_xx10 : lower_addr = {req_addr_i[6:2], 2'b01};
        5'bx_x100 : lower_addr = {req_addr_i[6:2], 2'b10};
        5'bx_1000 : lower_addr = {req_addr_i[6:2], 2'b11};
    endcase
end

always @* begin
    casex (req_be_i[3:0])
        4'b1xx1 : byte_count = 12'h004;
        4'b01x1 : byte_count = 12'h003;
        4'b1x10 : byte_count = 12'h003;
        4'b0011 : byte_count = 12'h002;
        4'b0110 : byte_count = 12'h002;
        4'b1100 : byte_count = 12'h002;
        4'b0001 : byte_count = 12'h001;
        4'b0010 : byte_count = 12'h001;
        4'b0100 : byte_count = 12'h001;
        4'b1000 : byte_count = 12'h001;
        4'b0000 : byte_count = 12'h001;
    endcase
end


reg [1:0]       req_compl_q;
reg [1:0]       req_compld_q;
reg             compl_req;
reg             compld_req;
reg             compl_req_clr;

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) begin
        req_compl_q         <= 2'b0;
        req_compld_q        <= 2'b0;
    end else begin
        req_compl_q         <= {req_compl_q[0],req_compl_i};
        req_compld_q        <= {req_compld_q[0],req_compld_i};
    end
end

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        compl_req   <= 1'b0;
    else if( compl_req_clr == 1'b1 )
        compl_req   <= 1'b0;
    else if( ~req_compl_q[1]   & req_compl_q[0] )
        compl_req   <= 1'b1;
    else
        compl_req   <= compl_req;
end

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        compld_req   <= 1'b0;
    else if( compl_req_clr == 1'b1 )
        compld_req   <= 1'b0;
    else if( ~req_compld_q[1]  & req_compld_q[0] )
        compld_req   <= 1'b1;
    else
        compld_req   <= compld_req;
end

//pcie statemachine reset
parameter       RST_IDLE    = 4'd0,
                WT_CPL_DONE =   4'd1,
                RST_DMASTA  =   4'd2,
                RST_DONE    =   4'd3,
					 RST_REQ		= 4'd4;



reg [3:0]       rst_cs;
reg             rst_dma_n;

always @(posedge clk) begin
    if ( rst_n == 1'b0 ) begin
        rst_dma_n           <= 1'b1 ;
        
        rst_cs              <= RST_IDLE;
    end
    else begin
        case( rst_cs )
            RST_IDLE : begin
                if( compl_req == 1'b1 )
                    rst_cs  <= RST_REQ;
                else
                    rst_cs  <= RST_IDLE;
                    
                rst_dma_n   <= 1'b1;    
            end
				RST_REQ : begin
					if( pcie_reset == 1'b1 )
						rst_cs	<= WT_CPL_DONE;
					else
						rst_cs	<= RST_IDLE;
				end
				
            WT_CPL_DONE : begin
                if( current_state == IDLE )//( ( compl_done_o  == 1'b1 ) && ( current_state == IDLE ) )
                    rst_cs  <= RST_DMASTA;
                else
                    rst_cs  <= WT_CPL_DONE;
            end
            RST_DMASTA : begin
                rst_dma_n   <= 1'b0 ;
                
                rst_cs      <= RST_DONE;
            end
            RST_DONE : begin
                rst_dma_n   <= 1'b1;
                
                rst_cs      <= RST_IDLE;
            end
            default : begin
                rst_dma_n           <= 1'b1 ;
                
                rst_cs              <= RST_IDLE;            
            end
        endcase    
    end
end    



//dma read req
reg [1:0]   dmard_start_q;
reg [10:0]  dmard_len_q;
reg [63:0]  dmard_add_q;

reg [1:0]   dmawr_start_q;
reg [10:0]  dmawr_len_q;
reg [63:0]  dmawr_add_q;

reg         dmard_req;
reg         dmard_req_clr;

reg         dmawr_req;
reg         dmawr_req_clr;

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        dmard_start_q   <= 2'b0;
    else 
        dmard_start_q   <= {dmard_start_q[0],dmard_start};
end

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        dmard_len_q     <= 11'd0;
    else if( ~dmard_start_q[1] & dmard_start_q[0] )    
        dmard_len_q     <= ( dmard_len[1:0] == 2'b00 ) ? { 2'b00 , dmard_len[10:2] } : ( { 2'b00 , dmard_len[10:2] + 1'b1 });
    else
        dmard_len_q     <= dmard_len_q;
end        

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        dmard_add_q     <= 64'd0;
    else if( ~dmard_start_q[1] & dmard_start_q[0] )    
        dmard_add_q     <= dmard_add;
    else
        dmard_add_q     <= dmard_add_q;
end

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        dmard_req       <= 1'b0;
    else if( dmard_req_clr == 1'b1 )    
        dmard_req       <= 1'b0;
    else if( ~dmard_start_q[1] & dmard_start_q[0] )    
        dmard_req       <= 1'b1;
    else
        dmard_req       <= dmard_req;
end

//dma write
always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        dmawr_start_q   <= 2'b0;
    else 
        dmawr_start_q   <= {dmawr_start_q[0],dmawr_start};
end
/*
always @(posedge clk) begin
    if ( rst_n == 1'b0 ) 
        dmawr_len_q     <= 10'd0;
    else if( ~dmawr_start_q[1] & dmawr_start_q[0] )    
        dmawr_len_q     <= ( dmawr_len[1:0] == 2'b00 ) ? dmawr_len[11:2] : ( dmawr_len[11:2] + 1'b1 );
    else
        dmawr_len_q     <= dmawr_len_q;
end
*/

reg [4:0]   wrtlp_total_count;
reg [9:0]   wrtlp_total_dwcount;
/*
always @(posedge clk) begin
    if ( rst_n == 1'b0 )
        wrtlp_total_count   <= 5'd0;
    else
        wrtlp_total_count   <= ( dmawr_len_q[4:0] == 5'd0 ) ? dmawr_len_q[9:5] : ( dmawr_len_q[9:5] + 5'd1 );
end
*/        
/*
always @(posedge clk) begin
    if ( rst_n == 1'b0 ) 
        dmawr_add_q     <= 64'd0;
    else if( ~dmawr_start_q[1] & dmawr_start_q[0] )    
        dmawr_add_q     <= dmawr_add;
    else
        dmawr_add_q     <= dmawr_add_q;
end
*/

always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) 
        dmawr_req       <= 1'b0;
    else if( dmawr_req_clr == 1'b1 )    
        dmawr_req       <= 1'b0;
    else if( ~dmawr_start_q[1] & dmawr_start_q[0] )    
        dmawr_req       <= 1'b1;
    else
        dmawr_req       <= dmawr_req;
end

//
parameter   IDLE    =   6'd0,
            CPL_DW1 =   6'd1,
            CPL_DW2 =   6'd2,
            CPL_DW3 =   6'd3,
            CPL_DW4 =   6'd4,
            CPL_DONE=   6'd5,
            
            DMARD_DW1   =   6'd6,
            DMARD_DW2   =   6'd7,
            DMARD_DW3   =   6'd8,
            DMARD_DONE  =   6'd9,
            
            DMAWR_JUDGE =   6'd10,
            DMAWR_DW1   =   6'd11,
            DMAWR_DW2   =   6'd12,
            DMAWR_DW3   =   6'd13,
            DMAWR_DWN   =   6'd14,
            DMAWR_DONE  =   6'd15,
            CPLD_DONE   =   6'd16,
    
            DMARD_JUDGE             = 6'd17,
            DMARD_NOT_CROSS         = 6'd18,
            DMARD_DOES_CROSS        = 6'd19,

            DMARD_DW4   =   6'd20,
            DMAWR_DW4   =   6'd21;
            
reg [5:0]   current_state; 
reg [5:0]   next_state;
reg [5:0]   req_ns;

reg         cpl_with_dat;      
reg [9:0]   current_tlp_dwcount;
reg [4:0]   wr_tag;
reg [4:0]   rd_tag;    

reg [63:0]  current_tlp_add;    

reg [5:0]   wrdat_beat_count;

wire        tlp_end;

// always @(posedge clk) begin
    // if ( ~rst_n | ~rst_dma_n )
        // wrdat_beat_count    <= 6'd0;
    // else if( current_state != DMAWR_DWN )    
        // wrdat_beat_count    <= 6'd0;
    // else if( ( s_axis_tx_tready == 1'b1 ) && ( current_state == DMAWR_DWN )) 
        // wrdat_beat_count    <= wrdat_beat_count + 1'b1;
    // else
        // wrdat_beat_count    <= wrdat_beat_count;
// end

//assign  tlp_end =  ( wrdat_beat_count >= ( current_tlp_dwcount - 2'd2 )) ? 1'b1 : 1'b0;


reg [10:0]  dmareq_len;
reg [63:0]  dmareq_add;
reg [63:0]  dmareq_add_latch;
reg [10:0]  dmareq_len_remain;
reg [10:0]  dmareq_1st_len;
reg [10:0]  dmareq_2nd_len;

reg         dmareq_1st_done;
reg         dmareq_2nd_done;
reg         do_cross;



always @(posedge clk) begin
    if ( ~rst_n | ~rst_dma_n ) begin
        s_axis_tx_tlast     <= 1'b0;
        s_axis_tx_tvalid    <= 1'b0;
        s_axis_tx_tdata     <= 32'h0;
        s_axis_tx_tkeep     <= 4'hF;

        compl_done_o        <= 1'b0;
        cpl_with_dat        <= 1'b0;
        
        compl_req_clr       <= 1'b0;
        dmard_req_clr       <= 1'b0;
        dmawr_req_clr       <= 1'b0;
        
        rd_tag              <= 5'd0;
        wr_tag              <= 5'd0;
        
        wrtlp_total_count   <= 5'd0;
        wrtlp_total_dwcount <= 10'd0;
        current_tlp_dwcount <= 10'd0;
        current_tlp_add     <= 64'h0;
        
        dmawr_rdfifo_en     <= 1'b0;
        dmawr_rdfifo_rst    <= 1'b1;
        dmawr_completed     <= 1'b0;
        
        dmareq_len          <= 11'd0;
        dmareq_add          <= 64'h0;
        dmareq_add_latch    <= 64'h0;
        dmareq_len_remain   <= 11'd0;
        dmareq_1st_len      <= 11'd0;
        dmareq_2nd_len      <= 11'd0;
            
        dmareq_1st_done     <= 1'b0;
        dmareq_2nd_done     <= 1'b0;
        do_cross            <= 1'b0;  
           
        wrdat_beat_count    <= 6'd0;   
        
        next_state          <= IDLE;
        current_state       <= IDLE;
    end 
    else begin
        case( current_state )
            IDLE : begin
                compl_done_o        <= 1'b0;
                dmawr_completed     <= 1'b0;
                dmawr_rdfifo_en     <= 1'b0;
                dmawr_rdfifo_rst    <= 1'b0;
                
                rd_tag              <= rd_tag;
                wr_tag              <= wr_tag;
                
                wrdat_beat_count    <= 6'd0;
                
                dmareq_len          <= 11'd0;
                dmareq_add          <= 64'h0;
                dmareq_add_latch    <= 64'h0;
                dmareq_len_remain   <= 11'd0;
                dmareq_1st_len      <= 11'd0;
                dmareq_2nd_len      <= 11'd0;
                    
                dmareq_1st_done     <= 1'b0;
                dmareq_2nd_done     <= 1'b0;   
                do_cross            <= 1'b0;
                
                s_axis_tx_tlast     <= 1'b0;
                s_axis_tx_tvalid    <= 1'b0;
                s_axis_tx_tdata     <= 64'h0;
                s_axis_tx_tkeep     <= 4'hF;
        
                if( compl_req | compld_req) begin   //1
                    compl_req_clr   <= 1'b1;
                    cpl_with_dat    <= compld_req;
                    
                    next_state      <= IDLE;
                    current_state   <= CPL_DW1;
                end
                else if( dmard_req == 1'b1 ) begin  //2
                    dmard_req_clr   <= 1'b1;
                    
                    next_state      <= IDLE;
                    current_state   <= DMARD_JUDGE;//DMARD_DW1;
                end
                else if( dmawr_req == 1'b1 ) begin  //3
                    dmawr_req_clr   <= 1'b1;
                    
                    wrtlp_total_count   <= ( dmawr_len[4:0] == 5'd0 ) ? dmawr_len[10:5] : ( dmawr_len[10:5] + 5'd1 );
                    wrtlp_total_dwcount <= ( dmawr_len[1:0] == 2'b00 ) ? dmawr_len[10:2] : ( dmawr_len[10:2] + 1'b1 );
                    
                    current_tlp_add     <= dmawr_add;
                    
                    current_state       <= DMAWR_JUDGE;
                end
                else begin
                    compl_req_clr   <= 1'b0;
                    dmard_req_clr   <= 1'b0;
                    
                    cpl_with_dat    <= 1'b0;
                    
                    next_state              <= IDLE;
                    current_state              <= IDLE;
                end
            end
            CPL_DW1 : begin
                compl_req_clr       <= 1'b0;
                
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast  <= 1'b0;
                    s_axis_tx_tvalid <= 1'b1;
                    s_axis_tx_tdata  <= {1'b0,
                                              ( cpl_with_dat == 1'b1 ) ? CPLD_FMT_TYPE : CPL_FMT_TYPE,
                                              {1'b0},
                                              req_tc_i,
                                              {4'b0},
                                              req_td_i,
                                              req_ep_i,
                                              req_attr_i,
                                              {2'b0},
                                              req_len_i
                                              };   
                    current_state                <= CPL_DW2;                            
                end
                else
                    current_state                <= CPL_DW1;
            end
            CPL_DW2 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast  <= 1'b0;
                    s_axis_tx_tvalid <= 1'b1;
                    s_axis_tx_tdata  <= {completer_id_i,
                                              {3'b0},
                                              {1'b0},
                                              byte_count
                                              };
                    current_state            <= CPL_DW3;                    
                end
                else
                    current_state               <= CPL_DW2;
            end
            CPL_DW3 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tvalid <= 1'b1;
                    s_axis_tx_tdata  <= {
                                        req_rid_i,
                                        req_tag_i,
                                        {1'b0},
                                        lower_addr
                                        };  

                    if( cpl_with_dat == 1'b1 ) begin
                        s_axis_tx_tlast <= 1'b0;
                        current_state              <= CPL_DW4;
                    end
                    else begin
                        s_axis_tx_tlast <= 1'b1;
                        compl_done_o    <= 1'b1;
                        
                        current_state              <= next_state;
                        //current_state              <= IDLE;
                    end
                end
                else
                    current_state               <= CPL_DW3;
            end
            CPL_DW4 : begin
                if ( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b1;
                    s_axis_tx_tvalid    <= 1'b1;
                    s_axis_tx_tdata     <= rd_data_i;
                    current_state                  <= CPLD_DONE;
                end 
                else begin
                    current_state                  <= CPL_DW4;
                end
            end
            CPLD_DONE : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b0;
                    s_axis_tx_tdata     <= 32'h0;                
                
                    compl_done_o        <= 1'b1;
                    
                    current_state                  <= next_state;
                    //current_state                  <= IDLE;
                end
                else              
                    current_state                  <= CPLD_DONE;
            end
            //DMA read
            DMARD_JUDGE : begin
                s_axis_tx_tlast     <= 1'b0;
                s_axis_tx_tvalid    <= 1'b0;
                s_axis_tx_tdata     <= 32'h0; 
                    
                dmareq_len_remain   <= dmard_len_q;
                dmareq_add_latch    <= dmard_add_q;
                compl_done_o        <= 1'b0;
                //next_state                  <= IDLE;
                
                if( ( 11'd1024 - dmard_add_q[11:2] ) >= dmard_len_q ) begin //not across a 4KB boundary                                        
                    do_cross        <= 1'b0;
                    current_state   <= DMARD_NOT_CROSS;
                end    
                else begin//if( ( 11'd1024 - dmard_add_q[12:2] ) >= dmard_len_q ) begin
                    dmareq_1st_len      <= 11'd1024 - dmard_add_q[11:2];
                    dmareq_2nd_len      <= dmard_len_q + dmard_add_q[11:2] - 11'd1024;
                    
                    do_cross            <= 1'b1;
                    current_state       <= DMARD_DOES_CROSS;
                end    
            end
            
            DMARD_NOT_CROSS : begin
                s_axis_tx_tlast         <= 1'b0;
                s_axis_tx_tvalid        <= 1'b0;
                s_axis_tx_tdata         <= 32'h0; 
                
                if( dmareq_len_remain <= max_reqsize_dw )  begin //1 request need
                    dmareq_len_remain   <= 11'd0;
                    dmareq_len          <= dmareq_len_remain;
                    dmareq_add          <= dmareq_add_latch;
                    
                    current_state       <= DMARD_DW1;
                    req_ns              <= DMARD_DONE;
                end
                else begin
                    dmareq_len_remain   <= dmareq_len_remain - max_reqsize_dw;
                    dmareq_len          <= max_reqsize_dw;
                    dmareq_add          <= dmareq_add_latch;
                    dmareq_add_latch    <= dmareq_add_latch + {max_reqsize_dw,2'b00};
                    
                    current_state       <= DMARD_DW1;
                    req_ns              <= DMARD_NOT_CROSS;
                end
            end
            DMARD_DOES_CROSS : begin
                s_axis_tx_tlast         <= 1'b0;
                s_axis_tx_tvalid        <= 1'b0;
                s_axis_tx_tdata         <= 32'h0; 
                
                if( dmareq_1st_done == 1'b0 ) begin
                    dmareq_len_remain   <= dmareq_1st_len;
                    dmareq_add_latch    <= dmareq_add_latch; 
                    
                    dmareq_1st_done     <= 1'b1;  
                    dmareq_2nd_done     <= 1'b0;
                end
                else begin
                    dmareq_len_remain   <= dmareq_2nd_len;
                    dmareq_add_latch    <= dmareq_1st_len + dmard_add_q;    
                    dmareq_2nd_done     <= 1'b1;
                end
                
                current_state           <= DMARD_NOT_CROSS;
            end
            DMARD_DW1 : begin
                dmard_req_clr           <= 1'b0;
                
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b1;
                    s_axis_tx_tdata     <= {
                                            1'b0,
                                            ( mwr_64b_add_en == 1'b1 ) ? MEM_RD64_FMT_TYPE : MEM_RD32_FMT_TYPE,
                                            1'b0,
                                            2'b00,//tc,
                                            {6'b0},
                                            2'b00,//attr,
                                            2'b0,
                                            dmareq_len
                                            };                      
                    current_state       <= DMARD_DW2;
                end
                else
                    current_state       <= DMARD_DW1;
            end
            DMARD_DW2 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b1;
                    s_axis_tx_tdata     <= {
                                            completer_id_i,                                            
                                            {3'b0, rd_tag[4:0]},   //TAG
                                            (dmareq_len[9:0] == 1'b1) ? 4'b0 : 4'hF,
                                            4'hF
                                            };
                    
                    rd_tag              <= rd_tag + 1'b1;        
                                            
                    current_state       <= ( mwr_64b_add_en == 1'b1 ) ? DMARD_DW3 : DMARD_DW4;
                end
                else
                    current_state       <= DMARD_DW2;
            end
            
            DMARD_DW3 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b1;
                    s_axis_tx_tdata     <= dmareq_add[63:32];
                    
                    current_state       <= DMARD_DW4;
                end
                else
                    current_state       <= DMARD_DW3;
            end
            DMARD_DW4 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b1;
                    s_axis_tx_tvalid    <= 1'b1;
                    
                    s_axis_tx_tdata     <= {
                                            dmareq_add[31:2],
                                            2'b00
                                            };
                                            
                    current_state       <= req_ns;//DMARD_DONE;
                end
                else
                    current_state       <= DMARD_DW4;
            end
            DMARD_DONE : begin
                s_axis_tx_tlast         <= 1'b0;
                s_axis_tx_tvalid        <= 1'b0;            
            
                //current_state                      <= next_state;
                if( do_cross == 1'b0 )
                    current_state                  <= next_state;
                else if( dmareq_2nd_done == 1'b1 )
                    current_state                  <= next_state;
                else
                    current_state                  <= DMARD_DOES_CROSS;
            end
            
            //DMA write
            DMAWR_JUDGE : begin
                dmawr_req_clr           <= 1'b0;
                compl_done_o            <= 1'b0;
                
                dmawr_rdfifo_en         <= 1'b0;
                wrdat_beat_count        <= 6'd0;
                
                s_axis_tx_tvalid        <= 1'b0;
                s_axis_tx_tlast         <= 1'b0;
                s_axis_tx_tdata         <= 32'h0;
                
                //need to take the priority into consideration
                if( compl_req | compld_req ) begin
                    compl_req_clr       <= 1'b1;
                    cpl_with_dat        <= compld_req;
                    
                    next_state          <= DMAWR_JUDGE;
                    current_state       <= CPL_DW1;
                end
                else if( dmard_req == 1'b1 ) begin  //2
                    dmard_req_clr       <= 1'b1;
                    
                    next_state          <= DMAWR_JUDGE;
                    current_state       <= DMARD_JUDGE;
                end
                else begin
                    current_tlp_add     <= current_tlp_add;
                                        
                    if( ( 11'd1024 - current_tlp_add[11:2] ) >= 11'd32 ) begin//current tlp not cross 4kB boundary
                        if( wrtlp_total_dwcount == 10'd0 ) begin
                            dmawr_rdfifo_rst    <= 1'b1;
                            current_state       <= DMAWR_DONE;
                        end
                        else if( wrtlp_total_dwcount >= 10'd32) begin
                            current_tlp_dwcount <= 10'd32;  //128B
                            wrtlp_total_dwcount <= wrtlp_total_dwcount - 10'd32;
                            
                            current_state       <= DMAWR_DW1;
                        end    
                        else begin
                            current_tlp_dwcount <= wrtlp_total_dwcount;
                            wrtlp_total_dwcount <= 10'd0;
                                                        
                            current_state       <= DMAWR_DW1;
                        end                         
                    end
                    else begin      //does cross
                        if( wrtlp_total_dwcount == 10'd0 ) begin
                            dmawr_rdfifo_rst    <= 1'b1;
                            current_state       <= DMAWR_DONE;
                        end
                        else begin //if( wrtlp_total_dwcount >= ( 11'd1024 - current_tlp_add[11:2]) ) begin
                            current_tlp_dwcount <= 11'd1024 - current_tlp_add[11:2];
                            wrtlp_total_dwcount <= wrtlp_total_dwcount + current_tlp_add[11:2] - 11'd1024;
                            current_state       <= DMAWR_DW1;
                        end                        
                    end
                end     
            end
            DMAWR_DW1 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b1;
                    
                    s_axis_tx_tdata     <= {1'b0, 
                                            ( mwr_64b_add_en == 1'b1 ) ? MEM_WR64_FMT_TYPE : MEM_WR32_FMT_TYPE, 
                                            1'b0, 
                                            3'b000, //mwr_tlp_tc_i 
                                            4'b0, 
                                            1'b0, 
                                            1'b0, 
                                            2'b00, 
                                            2'b0, 
                                            current_tlp_dwcount[9:0] };   
                    current_state       <= DMAWR_DW2;                            
                end
                else
                    current_state       <= DMAWR_DW1;
            end
            DMAWR_DW2 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b1;
                    
                    s_axis_tx_tdata     <= {
                                            completer_id_i, 
                                            {3'b000,wr_tag[4:0]},
                                            (current_tlp_dwcount[9:0] == 1'b1) ? 4'b0 : 4'hF,
                                            4'hF
                                            };   
                                            
                    current_state       <= ( mwr_64b_add_en == 1'b1 ) ? DMAWR_DW3 : DMAWR_DW4;                            
                end
                else
                    current_state       <= DMAWR_DW2;            
            end
            
            DMAWR_DW3 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b1;
                    s_axis_tx_tdata     <= current_tlp_add[63:32];
                    
                    current_state       <= DMAWR_DW4;
                end
                else
                    current_state       <= DMAWR_DW3;
            end
            DMAWR_DW4 : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tlast     <= 1'b0;
                    s_axis_tx_tvalid    <= 1'b1;
                    s_axis_tx_tdata     <= {current_tlp_add[31:2],2'b00};  
                    
                    dmawr_rdfifo_en     <= 1'b1;
                    
                    current_tlp_add     <= current_tlp_add + ( current_tlp_dwcount << 2);    
                                            
                    current_state       <= DMAWR_DWN;                            
                end
                else
                    current_state       <= DMAWR_DW4;                
            end
            //data
            DMAWR_DWN : begin
                if( s_axis_tx_tready ) begin
                    s_axis_tx_tvalid    <= 1'b1;
                    s_axis_tx_tdata     <= {dmawr_rdfifo_dat[7:0] , dmawr_rdfifo_dat[15:8] , dmawr_rdfifo_dat[23:16] , dmawr_rdfifo_dat[31:24]}; 
                    
                    if( wrdat_beat_count >=  ( current_tlp_dwcount - 1'b1 ) ) begin 
                        wr_tag              <= wr_tag + 1'b1;
                        wrdat_beat_count    <= 'd0;
                        dmawr_rdfifo_en     <= 1'b0;
                        
                        //dmawr_rdfifo_en <= 1'b0;          
                        s_axis_tx_tlast <= 1'b1;          
                        current_state   <= DMAWR_JUDGE;                 
                    end
                    else begin
                        wr_tag          <= wr_tag;
                        dmawr_rdfifo_en <= 1'b1;
                        
                        wrdat_beat_count<= wrdat_beat_count + 1'b1;
                        
                        s_axis_tx_tlast <= 1'b0;
                        current_state   <= DMAWR_DWN;                     
                    end
                end
                else begin
                    dmawr_rdfifo_en     <= 1'b0;
                    current_state       <= DMAWR_DWN;
                end
            end
            
            DMAWR_DONE : begin
                dmawr_completed         <= 1'b1;
                
                current_state           <= IDLE;
            end
            
            default : begin
                s_axis_tx_tlast         <= 1'b0;
                s_axis_tx_tvalid        <= 1'b0;
                s_axis_tx_tdata         <= 32'h0;
                s_axis_tx_tkeep         <= 4'hF;

                compl_done_o            <= 1'b0;
                cpl_with_dat            <= 1'b0;
                
                compl_req_clr           <= 1'b0;
                dmard_req_clr           <= 1'b0;
                dmawr_req_clr           <= 1'b0;
                
                rd_tag                  <= 5'd0;
                wr_tag                  <= 5'd0;
                
                wrtlp_total_count       <= 5'd0;
                wrtlp_total_dwcount     <= 10'd0;
                current_tlp_dwcount     <= 10'd0;
                current_tlp_add         <= 32'h0;
                
                wrdat_beat_count        <= 6'd0;    
                dmawr_rdfifo_en         <= 1'b0;
                dmawr_rdfifo_rst        <= 1'b1;
                dmawr_completed         <= 1'b0;
                
                next_state              <= IDLE;
                current_state           <= IDLE;            
            end
        endcase
    end
end    

//ila_grab ila_tx (
//						 .CONTROL		(CONTROL), // INOUT BUS [35:0]
//						 .CLK           (clk), // IN
//						 .TRIG0			({
//                                            s_axis_tx_tready,
//                                            s_axis_tx_tdata,
//                                            s_axis_tx_tlast,
//                                            s_axis_tx_tvalid,
//                                            current_state,
//                                            dmard_start,
//                                            dmawr_start,
//                                            dmard_len,
//                                            dmawr_len,
//                                            dmard_add,
//                                            dmawr_add,
//                                            dmawr_completed,
//                                            dmawr_rdfifo_en,
//                                            max_req_size
//                                            }) // IN BUS [255:0]
//					);




endmodule 



