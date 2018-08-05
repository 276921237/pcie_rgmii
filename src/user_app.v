
`timescale	1ns/1ps



module user_app(
				input				    user_clk,
				input				    user_reset,

				input				    user_lnk_up,
				
				//test
                inout [35:0]	CONTROL0,
		        inout [35:0]	CONTROL1,
					 
                input [15:0]            completer_id_i,
                input [2:0]             max_req_size,
				
                //pcie intr
                input [2:0]             cfg_interrupt_mmenable,
                input                   cfg_interrupt_msienable,                
				input				    cfg_interrupt_rdy,
				output				    cfg_interrupt,
                output [7:0]            cfg_interrupt_di,
				
				input				s_axis_tx_tready,
				output [31:0]		s_axis_tx_tdata,
				output [3:0]		s_axis_tx_tkeep,
				output [3:0]		s_axis_tx_tuser,  //4'b0000
				output				s_axis_tx_tlast,
				output				s_axis_tx_tvalid,

				input [31:0]		m_axis_rx_tdata,
				input [3:0]			m_axis_rx_tkeep,
				input 				m_axis_rx_tlast,
				input 				m_axis_rx_tvalid,
				output 				m_axis_rx_tready,
				input [16:0]		m_axis_rx_tuser, //[1] -- packet is error	
                
                //
                //input               clk_1m,
                input               clk_125m,
                input               pps,

					//upstream ram interface
					input [7:0]		ram_data_flag,
					output [7:0]	ram_data_flag_clr,
					
					//0
					input [10:0]	ram_dat_len0,
					output 			eth_ram_clk0,
					output			eth_ram_we0,
					output			eth_ram_en0,
					output [10:0]	eth_ram_add0,
					input [31:0]	eth_ram_dat0,
					
					output 			ts_ram_clk0,
					output			ts_ram_we0,
					output			ts_ram_en0,
					output [3:0]	ts_ram_add0,
					input [31:0]	ts_ram_dat0,
					//1
					input [10:0]	ram_dat_len1,
					output 			eth_ram_clk1,
					output			eth_ram_we1,
					output			eth_ram_en1,
					output [10:0]	eth_ram_add1,
					input [31:0]	eth_ram_dat1,
					
					output 			ts_ram_clk1,
					output			ts_ram_we1,
					output			ts_ram_en1,
					output [3:0]	ts_ram_add1,
					input [31:0]	ts_ram_dat1,
					//2
					input [10:0]	ram_dat_len2,
					output 			eth_ram_clk2,
					output			eth_ram_we2,
					output			eth_ram_en2,
					output [10:0]	eth_ram_add2,
					input [31:0]	eth_ram_dat2,
					
					output 			ts_ram_clk2,
					output			ts_ram_we2,
					output			ts_ram_en2,
					output [3:0]	ts_ram_add2,
					input [31:0]	ts_ram_dat2,					
					//3
					input [10:0]	ram_dat_len3,
					output 			eth_ram_clk3,
					output			eth_ram_we3,
					output			eth_ram_en3,
					output [10:0]	eth_ram_add3,
					input [31:0]	eth_ram_dat3,
					
					output 			ts_ram_clk3,
					output			ts_ram_we3,
					output			ts_ram_en3,
					output [3:0]	ts_ram_add3,
					input [31:0]	ts_ram_dat3,
					//4
					input [10:0]	ram_dat_len4,
					output 			eth_ram_clk4,
					output			eth_ram_we4,
					output			eth_ram_en4,
					output [10:0]	eth_ram_add4,
					input [31:0]	eth_ram_dat4,
					
					output 			ts_ram_clk4,
					output			ts_ram_we4,
					output			ts_ram_en4,
					output [3:0]	ts_ram_add4,
					input [31:0]	ts_ram_dat4,
					//5
					input [10:0]	ram_dat_len5,
					output 			eth_ram_clk5,
					output			eth_ram_we5,
					output			eth_ram_en5,
					output [10:0]	eth_ram_add5,
					input [31:0]	eth_ram_dat5,
					
					output 			ts_ram_clk5,
					output			ts_ram_we5,
					output			ts_ram_en5,
					output [3:0]	ts_ram_add5,
					input [31:0]	ts_ram_dat5,
					//6
					input [10:0]	ram_dat_len6,
					output 			eth_ram_clk6,
					output			eth_ram_we6,
					output			eth_ram_en6,
					output [10:0]	eth_ram_add6,
					input [31:0]	eth_ram_dat6,
					
					output 			ts_ram_clk6,
					output			ts_ram_we6,
					output			ts_ram_en6,
					output [3:0]	ts_ram_add6,
					input [31:0]	ts_ram_dat6,	
					//7
					input [10:0]	ram_dat_len7,
					output 			eth_ram_clk7,
					output			eth_ram_we7,
					output			eth_ram_en7,
					output [10:0]	eth_ram_add7,
					input [31:0]	eth_ram_dat7,
					
					output 			ts_ram_clk7,
					output			ts_ram_we7,
					output			ts_ram_en7,
					output [3:0]	ts_ram_add7,
					input [31:0]	ts_ram_dat7,	
					
					//downstream
					output			ram_tx_start,
					output			ram_tx_end,
					output [10:0]	ram_byte_len,
					input			tx_completed,
					
					output			ram_tx_clk,
					output			ram_tx_we,
					output			ram_tx_en,
					output [10:0]	ram_tx_add,
					output [31:0]	ram_tx_dat,

                    //uart controll interface
                    //upstream
                    input           m6x_uart_ram_data_flag,
                    output          m6x_uart_ram_data_flag_clr,
                    input  [12:0]   m6x_uart_ram_dat_len,
                    
                    output          m6x_uart_ram_clk,
                    output          m6x_uart_ram_we,
                    output          m6x_uart_ram_en,
                    output [12:0]   m6x_uart_ram_add,
                    input  [31:0]   m6x_uart_ram_dat,
                    
                    //down
                    output          m6x_uart_tx_start,
                    output          m6x_uart_tx_end,
                    output [7:0]    m6x_uart_down_byte_len,
                    input           m6x_uart_down_tx_completed,
                    
                    output          m6x_uart_down_tx_clk,
                    output          m6x_uart_down_tx_we,
                    output          m6x_uart_down_tx_en,
                    output [7:0]    m6x_uart_down_tx_add,
                    output [31:0]   m6x_uart_down_tx_dat,
                    input [31:0]    m6x_uart_down_tx_dat_i,
                    
                    //TOD
                    input           m6x_tod_ram_data_flag,
                    output          m6x_tod_ram_data_flag_clr,
                    input [8:0]     m6x_tod_ram_data_len,
                    
                    output          m6x_tod_ram_clk,
                    output          m6x_tod_ram_we,
                    output          m6x_tod_ram_en,
                    output [8:0]    m6x_tod_ram_add,
                    input [31:0]    m6x_tod_ram_dat,
                    
                    output          uart_ustod_latch_flag,
                    input [31:0]    bar_year_month_day,
                    input [31:0]    bar_hour_min_sec,
                    input [31:0]    bar_nano_sec
				);

//wire [31:0]			m_axis_rx_tdata;
//wire [3:0]          m_axis_rx_tkeep;
//wire                m_axis_rx_tlast;
//wire                m_axis_rx_tvalid;
//wire                m_axis_rx_tready;
//wire [16:0]			m_axis_rx_tuser; //[1] -- packet is error    
//
//wire                s_axis_tx_tready;
//wire [31:0]         s_axis_tx_tdata;
//wire [3:0]          s_axis_tx_tkeep;
//wire                s_axis_tx_tlast;
//wire                s_axis_tx_tvalid;      
//wire [3:0]          s_axis_tx_tuser;      

wire [10:0]         downstream_len;

wire [7:0]		    wr_io_be;
wire [15:0]		    wr_io_add;
wire [31:0]		    wr_io_dat;
wire                wr_io_en;

wire [31:0]      	req_addr;
wire [2:0]       	req_tc;
wire				req_td;
wire            	req_ep;
wire [1:0]       	req_attr;
wire [9:0]       	req_len;
wire [15:0]      	req_rid;
wire [7:0]       	req_tag;
wire [7:0]       	req_be;
wire				req_compl;
wire                req_compld;

wire                compl_done;  

wire [31:0]         rd_data;
wire [15:0]         rd_addr;           

wire                dma_wrdone;      

wire                dmard_start;
wire [10:0]         dmard_len;  
wire [63:0]         dmard_add;  

wire                dmawr_start;
wire [10:0]         dmawr_len;  
wire [63:0]         dmawr_add;      

wire                buf_rst;
wire                buf_rd;
wire [31:0]         buf_dat;   
                
ram_sel ram_sel_inst (
                        .user_clk           (user_clk), 
                        .user_reset         (user_reset), 
                        
                        .dma_wrdone         (dma_wrdone), 
                        .dmawr_len			(dmawr_len),
                        
                        .buf_rst            (buf_rst), 
                        .buf_rd             (buf_rd), 
                        .buf_dat            (buf_dat), 
                        
                        .ram_data_flag      (ram_data_flag), 
                        .ram_data_flag_clr  (ram_data_flag_clr), 
                        
                        .ram_dat_len0       (ram_dat_len0), 
                        .eth_ram_clk0       (eth_ram_clk0), 
                        .eth_ram_we0        (eth_ram_we0), 
                        .eth_ram_en0        (eth_ram_en0), 
                        .eth_ram_add0       (eth_ram_add0), 
                        .eth_ram_dat0       (eth_ram_dat0), 
                        .ts_ram_clk0        (ts_ram_clk0), 
                        .ts_ram_we0         (ts_ram_we0), 
                        .ts_ram_en0         (ts_ram_en0), 
                        .ts_ram_add0        (ts_ram_add0), 
                        .ts_ram_dat0        (ts_ram_dat0), 
                        
                        .ram_dat_len1       (ram_dat_len1), 
                        .eth_ram_clk1       (eth_ram_clk1), 
                        .eth_ram_we1        (eth_ram_we1), 
                        .eth_ram_en1        (eth_ram_en1), 
                        .eth_ram_add1       (eth_ram_add1), 
                        .eth_ram_dat1       (eth_ram_dat1), 
                        .ts_ram_clk1        (ts_ram_clk1), 
                        .ts_ram_we1         (ts_ram_we1), 
                        .ts_ram_en1         (ts_ram_en1), 
                        .ts_ram_add1        (ts_ram_add1), 
                        .ts_ram_dat1        (ts_ram_dat1), 
                        
                        .ram_dat_len2       (ram_dat_len2), 
                        .eth_ram_clk2       (eth_ram_clk2), 
                        .eth_ram_we2        (eth_ram_we2), 
                        .eth_ram_en2        (eth_ram_en2), 
                        .eth_ram_add2       (eth_ram_add2), 
                        .eth_ram_dat2       (eth_ram_dat2), 
                        .ts_ram_clk2        (ts_ram_clk2), 
                        .ts_ram_we2         (ts_ram_we2), 
                        .ts_ram_en2         (ts_ram_en2), 
                        .ts_ram_add2        (ts_ram_add2), 
                        .ts_ram_dat2        (ts_ram_dat2), 
                        
                        .ram_dat_len3       (ram_dat_len3), 
                        .eth_ram_clk3       (eth_ram_clk3), 
                        .eth_ram_we3        (eth_ram_we3), 
                        .eth_ram_en3        (eth_ram_en3), 
                        .eth_ram_add3       (eth_ram_add3), 
                        .eth_ram_dat3       (eth_ram_dat3), 
                        .ts_ram_clk3        (ts_ram_clk3), 
                        .ts_ram_we3         (ts_ram_we3), 
                        .ts_ram_en3         (ts_ram_en3), 
                        .ts_ram_add3        (ts_ram_add3), 
                        .ts_ram_dat3        (ts_ram_dat3), 
                        
                        .ram_dat_len4       (ram_dat_len4), 
                        .eth_ram_clk4       (eth_ram_clk4), 
                        .eth_ram_we4        (eth_ram_we4), 
                        .eth_ram_en4        (eth_ram_en4), 
                        .eth_ram_add4       (eth_ram_add4), 
                        .eth_ram_dat4       (eth_ram_dat4), 
                        .ts_ram_clk4        (ts_ram_clk4), 
                        .ts_ram_we4         (ts_ram_we4), 
                        .ts_ram_en4         (ts_ram_en4), 
                        .ts_ram_add4        (ts_ram_add4), 
                        .ts_ram_dat4        (ts_ram_dat4), 
                        
                        .ram_dat_len5       (ram_dat_len5), 
                        .eth_ram_clk5       (eth_ram_clk5), 
                        .eth_ram_we5        (eth_ram_we5), 
                        .eth_ram_en5        (eth_ram_en5), 
                        .eth_ram_add5       (eth_ram_add5), 
                        .eth_ram_dat5       (eth_ram_dat5), 
                        .ts_ram_clk5        (ts_ram_clk5), 
                        .ts_ram_we5         (ts_ram_we5), 
                        .ts_ram_en5         (ts_ram_en5), 
                        .ts_ram_add5        (ts_ram_add5), 
                        .ts_ram_dat5        (ts_ram_dat5), 
                        
                        .ram_dat_len6       (ram_dat_len6), 
                        .eth_ram_clk6       (eth_ram_clk6), 
                        .eth_ram_we6        (eth_ram_we6), 
                        .eth_ram_en6        (eth_ram_en6), 
                        .eth_ram_add6       (eth_ram_add6), 
                        .eth_ram_dat6       (eth_ram_dat6), 
                        .ts_ram_clk6        (ts_ram_clk6), 
                        .ts_ram_we6         (ts_ram_we6), 
                        .ts_ram_en6         (ts_ram_en6), 
                        .ts_ram_add6        (ts_ram_add6), 
                        .ts_ram_dat6        (ts_ram_dat6), 
                        
                        .ram_dat_len7       (ram_dat_len7), 
                        .eth_ram_clk7       (eth_ram_clk7), 
                        .eth_ram_we7        (eth_ram_we7), 
                        .eth_ram_en7        (eth_ram_en7), 
                        .eth_ram_add7       (eth_ram_add7), 
                        .eth_ram_dat7       (eth_ram_dat7), 
                        .ts_ram_clk7        (ts_ram_clk7), 
                        .ts_ram_we7         (ts_ram_we7), 
                        .ts_ram_en7         (ts_ram_en7), 
                        .ts_ram_add7        (ts_ram_add7), 
                        .ts_ram_dat7        (ts_ram_dat7)
                        );    

wire [31:0]     pps_freq_cnt1;
wire [31:0]     pps_freq_cnt2;
wire            pps_freq_sel;
wire            pulse;

wire            dma_upstream_flag;
wire            pcie_reset;
wire            pulse_int_mask;
wire            eth_int_mask;

wire  [10:0]    debug_wrlen;
wire            pps1_mask;
wire            m6x_uart_rx_mask;
wire            upstream_start;

pulse_gen pulse_gen (
                    .user_clk               ( user_clk      ), 
                    .user_reset             ( user_reset    ), 
                    .clk_125m               ( clk_125m      ), 
                                              
                    .pps                    ( pps           ), 
                    .pps_freq_cnt1          ( pps_freq_cnt1 ), 
                    .pps_freq_cnt2          ( pps_freq_cnt2 ), 
                    .pps_freq_sel           ( pps_freq_sel  ), 
                    .pulse                  ( pulse         )
                    );
                        
                
msi_gen     msi_gen (
								 .user_clk				( user_clk          ), 
								 .reset					( user_reset        ), 
                                                          
                                 //1PPS int               
                                 .nonprogramable_pps    ( pps               ),
                                 .pps                   ( pulse             ),
                                                          
                                 .pulse_int_mask        ( pulse_int_mask    ),
                                 .eth_int_mask          ( eth_int_mask      ),
                                 .pps1_mask             ( pps1_mask         ),
                                                          
                                 .m6x_uart_rx_flag      ( m6x_uart_ram_data_flag),
                                 .m6x_uart_rx_mask      ( m6x_uart_rx_mask  ),
                                 
								 //for debug
								 .ram_tx_end			    ( ram_tx_end ),
											
                                 //GMII int
								 .dat_flag				( ram_data_flag     ), 
								 .dma_upstream_done	    ( dma_wrdone        ), 
                                 .dma_upstream_flag     ( dma_upstream_flag ), //from bar
                                 .upstream_start        ( upstream_start    ),
                                 
                                 //down stream finished
                                 .pcie2pc_completed     ( dma_wrdone        ),  //dma_wrdone
                                 .pc2pcie_completed     ( tx_completed      ),
                                 
                                 .err                   ( err ),
                                 .cfg_interrupt_mmenable    ( cfg_interrupt_mmenable),
                                 .cfg_interrupt_msienable   ( cfg_interrupt_msienable),
								 .cfg_interrupt		    ( cfg_interrupt     ), 
								 .cfg_interrupt_rdy	    ( cfg_interrupt_rdy ), 
								 .cfg_interrupt_di	    ( cfg_interrupt_di  )
								 );


                                 
                                 
pcie_rx pcie_rx_inst (
                        .user_clk           ( user_clk                  ), 
                        .user_reset         ( user_reset | pcie_reset   ), 
                        
                        //.pcie_reset         (pcie_reset),
								
						//test
						.CONTROL							(CONTROL0),//
                        
                        .m_axis_rx_tdata    ( m_axis_rx_tdata   ), 
                        .m_axis_rx_tkeep    ( m_axis_rx_tkeep   ), 
                        .m_axis_rx_tlast    ( m_axis_rx_tlast   ), 
                        .m_axis_rx_tvalid   ( m_axis_rx_tvalid  ), 
                        .m_axis_rx_tready   ( m_axis_rx_tready  ), 
                        .m_axis_rx_tuser    ( m_axis_rx_tuser   ), 
                                              
                        .req_addr_o         ( req_addr          ), 
                        .req_tc_o           ( req_tc            ), 
                        .req_td_o           ( req_td            ), 
                        .req_ep_o           ( req_ep            ), 
                        .req_attr_o         ( req_attr          ), 
                        .req_len_o          ( req_len           ), 
                        .req_rid_o          ( req_rid           ), 
                        .req_tag_o          ( req_tag           ), 
                        .req_be_o           ( req_be            ), 
                                              
                        .req_compl_o        ( req_compl         ), 
                        .req_compld_o       ( req_compld        ), 
                        .compl_done_i       ( compl_done        ), 
                        
                        // .wr_io_be           (wr_io_be), 
                        // .wr_io_add          (wr_io_add), 
                        // .wr_io_dat          (wr_io_dat), 
                        // .wr_io_en           (wr_io_en), 
                        
                        .wrbar_be           (wr_io_be),
                        .wrbar_add          (wr_io_add),
                        .wrbar_dat          (wr_io_dat),
                        .wrbar_en           (wr_io_en),                        
								
                        .dma_byte_len       (dmard_len), 
                        
                        .ram_tx_start       (ram_tx_start), 
                        .ram_tx_end         (ram_tx_end), 
                        .ram_byte_len       (ram_byte_len), 
                        .ram_tx_clk         (ram_tx_clk), 
                        .ram_tx_we          (ram_tx_we), 
                        .ram_tx_en          (ram_tx_en), 
                        .ram_tx_add         (ram_tx_add), 
                        .ram_tx_dat         (ram_tx_dat)
                        );
                        
pcie_tx pcie_tx (
                        .clk                (user_clk), 
                        .rst_n              (~user_reset), 
                        
                        .pcie_reset         (pcie_reset),
                        
                        .CONTROL            (), //
                        
                        .mwr_64b_add_en     (1'b0),	//
                        
                        .max_req_size       ( max_req_size   ),
                                              
                        .s_axis_tx_tready   ( s_axis_tx_tready), 
                        .s_axis_tx_tdata    ( s_axis_tx_tdata), 
                        .s_axis_tx_tkeep    ( s_axis_tx_tkeep), 
                        .s_axis_tx_tlast    ( s_axis_tx_tlast), 
                        .s_axis_tx_tvalid   ( s_axis_tx_tvalid), //
                        .s_axis_tx_tuser    ( s_axis_tx_tuser),
                                              
                        .req_compl_i        ( req_compl     ), 
                        .req_compld_i       ( req_compld    ), 
                        .compl_done_o       ( compl_done    ), 
                        .req_tc_i           ( req_tc        ), 
                        .req_td_i           ( req_td        ), 
                        .req_ep_i           ( req_ep        ), 
                        .req_attr_i         ( req_attr      ), 
                        .req_len_i          ( req_len       ), 
                        .req_rid_i          ( req_rid       ), 
                        .req_tag_i          ( req_tag       ), 
                        .req_be_i           ( req_be        ), 
                        .req_addr_i         ( req_addr      ), 
                                              
                        .completer_id_i     ( completer_id_i),
                        //PIO
                        .rd_addr_o          ( rd_addr       ), 
                        .rd_data_i          ( rd_data       ), 
                        
                        //DMA
                        .dmard_start        ( dmard_start   ),
                        .dmard_len          ( dmard_len     ),  //bytes
                        .dmard_add          ( dmard_add     ),
                                              
                        .dmawr_start        ( dmawr_start   ),
                        .dmawr_len          ( debug_wrlen   ),  // DEBUG   dmawr_len
                        .dmawr_add          ( dmawr_add ),
                        .dmawr_completed    ( dma_wrdone), //single c
                                              
                        .dmawr_rdfifo_rst   ( buf_rst   ),
                        .dmawr_rdfifo_en    ( buf_rd    ),
                        .dmawr_rdfifo_dat   ( buf_dat   )                     
                        );     


// Instantiate the module
bar_space bar_space_inst (
                                .user_clk				(user_clk), 
                                .user_reset             (user_reset), 

                                .wr_io_be				(wr_io_be), 
                                .wr_io_add				(wr_io_add), 
                                .wr_io_dat				(wr_io_dat), 
                                .wr_io_en				(wr_io_en), 
                                
                                .rd_req                 (req_compld),        /////
                                .rd_add                 (rd_addr), 
                                .rd_dat                 (rd_data), 
                                 
                                .dma_wr_base            (dmawr_add),
                                .dma_rd_base            (dmard_add),
                                .dma_wr_start           (dmawr_start),
                                .dma_rd_start           (dmard_start),                                  

                                .upstream_start         (upstream_start ), //when send a msi ,rise edge 
                                
                                //debug
                                .debug_wlen             (debug_wrlen),
                                
                                .upstream_len           (dmawr_len), 
                                .downstream_len		    (dmard_len), 
                                .dma_wrdone			    (dma_wrdone), 
                                .dma_rddone			    (tx_completed),
                                
                                .dma_upstream_flag      (dma_upstream_flag),
                                
                                .pulse_int_mask         (pulse_int_mask),
                                .eth_int_mask           (eth_int_mask),
                                .pps1_mask              (pps1_mask),
                                .m6x_uart_rx_mask       (m6x_uart_rx_mask),

                                .m6x_uart_ram_data_flag     (m6x_uart_ram_data_flag), 
                                .m6x_uart_ram_data_flag_clr (m6x_uart_ram_data_flag_clr), 
                                .m6x_uart_ram_dat_len       (m6x_uart_ram_dat_len), 
                                .m6x_uart_ram_clk           (m6x_uart_ram_clk), 
                                .m6x_uart_ram_we            (m6x_uart_ram_we), 
                                .m6x_uart_ram_en            (m6x_uart_ram_en), 
                                .m6x_uart_ram_add           (m6x_uart_ram_add), 
                                .m6x_uart_ram_dat           (m6x_uart_ram_dat), 
                                .m6x_uart_tx_start          (m6x_uart_tx_start), 
                                .m6x_uart_tx_end            (m6x_uart_tx_end), 
                                
                                .m6x_uart_down_byte_len     (m6x_uart_down_byte_len), 
                                .m6x_uart_down_tx_completed (m6x_uart_down_tx_completed), 
                                .m6x_uart_down_tx_clk       (m6x_uart_down_tx_clk), 
                                .m6x_uart_down_tx_we        (m6x_uart_down_tx_we), 
                                .m6x_uart_down_tx_en        (m6x_uart_down_tx_en), 
                                .m6x_uart_down_tx_add       (m6x_uart_down_tx_add), 
                                .m6x_uart_down_tx_dat       (m6x_uart_down_tx_dat), 
                                .m6x_uart_down_tx_dat_i     (m6x_uart_down_tx_dat_i), 
                                
                                .m6x_tod_ram_data_flag      (m6x_tod_ram_data_flag), 
                                .m6x_tod_ram_data_flag_clr  (m6x_tod_ram_data_flag_clr), 
                                .m6x_tod_ram_data_len       (m6x_tod_ram_data_len), 
                                .m6x_tod_ram_clk            (m6x_tod_ram_clk), 
                                .m6x_tod_ram_we             (m6x_tod_ram_we), 
                                .m6x_tod_ram_en             (m6x_tod_ram_en), 
                                .m6x_tod_ram_add            (m6x_tod_ram_add), 
                                .m6x_tod_ram_dat            (m6x_tod_ram_dat), 
                                
                                .uart_ustod_latch_flag      (uart_ustod_latch_flag),
                                .bar_year_month_day         (bar_year_month_day),
                                .bar_hour_min_sec           (bar_hour_min_sec),
                                .bar_nano_sec               (bar_nano_sec),

                                .pps_freq_cnt1              (pps_freq_cnt1), 
                                .pps_freq_cnt2              (pps_freq_cnt2), 
                                .pps_freq_sel               (pps_freq_sel), 
                                .pcie_reset                 (pcie_reset)
    );


endmodule
