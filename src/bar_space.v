
`timescale 1ns/1ps


module bar_space(
                    input                   user_clk,
                    input                   user_reset,
                    
                    input [7:0]             wr_io_be,
                    input [15:0]            wr_io_add,
                    input [31:0]            wr_io_dat,
                    input                   wr_io_en,
                    
                    input                   rd_req,
                    input [15:0]            rd_add,
                    output [31:0]           rd_dat,
                    
                    //debug
                    output reg [10:0]       debug_wlen,
                    
                    input                   upstream_start,
                    input [10:0]            upstream_len,
                    output [10:0]           downstream_len,
                    
                    //DMA 
                    output reg [63:0]       dma_wr_base,
                    output reg [63:0]       dma_rd_base,
                    output reg              dma_wr_start,
                    output reg              dma_rd_start,                    
                    
                    input                   dma_wrdone,     //after write to PC buffer
                    input                   dma_rddone,      //after send to PHY
                    
                    output                  dma_upstream_flag,
                    
                    output reg              pulse_int_mask,
                    output reg              eth_int_mask,  
                    output reg              pps1_mask,
                    output reg              m6x_uart_rx_mask,
                    
                    input [31:0]            tod_us_cnt,
                    
                    //uart signals
                    //uart controll interface
                    //upstream
                    input           m6x_uart_ram_data_flag,
                    output reg      m6x_uart_ram_data_flag_clr,
                    input  [12:0]   m6x_uart_ram_dat_len,
                    
                    output          m6x_uart_ram_clk,
                    output          m6x_uart_ram_we,
                    output          m6x_uart_ram_en,
                    output reg[12:0]m6x_uart_ram_add,
                    input  [31:0]   m6x_uart_ram_dat,
                    
                    //down
                    output reg      m6x_uart_tx_start,
                    output          m6x_uart_tx_end,
                    output reg[7:0] m6x_uart_down_byte_len,
                    input           m6x_uart_down_tx_completed,
                    
                    output          m6x_uart_down_tx_clk,
                    output reg      m6x_uart_down_tx_we,
                    output          m6x_uart_down_tx_en,
                    output reg[7:0] m6x_uart_down_tx_add,
                    output reg[31:0]m6x_uart_down_tx_dat,
                    input [31:0]    m6x_uart_down_tx_dat_i,
                    
                    //TOD
                    input           m6x_tod_ram_data_flag,
                    output reg      m6x_tod_ram_data_flag_clr,
                    input [8:0]     m6x_tod_ram_data_len,
                    
                    output          m6x_tod_ram_clk,
                    output          m6x_tod_ram_we,
                    output          m6x_tod_ram_en,
                    output reg[8:0] m6x_tod_ram_add,
                    input [31:0]    m6x_tod_ram_dat, 
                    
                    output          uart_ustod_latch_flag,
                    input [31:0]    bar_year_month_day,
                    input [31:0]    bar_hour_min_sec,
                    input [31:0]    bar_nano_sec,

                    output reg [31:0]   pps_freq_cnt1,
                    output reg [31:0]   pps_freq_cnt2,
                    output reg          pps_freq_sel,
   
                    output              pcie_reset
				
					);
                    
parameter   FPGA_VER_HI     =   16'h0;                    
parameter   FPGA_VER_LO     =   16'h1; 

parameter   CTRL_SPACE      =   3'b000,
            TOD_SPACE       =   3'b001,
            M6XUP_SPACE     =   3'b010,
            M6XDN_SPACE     =   3'b011;


parameter   TEST1_ADD           =   11'h00,                    
            TEST2_ADD           =   11'h04,
                
            PCIE_RST            =   11'h08,
                
            FPGA_VER            =   11'h10,
            CLR_DMA_SET         =   11'h14,
            DMA_WRBASE          =   11'h18, //unused
            DMA_WRLEN           =   11'h1C,  
                
            DMA_RDBASE          =   11'h20,////unused
            DMA_RDLEN           =   11'h24,
            DMA_START           =   11'h28,
            CLR_DMA_FLAG        =   11'h2C,
            
            ETHUP_BYTE_CNT      =   11'h30,
            ETHUP_BYTE_CNT_CLR  =   11'h34,
    
            DMAWR_ADD_LO        =   11'h38,
            DMAWR_ADD_HI        =   11'h3c,
                
            DMARD_ADD_LO        =   11'h40,
            DMARD_ADD_HI        =   11'h44,
    
            MSI_MASK            =   11'h48,
                
            CTRL_UP_CNT         =   11'h80,
            CTRL_UP_FLAG        =   11'h84,
            CTRL_UPFLAG_CLR     =   11'h88,
                
            CTRL_DN_CNT         =   11'h90,
            CTRL_DN_EN          =   11'h94,
            CTRL_TX_BUSY        =   11'h98,
                
            TOD_BYTE_CNT        =   11'ha0,
            TOD_FLAG            =   11'ha4,
            TOD_FLAG_CLR        =   11'ha8,

            MAC_LO              =   11'h104,
            MAC_HI              =   11'h108,
                
            PPSFREQ_CNT1        =   11'h10c,
            PPSFREQ_CNT2        =   11'h110,
            PPSFREQ_SEL         =   11'h114,
            
            
            HARDWARE_FREQ         = 11'h118,

            TOD_YEAR_MONTH_DAY    = 11'h200,
            TOD_HOUR_MIN_SEC      = 11'h204,
            UART_NSTOD_CNT        = 11'h208,
            UART_USTOD_LATCH_FLAG = 11'h20c;
            
            
            
            
parameter   DEBUG_WRLEN     =   11'hac;            
            
            
assign  m6x_uart_down_tx_clk    =   user_clk;            
assign  m6x_uart_down_tx_en     =   1'b1;       

assign  m6x_tod_ram_clk         =   user_clk;
assign  m6x_tod_ram_we          =   1'b0;
assign  m6x_tod_ram_en          =   1'b1;
            
assign  m6x_uart_ram_clk        =   user_clk;
assign  m6x_uart_ram_we         =   1'b0;
assign  m6x_uart_ram_en         =   1'b1;
          
                                      
reg [15:0]		wr_io_add_r;
reg [31:0]		wr_io_dat_r;
reg	[1:0]       wr_io_en_r;
                
always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        wr_io_add_r     <= 16'h0;
    else 
        wr_io_add_r     <= wr_io_add;
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        wr_io_dat_r     <= 32'h0;
    else 
        wr_io_dat_r     <= wr_io_dat;
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        wr_io_en_r     <= 2'h0;
    else 
        wr_io_en_r     <= {wr_io_en_r[0],wr_io_en};
end

wire    wr_en;

assign  wr_en = ~wr_io_en_r[1] & wr_io_en_r[0];


reg [15:0]      rd_add_r;
reg             rd_req_r;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        rd_req_r    <= 1'b0;
    else
        rd_req_r    <= rd_req;
end        
      
always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        rd_add_r    <= 16'd0;
    else if( ~rd_req_r & rd_req ) 
        rd_add_r    <= rd_add;
    else
        rd_add_r    <= rd_add_r;
end        

//register input signals
reg [15:0]  dma_wrlen_r;
reg [15:0]  dma_wrlen_rr;
reg [15:0]  dma_upstream_len;

reg [3:0]   upstream_start_d;
reg [31:0]  rd_dat_r;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        upstream_start_d    <= 2'b00;
    else
        upstream_start_d    <= {upstream_start_d[2:0],upstream_start};
end    

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) begin
        dma_wrlen_r     <= 16'd0;
        dma_wrlen_rr    <= 16'd0;
    end
    else begin
        dma_wrlen_r     <= {5'd0,upstream_len};
        dma_wrlen_rr    <= dma_wrlen_r;    
    end
end 

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        dma_upstream_len    <= 16'd0;
    else if( ~upstream_start_d[3] & upstream_start_d[2] )
        dma_upstream_len    <= dma_wrlen_rr;
    else if( ~clr_eth_d & clr_eth )
        dma_upstream_len    <= 16'd0;
    else
        dma_upstream_len    <= dma_upstream_len;
end
        
//about M6X up
reg [12:0]  m6x_ctrl_len_r;
reg [12:0]  m6x_ctrl_len;

reg [1:0]   m6x_ctrl_flag;
reg         m6x_ctrl_rdy;

reg         clr_ctrl_flag;
reg [1:0]   clr_ctrl_r;
reg         ctrl_clr_extend;

wire        clr_ctrl_p;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) begin
        m6x_ctrl_len_r  <= 13'd0;
        m6x_ctrl_len    <= 13'd0;
    end
    else begin
        m6x_ctrl_len_r  <= m6x_uart_ram_dat_len;
        m6x_ctrl_len    <= m6x_ctrl_len_r;
    end
end    

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        m6x_ctrl_flag   <= 2'b00;
    else
        m6x_ctrl_flag   <= {m6x_ctrl_flag[0],m6x_uart_ram_data_flag};
end    

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        clr_ctrl_r      <= 2'b00;
    else    
        clr_ctrl_r      <= {clr_ctrl_r[0],clr_ctrl_flag};
end

assign  clr_ctrl_p = ~clr_ctrl_r[1] & clr_ctrl_r[0];

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        m6x_uart_ram_data_flag_clr      <= 1'b0;
    else if( clr_ctrl_p == 1'b1 )
        m6x_uart_ram_data_flag_clr      <= 1'b1;
    else if( ctrl_clr_extend == 1'b1 )
        m6x_uart_ram_data_flag_clr      <= 1'b0;
    else
        m6x_uart_ram_data_flag_clr      <= m6x_uart_ram_data_flag_clr;
end 
   
always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        ctrl_clr_extend                 <= 1'b0;
    else if( m6x_uart_ram_data_flag_clr == 1'b1 )
        ctrl_clr_extend                 <= 1'b1;
    else
        ctrl_clr_extend                 <= 1'b0;
end        

//M6X down
reg [1:0]   m6x_down_start_r;
reg [1:0]   m6x_down_done_r;

wire        m6x_start_p;
wire        m6x_done_p;

reg         m6x_down_busy;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        m6x_down_start_r            <= 2'b0;
    else
        m6x_down_start_r            <= {m6x_down_start_r[0],m6x_uart_tx_start};
end

assign  m6x_start_p = ~m6x_down_start_r[1] & m6x_down_start_r[0];

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        m6x_down_done_r            <= 2'b0;
    else
        m6x_down_done_r            <= {m6x_down_done_r[0],m6x_uart_down_tx_completed};
end

assign  m6x_done_p = ~m6x_down_done_r[1] & m6x_down_done_r[0];

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        m6x_down_busy               <= 1'b0;
    else if( m6x_start_p == 1'b1 )
        m6x_down_busy               <= 1'b1;
    else if( m6x_done_p == 1'b1 )
        m6x_down_busy               <= 1'b0;
    else
        m6x_down_busy               <= m6x_down_busy;
end

//TOD
reg [8:0]       tod_len_r;
reg [8:0]       tod_len_rr;
reg [1:0]       tod_flag_r;
reg [1:0]       clr_tod_r;
reg             clr_tod_extend;
wire            clr_tod_p;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) begin
        tod_len_r       <= 9'd0;
        tod_len_rr      <= 9'd0;
    end
    else begin
        tod_len_r       <= m6x_tod_ram_data_len;
        tod_len_rr      <= tod_len_r;
    end
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        tod_flag_r      <= 2'b00;
    else 
        tod_flag_r      <= {tod_flag_r[0],m6x_tod_ram_data_flag};
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        clr_tod_r       <= 2'b00;
    else    
        clr_tod_r       <= {clr_tod_r[0],clr_tod};
end

assign  clr_tod_p = ~clr_tod_r[1] & clr_tod_r[0];

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        m6x_tod_ram_data_flag_clr      <= 1'b0;
    else if( clr_tod_p == 1'b1 )
        m6x_tod_ram_data_flag_clr      <= 1'b1;
    else if( clr_tod_extend == 1'b1 )
        m6x_tod_ram_data_flag_clr      <= 1'b0;
    else
        m6x_tod_ram_data_flag_clr      <= m6x_tod_ram_data_flag_clr;
end 
   
always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        clr_tod_extend                  <= 1'b0;
    else if( m6x_tod_ram_data_flag_clr == 1'b1 )
        clr_tod_extend                  <= 1'b1;
    else
        clr_tod_extend                  <= 1'b0;
end

//
reg [31:0]      test1;
reg [31:0]      test2;
reg             clr_settings;
reg             clr_tod;
reg             dma_wrdone_clr;
reg             dma_rddone_clr;

reg [1:0]       clr_dma_register;
wire            clr_dma_opr;
reg             clr_eth;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        clr_dma_register    <= 2'b00;
    else
        clr_dma_register    <= {clr_dma_register[0],clr_settings};
end    

assign  clr_dma_opr = ~clr_dma_register[1] & clr_dma_register[0];

reg [31:0]		dma_rd_len;
reg             tod_time_latch;


always  @(posedge user_clk) begin
    if( ( user_reset == 1'b1 ) || ( clr_dma_opr == 1'b1 ) ) begin
        test1                   <=  32'haaaa_aaaa_aaaa_aaaa;
        test2                   <=  32'h5555_5555_5555_5555;
        
        pcie_rst_r              <= 1'b0;
        
        clr_settings            <=  1'b0;
        dma_wr_base             <=  64'h0;
        dma_rd_base             <=  64'h0;
        dma_rd_len              <=  32'h0;
        dma_wr_start            <=  1'b0;
        dma_rd_start            <=  1'b0;
        
        dma_wrdone_clr          <= 1'b0;
        dma_rddone_clr          <= 1'b0;
        
        clr_ctrl_flag           <= 1'b0;
        
        clr_eth             <= 1'b0;
        
        m6x_uart_down_byte_len  <= 8'd0;
        m6x_uart_tx_start       <= 1'b0;
        
        m6x_uart_down_tx_we     <= 1'b0;
        m6x_uart_down_tx_dat    <= 32'h00;
        
        pps_freq_cnt1           <= 32'hF423F;
        pps_freq_cnt2           <= 32'h3B9AC9F;
        pps_freq_sel            <= 1'b0;
        
        pulse_int_mask          <= 1'b0;
        eth_int_mask            <= 1'b0;
        pps1_mask               <= 1'b0;
        m6x_uart_rx_mask        <= 1'b1;
        
        tod_time_latch           <= 1'b0;
        
        //debug
        debug_wlen              <= 11'd0;
    end
    else if(  wr_en == 1'b1 ) begin
        case( wr_io_add_r[15:13] )
            CTRL_SPACE : begin
                    case( wr_io_add_r[10:0] )
                        DEBUG_WRLEN     : debug_wlen    <= wr_io_dat_r[10:0];
                    
                    
                        TEST1_ADD       : test1         <= wr_io_dat_r;
                        TEST2_ADD       : test2         <= wr_io_dat_r;
                        
                        PCIE_RST        : pcie_rst_r    <= wr_io_dat_r[0];
                        
                        CLR_DMA_SET     : clr_settings  <= wr_io_dat_r[0];
                        
                        //DMA_WRBASE      : dma_wr_base   <= wr_io_dat_r;
                        DMAWR_ADD_LO    :   dma_wr_base[31:0]   <= wr_io_dat_r;// + 32'h80;	//for test
                        DMAWR_ADD_HI    :   dma_wr_base[63:32]  <= wr_io_dat_r;
                        //DMA_RDBASE      : dma_rd_base   <= wr_io_dat_r;
                        DMARD_ADD_LO    :   dma_rd_base[31:0]   <= wr_io_dat_r;
                        DMARD_ADD_HI    :   dma_rd_base[63:32]  <= wr_io_dat_r;                        
                        
                        DMA_RDLEN       : dma_rd_len    <= wr_io_dat_r;
                        DMA_START       : begin
                                            if( wr_io_dat_r[0] & wr_io_dat_r[8]) 
                                                {dma_wr_start,dma_rd_start}  <= 2'b0;
                                            else 
                                                {dma_rd_start,dma_wr_start}  <= {wr_io_dat_r[8],wr_io_dat_r[0]};
                                        end
                        CLR_DMA_FLAG    : {dma_rddone_clr,dma_wrdone_clr}   <= {wr_io_dat_r[8],wr_io_dat_r[0]};
                        
                        CTRL_UPFLAG_CLR : clr_ctrl_flag                     <= wr_io_dat_r[0];
                        
                        CTRL_DN_CNT     : m6x_uart_down_byte_len            <= {24'd0 , wr_io_dat_r[7:0]};                
                                      
                        CTRL_DN_EN      : m6x_uart_tx_start                 <= {31'd0 , wr_io_dat_r[0]};
                        
                        TOD_FLAG_CLR    : clr_tod                           <= {31'd0 , wr_io_dat_r[0]};
                        
                        ETHUP_BYTE_CNT_CLR : clr_eth                    <= {31'd0 , wr_io_dat_r[0]};
                        
                        PPSFREQ_CNT1    : pps_freq_cnt1         <= wr_io_dat_r;
                        PPSFREQ_CNT2    : pps_freq_cnt2         <= wr_io_dat_r;
                        PPSFREQ_SEL     : pps_freq_sel          <= wr_io_dat_r[0];  
                                  
                        MSI_MASK        : {m6x_uart_rx_mask,pps1_mask,pulse_int_mask,eth_int_mask} <= wr_io_dat_r[3:0];
                        
                        UART_USTOD_LATCH_FLAG : tod_time_latch   <= wr_io_dat_r[0];                        
                        
                        default         : begin
                                            test1               <=  32'haaaa_aaaa_aaaa_aaaa;
                                            test2               <=  32'h5555_5555_5555_5555;
                                            
                                            pcie_rst_r          <=  1'b0;
                                            
                                            clr_settings        <=  1'b0;
                                            dma_wr_base         <=  64'h0;
                                            dma_rd_base         <=  64'h0;
                                            dma_rd_len          <=  32'h0;
                                            dma_wr_start        <=  1'b0;
                                            dma_rd_start        <=  1'b0;  

                                            clr_ctrl_flag       <=  1'b0;
                                            
                                            pps_freq_cnt1           <= 32'hF423F;
                                            pps_freq_cnt2           <= 32'h3B9AC9F;
                                            pps_freq_sel            <= 1'b0;
                                        end
                    endcase
            end
            M6XDN_SPACE : begin
                    m6x_uart_down_tx_we     <= 1'b1;
                    m6x_uart_down_tx_dat    <= wr_io_dat_r;            
            end
                        
            default : begin
				end
            endcase
    end
    else begin
        dma_wr_start                        <= 1'b0;
        dma_rd_start                        <= 1'b0;  
        dma_wrdone_clr                      <= 1'b0;
        dma_rddone_clr                      <= 1'b0;   
        
        m6x_uart_down_tx_we                 <= 1'b0;    
    end
end  

//

reg [1:0]   wrdone_clr;
reg [1:0]   rddone_clr;

reg         wrdone_flag;
reg         rddone_flag;

reg [1:0]   dma_wrdone_r;
reg [1:0]   dma_rddone_r;

wire        wrdone_clr_p;
wire        rddone_clr_p;

wire        dma_wrdone_p;
wire        dma_rddone_p;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        wrdone_clr    <= 2'b0;
    else 
        wrdone_clr    <= {wrdone_clr[0],dma_wrdone_clr};
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        rddone_clr    <= 2'b0;
    else 
        rddone_clr    <= {rddone_clr[0],dma_rddone_clr};
end

assign  wrdone_clr_p = ~wrdone_clr[1] & wrdone_clr[0];
assign  rddone_clr_p = ~rddone_clr[1] & rddone_clr[0];

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        dma_wrdone_r    <= 2'b0;
    else 
        dma_wrdone_r    <= {dma_wrdone_r[0],dma_wrdone};
end    
    
always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        dma_rddone_r    <= 2'b0;
    else 
        dma_rddone_r    <= {dma_rddone_r[0],dma_rddone};
end

assign  dma_wrdone_p = ~dma_wrdone_r[1] & dma_wrdone_r[0];
assign  dma_rddone_p = ~dma_rddone_r[1] & dma_rddone_r[0];

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        wrdone_flag     <= 1'b1;
    else if( wrdone_clr_p == 1'b1 )
        wrdone_flag     <= 1'b0;
    else if( dma_wrdone_p == 1'b1 )
        wrdone_flag     <= 1'b1;
    else
        wrdone_flag     <= wrdone_flag;
end    

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        rddone_flag     <= 1'b1;
    else if( rddone_clr_p == 1'b1 )
        rddone_flag     <= 1'b0;
    else if( dma_rddone_p == 1'b1 )
        rddone_flag     <= 1'b1;
    else
        rddone_flag     <= rddone_flag;
end    

assign  dma_upstream_flag = wrdone_flag;

//reset pcie
reg 			pcie_rst_r;
reg [3:0]   pcie_rst_rr;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) 
        pcie_rst_rr     <= 4'b00;
    else
        pcie_rst_rr     <= {pcie_rst_rr[2:0],pcie_rst_r};
end    
    
assign  pcie_reset = pcie_rst_rr[3] & ~pcie_rst_rr[2];


reg         clr_eth_d;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        clr_eth_d   <= 1'b0;
    else
        clr_eth_d   <= clr_eth;
end 

reg [31:0]      bar_year_month_day_r1;
reg [31:0]      bar_hour_min_sec_r1;
reg [31:0]      bar_nano_sec_r1;
reg [31:0]      bar_year_month_day_r2;
reg [31:0]      bar_hour_min_sec_r2;
reg [31:0]      bar_nano_sec_r2;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )begin
        bar_year_month_day_r1 <= 0;
        bar_hour_min_sec_r1   <= 0;
        bar_nano_sec_r1       <= 0;
    end
    else begin
        bar_year_month_day_r1 <= bar_year_month_day;
        bar_hour_min_sec_r1   <= bar_hour_min_sec;
        bar_nano_sec_r1       <= bar_nano_sec;
    end
end
   
always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )begin
        bar_year_month_day_r2 <= 0;
        bar_hour_min_sec_r2   <= 0;
        bar_nano_sec_r2       <= 0;
    end
    else begin
        bar_year_month_day_r2 <= bar_year_month_day_r1;
        bar_hour_min_sec_r2   <= bar_hour_min_sec_r1;
        bar_nano_sec_r2       <= bar_nano_sec_r1;
    end
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 ) begin
        rd_dat_r              <= 32'h0;
        
        m6x_tod_ram_add     <= 9'd0;
        m6x_uart_ram_add    <= 13'd0;
    end
    else begin
        case( rd_add_r[15:13] )
            CTRL_SPACE : begin
                case( rd_add_r[10:0] )
                    DEBUG_WRLEN     : rd_dat_r    <= {21'd0,debug_wlen};
                
                    TEST1_ADD       : rd_dat_r    <= ~test1;
                    TEST2_ADD       : rd_dat_r    <= ~test2;
                    FPGA_VER        : rd_dat_r    <= {FPGA_VER_HI,FPGA_VER_LO};
           
                    DMAWR_ADD_LO    : rd_dat_r    <=   dma_wr_base[31:0];
                    DMAWR_ADD_HI    : rd_dat_r    <=   dma_wr_base[63:32];

                    DMARD_ADD_LO    : rd_dat_r    <=   dma_rd_base[31:0];
                    DMARD_ADD_HI    : rd_dat_r    <=   dma_rd_base[63:32];                        
           
                    //DMA_WRBASE      : rd_dat_r    <= dma_wr_base;
                    DMA_WRLEN       : rd_dat_r    <= {dma_upstream_len , dma_upstream_len + 16'd16};
                    
                    //DMA_RDBASE      : rd_dat_r    <= dma_rd_base;
                    DMA_RDLEN       : rd_dat_r    <= dma_rd_len;
                    CLR_DMA_FLAG    : rd_dat_r    <= {23'h0,rddone_flag,7'h0,wrdone_flag};
                    
                    ETHUP_BYTE_CNT  : rd_dat_r    <= {16'd0,dma_upstream_len};
                    ETHUP_BYTE_CNT_CLR : rd_dat_r <= {31'h0,clr_eth};
                    
                    //M6x
                    CTRL_UP_CNT     : rd_dat_r    <= {19'd0,m6x_ctrl_len};
                    CTRL_UP_FLAG    : rd_dat_r    <= {31'h0,m6x_ctrl_flag[1]};
                    CTRL_UPFLAG_CLR : rd_dat_r    <= {31'h0,clr_ctrl_flag};
                    
                    CTRL_DN_CNT     : rd_dat_r    <= {24'd0,m6x_uart_down_byte_len};
                    CTRL_DN_EN      : rd_dat_r    <= {31'd0,m6x_uart_tx_start};
                    CTRL_TX_BUSY    : rd_dat_r    <= {31'd0,m6x_down_busy};
                    
                    //TOD
                    TOD_BYTE_CNT    : rd_dat_r    <= {23'h0,tod_len_rr};
                    TOD_FLAG        : rd_dat_r    <= {31'h0,tod_flag_r[1]};
                    TOD_FLAG_CLR    : rd_dat_r    <= {31'h0,m6x_tod_ram_data_flag_clr};
                    
                    UART_USTOD_LATCH_FLAG : rd_dat_r <= {31'h0 , tod_time_latch};
                    TOD_YEAR_MONTH_DAY    : rd_dat_r <= bar_year_month_day_r2;
                    TOD_HOUR_MIN_SEC      : rd_dat_r <= bar_hour_min_sec_r2;
                    UART_NSTOD_CNT        : rd_dat_r <= bar_nano_sec_r2;
                    
                    //PPS FREQ CNT
                    PPSFREQ_CNT1    : rd_dat_r    <= pps_freq_cnt1;
                    PPSFREQ_CNT2    : rd_dat_r    <= pps_freq_cnt2;
                    PPSFREQ_SEL     : rd_dat_r    <= pps_freq_sel;
                    
                    MSI_MASK        : rd_dat_r    <= {28'h0,m6x_uart_rx_mask,pps1_mask,pulse_int_mask,eth_int_mask};
                    
                    default         : rd_dat_r    <= 32'h0; 
                endcase
            end
            TOD_SPACE : begin
                m6x_tod_ram_add     <= rd_add_r[8:0];
                rd_dat_r              <= m6x_tod_ram_dat;
            end
            M6XDN_SPACE : begin
                rd_dat_r              <= m6x_uart_down_tx_dat_i;
            end
            M6XUP_SPACE : begin
                m6x_uart_ram_add    <= rd_add_r[12:0];
                rd_dat_r              <= m6x_uart_ram_dat;
            end
            default : begin
                ;
            end
            endcase
    end
end    


always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        m6x_uart_down_tx_add    <= 8'h00;
    else if( ( wr_io_add_r[15:13] == M6XDN_SPACE ) && ( wr_en == 1'b1 ) )
        m6x_uart_down_tx_add    <= wr_io_add_r[7:0];
    else if( rd_add_r[15:13] == M6XDN_SPACE )
        m6x_uart_down_tx_add    <= rd_add_r[7:0];
    else
        m6x_uart_down_tx_add    <= m6x_uart_down_tx_add;
end    


assign  downstream_len = dma_rd_len[10:0];

assign  uart_ustod_latch_flag    = tod_time_latch;

assign  rd_dat = { rd_dat_r[7:0] , rd_dat_r[15:8] , rd_dat_r[23:16] , rd_dat_r[31:24]};

endmodule 

