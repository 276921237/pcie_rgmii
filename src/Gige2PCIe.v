
module Gige2PCIe(
					output			link_up,

					//input				clk_1m,
					input				clk_125m,
					input				pps,
					
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
						  input [31:0]		m6x_uart_down_tx_dat_i,
                    
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
                    input [31:0]    bar_nano_sec,
    
					//pcie interface
					input			pcie_rst,
					
					input			refclk_p,
					input			refclk_n,
					
					output			pcie_txp,
					output			pcie_txn,
					
					input			pcie_rxp,
					input			pcie_rxn
										
					);

localparam PCI_EXP_EP_OUI    = 24'h000A35;
localparam PCI_EXP_EP_DSN_1  = {{8'h1},PCI_EXP_EP_OUI};
localparam PCI_EXP_EP_DSN_2  = 32'h00000001;

wire			refclk;
	
wire			user_lnk_up;
wire			user_clk;
wire			user_reset;

wire [7:0]    	cfg_bus_number;
wire [4:0]    	cfg_device_number;
wire [2:0]    	cfg_function_number;

wire [15:0]		completer_id;
wire [63:0]		cfg_dsn;

wire [15:0]		cfg_command;
wire [15:0]		cfg_dcommand;
wire [15:0]		cfg_lstatus;
wire [15:0]		cfg_lcommand;
wire			cfg_bus_mstr_enable;

wire        	cfg_ext_tag_en;
wire  [5:0] 	cfg_neg_max_lnk_width;
wire  [2:0] 	cfg_prg_max_payload_size;
wire  [2:0] 	cfg_max_rd_req_size;
wire        	cfg_rd_comp_bound;

wire			cfg_interrupt_rdy;
wire			cfg_interrupt;

wire			s_axis_tx_tready;
wire [31:0]		s_axis_tx_tdata;
wire [3:0]		s_axis_tx_tkeep;
wire [3:0]		s_axis_tx_tuser;  //4'b0000
wire			s_axis_tx_tlast;
wire			s_axis_tx_tvalid;

wire [31:0]		m_axis_rx_tdata;
wire [3:0]		m_axis_rx_tkeep;
wire 			m_axis_rx_tlast;
wire 			m_axis_rx_tvalid;
wire 			m_axis_rx_tready;
wire [16:0]		m_axis_rx_tuser; //[1] -- packet is error

 
wire [2:0]      cfg_interrupt_mmenable;
wire            cfg_interrupt_msienable;
wire [7:0]      cfg_interrupt_di;

wire				pcie_rst_n;

IBUFDS refclk_ibuf (
					.O		(refclk), 
					.I		(refclk_p), 
					.IB		(refclk_n)
					);
					
IBUF   sys_reset_n_ibuf (.O(pcie_rst_n), .I(pcie_rst));					


assign	completer_id 		    = {cfg_bus_number,cfg_device_number,cfg_function_number};					
assign 	cfg_dsn 				= {PCI_EXP_EP_DSN_2, PCI_EXP_EP_DSN_1};
assign 	cfg_bus_mstr_enable 	= cfg_command[2];
assign	cfg_ext_tag_en			= cfg_dcommand[8];
assign  cfg_neg_max_lnk_width	= cfg_lstatus[9:4];
assign	cfg_prg_max_payload_size= cfg_dcommand[7:5];
assign	cfg_max_rd_req_size		= cfg_dcommand[14:12];
assign	cfg_rd_comp_bound		= cfg_lcommand[3];


wire [255:0]	TRIG0;
wire[35:0]		CONTROL0;
wire[35:0]		CONTROL1;


assign	link_up = user_lnk_up;

/*
icon_ila icon_inst (
						 .CONTROL0(CONTROL0) // INOUT BUS [35:0]
						 //.CONTROL1(CONTROL1) // INOUT BUS [35:0]
					);
*/

//ila_grab ila_0 (
//						 .CONTROL		(CONTROL0), // INOUT BUS [35:0]
//						 .CLK				(user_clk), // IN
//						 .TRIG0			({completer_id,cfg_bus_mstr_enable,
//												cfg_prg_max_payload_size,cfg_max_rd_req_size,
//												cfg_interrupt_mmenable,cfg_interrupt_msienable}) // IN BUS [255:0]
//					);

user_app user_app (
                        .user_clk                   (user_clk), 
                        .user_reset                 (user_reset), 
                        .user_lnk_up                (user_lnk_up), 
                        
								.CONTROL0						(CONTROL0),
								.CONTROL1						(CONTROL1),
								
                        .completer_id_i             (completer_id), 
                        .max_req_size               (cfg_max_rd_req_size),
                        
                        .cfg_interrupt_mmenable     (cfg_interrupt_mmenable), 
                        .cfg_interrupt_msienable    (cfg_interrupt_msienable), 
                        .cfg_interrupt_rdy          (cfg_interrupt_rdy), 
                        .cfg_interrupt              (cfg_interrupt), 
                        .cfg_interrupt_di           (cfg_interrupt_di), 
                        
                        .s_axis_tx_tready           (s_axis_tx_tready), 
                        .s_axis_tx_tdata            (s_axis_tx_tdata), 
                        .s_axis_tx_tkeep            (s_axis_tx_tkeep), 
                        .s_axis_tx_tuser            (s_axis_tx_tuser), 
                        .s_axis_tx_tlast            (s_axis_tx_tlast), 
                        .s_axis_tx_tvalid           (s_axis_tx_tvalid),
                        
                        .m_axis_rx_tdata            (m_axis_rx_tdata), 
                        .m_axis_rx_tkeep            (m_axis_rx_tkeep), 
                        .m_axis_rx_tlast            (m_axis_rx_tlast), 
                        .m_axis_rx_tvalid           (m_axis_rx_tvalid), 
                        .m_axis_rx_tready           (m_axis_rx_tready), 
                        .m_axis_rx_tuser            (m_axis_rx_tuser), 
                        
                        //.clk_1m                     (clk_1m), 
                        .clk_125m                   (clk_125m), 
                        .pps                        (pps), 
                        
                        .ram_data_flag              (ram_data_flag), 
                        .ram_data_flag_clr          (ram_data_flag_clr), 
                        
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
                        .ts_ram_dat7        (ts_ram_dat7),
                        
                        .ram_tx_start       (ram_tx_start), 
                        .ram_tx_end         (ram_tx_end), 
                        .ram_byte_len       (ram_byte_len), 
                        .tx_completed       (tx_completed), 
                        .ram_tx_clk         (ram_tx_clk), 
                        .ram_tx_we          (ram_tx_we), 
                        .ram_tx_en          (ram_tx_en), 
                        .ram_tx_add         (ram_tx_add), 
                        .ram_tx_dat         (ram_tx_dat), 
                        
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
                        .bar_nano_sec               (bar_nano_sec)
                        );

pcie_gen1 pcie_gen1x1 (
						// PCI Express (PCI_EXP) Fabric Interface
						.pci_exp_txp                        ( pcie_txp                 ),
						.pci_exp_txn                        ( pcie_txn                 ),
						.pci_exp_rxp                        ( pcie_rxp                 ),
						.pci_exp_rxn                        ( pcie_rxn                 ),

						// Transaction (TRN) Interface
						// Common clock & reset
						.user_lnk_up                        ( user_lnk_up                 ),
						.user_clk_out                       ( user_clk                    ),
						.user_reset_out                     ( user_reset                  ),
						// Common flow control
						.fc_sel                             (3'b0),
						.fc_nph                             (),
						.fc_npd                             (),
						.fc_ph                              (),
						.fc_pd                              (),
						.fc_cplh                            (),
						.fc_cpld                            (),

						// Transaction Tx
						.s_axis_tx_tready                   ( s_axis_tx_tready            ),
						.s_axis_tx_tdata                    ( s_axis_tx_tdata             ),
						.s_axis_tx_tkeep                    ( s_axis_tx_tkeep             ),
						.s_axis_tx_tuser                    ( s_axis_tx_tuser             ),
						.s_axis_tx_tlast                    ( s_axis_tx_tlast             ),
						.s_axis_tx_tvalid                   ( s_axis_tx_tvalid            ),
						.tx_err_drop                        (                   ),
						.tx_buf_av                          (                    ),
						.tx_cfg_req                         (                    ),
						.tx_cfg_gnt                         ( 1'b1                  ),

						// Transaction Rx
						.m_axis_rx_tdata                    ( m_axis_rx_tdata             ),
						.m_axis_rx_tkeep                    ( m_axis_rx_tkeep             ),
						.m_axis_rx_tlast                    ( m_axis_rx_tlast             ),
						.m_axis_rx_tvalid                   ( m_axis_rx_tvalid            ),
						.m_axis_rx_tready                   ( m_axis_rx_tready            ),
						.m_axis_rx_tuser                    ( m_axis_rx_tuser             ),
						.rx_np_ok                           ( 1'b1                    ),


						// Configuration (CFG) Interface
						// Configuration space access
						.cfg_do                             (                       ),
						.cfg_rd_wr_done                     (               ),
						.cfg_dwaddr                         ( 'd0                  ),
						.cfg_rd_en                          ( 1'b0                   ),
						// Error reporting
						.cfg_err_ur                         ( 1'b0                  ),
						.cfg_err_cor                        ( 1'b0                 ),
						.cfg_err_ecrc                       ( 1'b0                ),
						.cfg_err_cpl_timeout                ( 1'b0         ),
						.cfg_err_cpl_abort                  ( 1'b0           ),
						.cfg_err_posted                     ( 1'b1              ),
						.cfg_err_locked                     ( 1'b0              ),
						.cfg_err_tlp_cpl_header             ( 48'h0      ),
						.cfg_err_cpl_rdy                    (              ),
						// Interrupt generation
						.cfg_interrupt                      ( cfg_interrupt               ),//
						.cfg_interrupt_rdy                  ( cfg_interrupt_rdy           ),//
						.cfg_interrupt_assert               ( 1'b0        ),
						.cfg_interrupt_do                   (             ),
						.cfg_interrupt_di                   ( cfg_interrupt_di            ),//
						.cfg_interrupt_mmenable             ( cfg_interrupt_mmenable      ),
						.cfg_interrupt_msienable            ( cfg_interrupt_msienable     ),
						// Power management signaling
						.cfg_turnoff_ok                     ( 1'b0              ),
						.cfg_to_turnoff                     (               ),
						.cfg_pm_wake                        ( 1'b0                 ),
						.cfg_pcie_link_state                (           ),
						.cfg_trn_pending                    ( 1'b0             ),
						// System configuration and status
						.cfg_dsn                            ( cfg_dsn                     ),
						.cfg_bus_number                     ( cfg_bus_number              ),
						.cfg_device_number                  ( cfg_device_number           ),
						.cfg_function_number                ( cfg_function_number         ),
						.cfg_status                         (                   ),
						.cfg_command                        ( cfg_command                 ),
						.cfg_dstatus                        (                  ),
						.cfg_dcommand                       ( cfg_dcommand                ),
						.cfg_lstatus                        ( cfg_lstatus                 ),
						.cfg_lcommand                       ( cfg_lcommand                ),

						// System (SYS) Interface
						.sys_clk                            ( refclk ),
						.sys_reset                          ( ~pcie_rst_n ),
						.received_hot_reset                 ()
						);

//pcie_gen1 pcie_gen1x1 (
//						// PCI Express (PCI_EXP) Fabric Interface
//						.pci_exp_txp                        ( pcie_txp                 ),
//						.pci_exp_txn                        ( pcie_txn                 ),
//						.pci_exp_rxp                        ( pcie_rxp                 ),
//						.pci_exp_rxn                        ( pcie_rxn                 ),
//
//						// Transaction (TRN) Interface
//						// Common clock & reset
//						.user_lnk_up                        ( user_lnk_up                 ),
//						.user_clk_out                       ( user_clk                    ),
//						.user_reset_out                     ( user_reset                  ),
//						// Common flow control
//						.fc_sel                             (3'b0),
//						.fc_nph                             (),
//						.fc_npd                             (),
//						.fc_ph                              (),
//						.fc_pd                              (),
//						.fc_cplh                            (),
//						.fc_cpld                            (),
//
//						// Transaction Tx
//						.s_axis_tx_tready                   (             ),
//						.s_axis_tx_tdata                    (              ),
//						.s_axis_tx_tkeep                    (              ),
//						.s_axis_tx_tuser                    (              ),
//						.s_axis_tx_tlast                    (              ),
//						.s_axis_tx_tvalid                   (             ),
//						.tx_err_drop                        (                   ),
//						.tx_buf_av                          (                    ),
//						.tx_cfg_req                         (                    ),
//						.tx_cfg_gnt                         ( 1'b1                  ),
//
//						// Transaction Rx
//						.m_axis_rx_tdata                    (              ),
//						.m_axis_rx_tkeep                    (              ),
//						.m_axis_rx_tlast                    (              ),
//						.m_axis_rx_tvalid                   (             ),
//						.m_axis_rx_tready                   (             ),
//						.m_axis_rx_tuser                    (              ),
//						.rx_np_ok                           ( 1'b1                    ),
//
//
//						// Configuration (CFG) Interface
//						// Configuration space access
//						.cfg_do                             (                       ),
//						.cfg_rd_wr_done                     (               ),
//						.cfg_dwaddr                         ( 'd0                  ),
//						.cfg_rd_en                          ( 1'b0                   ),
//						// Error reporting
//						.cfg_err_ur                         ( 1'b0                  ),
//						.cfg_err_cor                        ( 1'b0                 ),
//						.cfg_err_ecrc                       ( 1'b0                ),
//						.cfg_err_cpl_timeout                ( 1'b0         ),
//						.cfg_err_cpl_abort                  ( 1'b0           ),
//						.cfg_err_posted                     ( 1'b1              ),
//						.cfg_err_locked                     ( 1'b0              ),
//						.cfg_err_tlp_cpl_header             ( 48'h0      ),
//						.cfg_err_cpl_rdy                    (              ),
//						// Interrupt generation
//						.cfg_interrupt                      (                ),	//cfg_interrupt
//						.cfg_interrupt_rdy                  (            ),//cfg_interrupt_rdy
//						.cfg_interrupt_assert               (         ),//
//						.cfg_interrupt_do                   (             ),
//						.cfg_interrupt_di                   (             ),//cfg_interrupt_di
//						.cfg_interrupt_mmenable             ( cfg_interrupt_mmenable      ),
//						.cfg_interrupt_msienable            ( cfg_interrupt_msienable     ),
//						// Power management signaling
//						.cfg_turnoff_ok                     ( 1'b0              ),
//						.cfg_to_turnoff                     (               ),
//						.cfg_pm_wake                        ( 1'b0                 ),
//						.cfg_pcie_link_state                (           ),
//						.cfg_trn_pending                    ( 1'b0             ),
//						// System configuration and status
//						.cfg_dsn                            ( cfg_dsn                     ),
//						.cfg_bus_number                     ( cfg_bus_number              ),
//						.cfg_device_number                  ( cfg_device_number           ),
//						.cfg_function_number                ( cfg_function_number         ),
//						.cfg_status                         (                   ),
//						.cfg_command                        ( cfg_command                 ),
//						.cfg_dstatus                        (                  ),
//						.cfg_dcommand                       ( cfg_dcommand                ),
//						.cfg_lstatus                        ( cfg_lstatus                 ),
//						.cfg_lcommand                       ( cfg_lcommand                ),
//
//						// System (SYS) Interface
//						.sys_clk                            ( refclk ),
//						.sys_reset                          ( ~pcie_rst_n ),
//						.received_hot_reset                 ()
//						);

						
endmodule 

