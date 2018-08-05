
`timescale 1ns/1ps

module msi_gen(
				input		    user_clk,
				input		    reset,

                input           pulse_int_mask,
                input           eth_int_mask,  
                input           pps1_mask,    
                input           m6x_uart_rx_mask,    

                input           nonprogramable_pps,    
                input           pps,
                input           m6x_uart_rx_flag,
                
				input [7:0]     dat_flag,
                input           dma_upstream_done,
                input           dma_upstream_flag,
                output reg      upstream_start,
                
                //
					 
                input				ram_tx_end,	/*DEBUG*/
					 
					 
                input           pc2pcie_completed,  //
                input           pcie2pc_completed,  //
                
                //int
                output reg      err,
                input [2:0]     cfg_interrupt_mmenable,
                input           cfg_interrupt_msienable,
                
                output reg      cfg_interrupt,
                input           cfg_interrupt_rdy,
                output reg[7:0] cfg_interrupt_di
				);
                
parameter   PPS_INT_VEC = 8'd0;     //INT 1           
parameter   ETH_DAT_VEC = 8'd1;     //INT 2 Not used for now
parameter   NONPROG_PPS = 8'd2;     //INT 3 nonprogrammable pps interrupt
parameter   M6X_UART_RX = 8'd3;     //INT 4 M6X uart configuration data ( upstream ) 

parameter   DAT2PCIE_END  = 8'd4;   //INT 5 mac downstream completed 
parameter   DAT2PC_END    = 8'd5;   //INT 6 mac upstream completed


reg [7:0]       dat_flag_r;
reg [7:0]       dat_flag_rr;
reg [7:0]       dat_flag_rrr;   

reg [1:0]       dmawr_done; 
reg [1:0]       dmawr_flag;       

reg [2:0]       ram_ptr;
reg             intr_meet;
reg             dat_rdy;
reg             intr_do; 

wire            int_rdy; 

reg [3:0]       pps_r;    

reg [7:0]       pps_vector;
reg [7:0]       dat_vector;

reg [7:0]       vector_num;


// always  @(posedge user_clk) begin
    // if( reset == 1'b1 )
        // vector_num      <= 8'd1;
    // else
        // vector_num      <= vector_num << cfg_interrupt_mmenable;
// end    
    
// always  @(posedge user_clk) begin
    // if( reset == 1'b1 ) begin
        // pps_vector      <= 8'd0;
        // dat_vector      <= 8'd1;
        // err             <= 1'b0;
    // end
    // else if( ( vector_num >= 8'd2 ) && ( cfg_interrupt_msienable == 1'b1 )) begin
        // pps_vector      <= 8'd0;
        // dat_vector      <= 8'd1;
        // err             <= 1'b0;
    // end
    // else begin
        // err             <= 1'b1;
    // end
// end
   

always  @(posedge user_clk) begin
    if( reset == 1'b1 ) begin
        dat_flag_r      <= 8'h0;
        dat_flag_rr     <= 8'h0;
        dat_flag_rrr    <= 8'h0;
    end    
    else begin
        dat_flag_r      <= dat_flag;
        dat_flag_rr     <= dat_flag_r;
        dat_flag_rrr    <= dat_flag_rr;
    end    
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 ) 
        dmawr_done      <= 2'b0;
    else
        dmawr_done      <= {dmawr_done[0],dma_upstream_done};
end    

always  @(posedge user_clk) begin
    if( reset == 1'b1 ) 
        dmawr_flag      <= 2'b0;
    else
        dmawr_flag      <= {dmawr_flag[0],dma_upstream_flag};   //indicate that DMA upstream had been done
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        ram_ptr      <= 3'd0;
    else if( ~dmawr_done[1] & dmawr_done[0] )
        ram_ptr      <= ram_ptr + 1'b1;
    else
        ram_ptr      <= ram_ptr;
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        dat_rdy             <= 1'b0;
    else begin
        case( ram_ptr )
            3'd0 : dat_rdy  <= dat_flag_rrr[0];
            3'd1 : dat_rdy  <= dat_flag_rrr[1];
            3'd2 : dat_rdy  <= dat_flag_rrr[2];
            3'd3 : dat_rdy  <= dat_flag_rrr[3];
            3'd4 : dat_rdy  <= dat_flag_rrr[4];
            3'd5 : dat_rdy  <= dat_flag_rrr[5];
            3'd6 : dat_rdy  <= dat_flag_rrr[6];
            3'd7 : dat_rdy  <= dat_flag_rrr[7];
            default : dat_rdy  <= dat_flag_rrr[0];
        endcase
    end
end    

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        intr_do         <= 1'b0;
    else if( ~dmawr_done[1] & dmawr_done[0] )
        intr_do         <= 1'b0;
    else if( dat_intr_clr == 1'b1 )
        intr_do         <= 1'b1;
    else
        intr_do         <= intr_do;
end    

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        intr_meet   <= 1'b0;
    else if( ~dmawr_flag[1] & dat_rdy & ~intr_do & eth_int_mask & cfg_interrupt_msienable )
        intr_meet   <= 1'b1;
    else if( dat_intr_clr == 1'b1 )
        intr_meet   <= 1'b0;
    else
        intr_meet   <= intr_meet;
end  

//programmable pps 
always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        pps_r       <= 4'b0;
    else
        pps_r       <= { pps_r[2:0],pps};
end

reg     pps_intr;

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        pps_intr    <= 1'b0;
    else if( ~pps_r[3] & pps_r[2] & pulse_int_mask & cfg_interrupt_msienable )
        pps_intr    <= 1'b1;
    else if( pps_intr_clr == 1'b1 )
        pps_intr    <= 1'b0;
    else
        pps_intr    <= pps_intr;
end      

//nonprogramable pps
reg [3:0]   nonprogramable_pps_r;
reg         pps1_intr;
reg         pps1_intr_clr;

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        nonprogramable_pps_r       <= 4'b0;
    else
        nonprogramable_pps_r       <= { nonprogramable_pps_r[2:0],nonprogramable_pps};
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        pps1_intr    <= 1'b0;
    else if(    ~nonprogramable_pps_r[3] & nonprogramable_pps_r[2] & 
                pps1_mask & cfg_interrupt_msienable )
        pps1_intr    <= 1'b1;
    else if( pps1_intr_clr == 1'b1 )
        pps1_intr    <= 1'b0;
    else
        pps1_intr    <= pps1_intr;
end 

reg [3:0]   m6x_uart_rx_flag_r;
reg         m6x_uart_rx_intr;
reg         m6x_uart_rx_intr_clr;
  
always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        m6x_uart_rx_flag_r       <= 4'b0;
    else
        m6x_uart_rx_flag_r       <= { m6x_uart_rx_flag_r[2:0],m6x_uart_rx_flag};
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        m6x_uart_rx_intr    <= 1'b0;
    else if(    ~m6x_uart_rx_flag_r[3] & m6x_uart_rx_flag_r[2] & 
                m6x_uart_rx_mask & cfg_interrupt_msienable )
        m6x_uart_rx_intr    <= 1'b1;
    else if( m6x_uart_rx_intr_clr == 1'b1 )
        m6x_uart_rx_intr    <= 1'b0;
    else
        m6x_uart_rx_intr    <= m6x_uart_rx_intr;
end 
  
//assign  int_rdy = ( int_cs == INT_IDLE ) ? 1'b1 : 1'b0;

//2018 0610
reg [1:0]       pc2pcie_completed_r;
reg             pc2pcie_msi_clr;
reg             pc2pcie_intr;

reg [1:0]       pcie2pc_completed_r;
reg             pcie2pc_msi_clr;
reg             pcie2pc_intr;


//debug
reg         debug_dly_en;
reg [9:0]   dly_cnt;

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
		debug_dly_en        <= 1'b0;
    else if( dly_cnt >= 10'd1000 )
        debug_dly_en        <= 1'b0;
    else if( ram_tx_end == 1'b1 ) 
        debug_dly_en        <= 1'b1;
    else
        debug_dly_en        <= debug_dly_en;
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        dly_cnt     <= 10'd0;
    else if( debug_dly_en == 1'b1 )
        dly_cnt     <= dly_cnt + 1'b1;
    else
        dly_cnt     <= 10'd0;
end    

always  @(posedge user_clk) begin
        pc2pcie_completed_r     <= {pc2pcie_completed_r[0] , debug_dly_en };//;pc2pcie_completed};
end

always  @(posedge user_clk) begin
        pcie2pc_completed_r     <= {pcie2pc_completed_r[0] , pcie2pc_completed};
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        pc2pcie_intr    <= 1'b0;
    else if( pc2pcie_msi_clr == 1'b1 )
        pc2pcie_intr    <= 1'b0;
    else if( pc2pcie_completed_r[1] & ~pc2pcie_completed_r[0] )    
    //else if( ~pc2pcie_completed_r[1] & pc2pcie_completed_r[0] )
        pc2pcie_intr    <= 1'b1;
    else
        pc2pcie_intr    <= pc2pcie_intr;
end

always  @(posedge user_clk) begin
    if( reset == 1'b1 )
        pcie2pc_intr    <= 1'b0;
    else if( pcie2pc_msi_clr == 1'b1 )
        pcie2pc_intr    <= 1'b0;
    else if( ~pcie2pc_completed_r[1] & pcie2pc_completed_r[0] )
        pcie2pc_intr    <= 1'b1;
    else
        pcie2pc_intr    <= pcie2pc_intr;
end

//assign  cfg_interrupt_di = 8'h0;
wire        intr_send_en ;

assign      intr_send_en = pps1_intr | pps_intr | intr_meet | m6x_uart_rx_intr | pc2pcie_intr | pcie2pc_intr;    

    
parameter   INT_IDLE    =   4'd0,
            INT_GEN     =   4'd1,
            INT_GRANT   =   4'd2,
            INT_DLY     =   4'd3,
            INT_DONE    =   4'd4;

reg [3:0]   int_cs;  

reg         dat_intr_clr; 
reg         pps_intr_clr;   

reg [5:0]   intdly_cnt;     
            
always  @(posedge user_clk) begin
    if( reset == 1'b1 ) begin
        cfg_interrupt           <= 1'b0;
        cfg_interrupt_di        <= 8'd0;
        
        dat_intr_clr            <= 1'b0;
        pps_intr_clr            <= 1'b0;
        pps1_intr_clr           <= 1'b0;
        m6x_uart_rx_intr_clr    <= 1'b0;
        
        pc2pcie_msi_clr         <= 1'b0;
        pcie2pc_msi_clr         <= 1'b0;
        
        upstream_start          <= 1'b0;
        
        intdly_cnt              <= 6'd0;
        
        int_cs                  <= INT_IDLE;
    end
    else begin
        case( int_cs )
            INT_IDLE : begin
                if( pps1_intr == 1'b1 ) begin
                    pps1_intr_clr           <= 1'b1;
                    dat_intr_clr            <= 1'b0;
                    pps_intr_clr            <= 1'b0;
                    m6x_uart_rx_intr_clr    <= 1'b0;
                    pc2pcie_msi_clr         <= 1'b0;
                    pcie2pc_msi_clr         <= 1'b0;
                    
                    cfg_interrupt_di        <= NONPROG_PPS;
                end
                else if( pps_intr == 1'b1 ) begin
                    pps_intr_clr            <= 1'b1;
                    dat_intr_clr            <= 1'b0;
                    pps1_intr_clr           <= 1'b0;
                    m6x_uart_rx_intr_clr    <= 1'b0;
                    pc2pcie_msi_clr         <= 1'b0;
                    pcie2pc_msi_clr         <= 1'b0;
                    
                    cfg_interrupt_di        <= PPS_INT_VEC;//pps_vector;
                end
                else if( m6x_uart_rx_intr == 1'b1 ) begin
                    m6x_uart_rx_intr_clr    <= 1'b1;
                    dat_intr_clr            <= 1'b0;
                    pps_intr_clr            <= 1'b0;
                    pps1_intr_clr           <= 1'b0;
                    pc2pcie_msi_clr         <= 1'b0;
                    pcie2pc_msi_clr         <= 1'b0;
                    
                    cfg_interrupt_di        <= M6X_UART_RX;//m6x_uart_rx_vector;
                end       
                else if( intr_meet == 1'b1 ) begin
                    dat_intr_clr            <= 1'b1;
                    pps_intr_clr            <= 1'b0;
                    pps1_intr_clr           <= 1'b0;
                    m6x_uart_rx_intr_clr    <= 1'b0;
                    pc2pcie_msi_clr         <= 1'b0;
                    pcie2pc_msi_clr         <= 1'b0;
                    
                    upstream_start          <= 1'b1;
                    
                    cfg_interrupt_di        <= ETH_DAT_VEC; //When mac data received from M6X
                end                 
                else if( pc2pcie_intr == 1'b1 ) begin
                    pc2pcie_msi_clr         <= 1'b1;
                    dat_intr_clr            <= 1'b0;
                    pps_intr_clr            <= 1'b0;
                    pps1_intr_clr           <= 1'b0;
                    m6x_uart_rx_intr_clr    <= 1'b0;
                    pcie2pc_msi_clr         <= 1'b0;
                    cfg_interrupt_di        <=  DAT2PCIE_END;   //Downstream completed
                end  
                else if( pcie2pc_intr == 1'b1 ) begin
                    pcie2pc_msi_clr         <= 1'b1;
                    dat_intr_clr            <= 1'b0;
                    pps_intr_clr            <= 1'b0;
                    pps1_intr_clr           <= 1'b0;
                    m6x_uart_rx_intr_clr    <= 1'b0;
                    pc2pcie_msi_clr         <= 1'b0;
                    cfg_interrupt_di        <=  DAT2PC_END; // upsteam completed
                end                
                else begin
                    upstream_start          <= 1'b0;
                    dat_intr_clr            <= 1'b0;
                    pps_intr_clr            <= 1'b0;
                    pps1_intr_clr           <= 1'b0;
                    m6x_uart_rx_intr_clr    <= 1'b0;
                    pc2pcie_msi_clr         <= 1'b0;
                    pcie2pc_msi_clr         <= 1'b0;
                    
                    cfg_interrupt_di        <= cfg_interrupt_di;
                end  

                intdly_cnt              <= 6'd0;
                
                if( intr_send_en == 1'b1 )
                    int_cs              <= INT_GEN;
                else
                    int_cs              <= INT_IDLE;
            end
            INT_GEN : begin
                upstream_start          <= 1'b0;
                cfg_interrupt           <= 1'b1;
                
                dat_intr_clr            <= 1'b0;
                pps_intr_clr            <= 1'b0;
                pps1_intr_clr           <= 1'b0;
                m6x_uart_rx_intr_clr    <= 1'b0;
                pc2pcie_msi_clr         <= 1'b0;
                pcie2pc_msi_clr         <= 1'b0;                
                
                int_cs                  <= INT_GRANT;
            end
            INT_GRANT : begin
                if( cfg_interrupt_rdy == 1'b1 ) begin
                    cfg_interrupt       <= 1'b0;
                    int_cs              <= INT_DLY;//INT_DONE;
                end
                else begin
                    cfg_interrupt       <= cfg_interrupt;
                    int_cs              <= INT_GRANT;
                end    
            end
            INT_DLY : begin
                if( intdly_cnt < 6'd32 )
                    intdly_cnt          <= intdly_cnt + 1'b1;
                else
                    intdly_cnt          <= 6'd0;
                    
                if( intdly_cnt >= 6'd32 )  
                    int_cs              <= INT_DONE;
                else
                    int_cs              <= INT_DLY; 
            end
            
            INT_DONE : begin
                int_cs                  <= INT_IDLE;
            end
            default : begin
                cfg_interrupt           <= 1'b0;
                intdly_cnt              <= 6'd0;
                int_cs                  <= INT_IDLE;            
            end
        endcase
    end
end    


endmodule 

