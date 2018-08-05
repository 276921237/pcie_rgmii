
module PCIe_M6X(
	input			user_clk		,
	input			user_rst		,

	input			m6x_clk			,
	output			m6x_rst			,

	input			uart_rx			,
	output			uart_tx			,
	input			pps_in			,
	input			tod_in			,
	
	input			rgmii_rxdv		,//输入有效信号
	input			rgmii_rxclk		,//输入时钟
	input	[3:0]	rgmii_rxd		,//数据输入
	
	output			rgmii_txdv		,//输出有效信号
	output			rgmii_txclk		,//输出时钟
	output	[3:0]	rgmii_txd		,//数据输出

	input			pcie_clk_p		,
	input			pcie_clk_n		,
	output			pci_txp			,
	output			pci_txn			,
	input			pci_rxp			,
	input			pci_rxn			,
	output			pcie_int		,
	input           pcie_rst		,

	output	[3:0]	led			
);

	wire 			link_up						;
	wire 			clk_125m					;
	wire 			rgmii_clk_125m				;
	//upstream ram interface		
	wire	[7:0]	ram_data_flag				;
	wire	[7:0]	ram_data_flag_clr			;

	//0		
	wire	[10:0]	ram_dat_len0				;
	wire			eth_ram_clk0				;
	wire			eth_ram_we0					;
	wire			eth_ram_en0					;
	wire	[10:0]	eth_ram_add0				;
	wire	[31:0]	eth_ram_dat0				;

	wire			ts_ram_clk0					;
	wire			ts_ram_we0					;
	wire			ts_ram_en0					;
	wire	[3:0]	ts_ram_add0					;
	wire	[31:0]	ts_ram_dat0					;
	//1		
	wire	[10:0]	ram_dat_len1				;
	wire			eth_ram_clk1				;
	wire			eth_ram_we1					;
	wire			eth_ram_en1					;
	wire	[10:0]	eth_ram_add1				;
	wire	[31:0]	eth_ram_dat1				;

	wire			ts_ram_clk1					;
	wire			ts_ram_we1					;
	wire			ts_ram_en1					;
	wire	[3:0]	ts_ram_add1					;
	wire	[31:0]	ts_ram_dat1					;
	//2		
	wire	[10:0]	ram_dat_len2				;
	wire			eth_ram_clk2				;
	wire			eth_ram_we2					;
	wire			eth_ram_en2					;
	wire	[10:0]	eth_ram_add2				;
	wire	[31:0]	eth_ram_dat2				;

	wire			ts_ram_clk2					;
	wire			ts_ram_we2					;
	wire			ts_ram_en2					;
	wire	[3:0]	ts_ram_add2					;
	wire	[31:0]	ts_ram_dat2					;
	//3		
	wire	[10:0]	ram_dat_len3				;
	wire			eth_ram_clk3				;
	wire			eth_ram_we3					;
	wire			eth_ram_en3					;
	wire	[10:0]	eth_ram_add3				;
	wire	[31:0]	eth_ram_dat3				;

	wire			ts_ram_clk3					;
	wire			ts_ram_we3					;
	wire			ts_ram_en3					;
	wire	[3:0]	ts_ram_add3					;
	wire	[31:0]	ts_ram_dat3					;
	//4		
	wire	[10:0]	ram_dat_len4				;
	wire			eth_ram_clk4				;
	wire			eth_ram_we4					;
	wire			eth_ram_en4					;
	wire	[10:0]	eth_ram_add4				;
	wire	[31:0]	eth_ram_dat4				;

	wire			ts_ram_clk4					;
	wire			ts_ram_we4					;
	wire			ts_ram_en4					;
	wire	[3:0]	ts_ram_add4					;
	wire	[31:0]	ts_ram_dat4					;
	//5		
	wire	[10:0]	ram_dat_len5				;
	wire			eth_ram_clk5				;
	wire			eth_ram_we5					;
	wire			eth_ram_en5					;
	wire	[10:0]	eth_ram_add5				;
	wire	[31:0]	eth_ram_dat5				;

	wire			ts_ram_clk5					;
	wire			ts_ram_we5					;
	wire			ts_ram_en5					;
	wire	[3:0]	ts_ram_add5					;
	wire	[31:0]	ts_ram_dat5					;
	//6		
	wire	[10:0]	ram_dat_len6				;
	wire			eth_ram_clk6				;
	wire			eth_ram_we6					;
	wire			eth_ram_en6					;
	wire	[10:0]	eth_ram_add6				;
	wire	[31:0]	eth_ram_dat6				;

	wire			ts_ram_clk6					;
	wire			ts_ram_we6					;
	wire			ts_ram_en6					;
	wire	[3:0]	ts_ram_add6					;
	wire	[31:0]	ts_ram_dat6					;
	//7		
	wire	[10:0]	ram_dat_len7				;
	wire			eth_ram_clk7				;
	wire			eth_ram_we7					;
	wire			eth_ram_en7					;
	wire	[10:0]	eth_ram_add7				;
	wire	[31:0]	eth_ram_dat7				;

	wire			ts_ram_clk7					;
	wire			ts_ram_we7					;
	wire			ts_ram_en7					;
	wire	[3:0]	ts_ram_add7					;
	wire	[31:0]	ts_ram_dat7					;

	//downstream		
	wire			ram_tx_start				;
	wire			ram_tx_end					;
	wire	[10:0]	ram_byte_len				;
	wire			tx_completed				;

	wire			ram_tx_clk					;
	wire			ram_tx_we					;
	wire			ram_tx_en					;
	wire	[10:0]	ram_tx_add					;
	wire	[31:0]	ram_tx_dat					;

	//uart controll interface
	//upstream
	wire			m6x_uart_ram_data_flag		;
	wire			m6x_uart_ram_data_flag_clr	;
	wire	[12:0]	m6x_uart_ram_dat_len		;

	wire			m6x_uart_ram_clk			;
	wire			m6x_uart_ram_we				;
	wire			m6x_uart_ram_en				;
	wire	[12:0]	m6x_uart_ram_add			;
	wire	[31:0]	m6x_uart_ram_dat			;

	//down
	wire			m6x_uart_tx_start			;
	wire			m6x_uart_tx_end				;
	wire	[7:0]	m6x_uart_down_byte_len		;
	wire			m6x_uart_down_tx_completed	;

	wire			m6x_uart_down_tx_clk		;
	wire			m6x_uart_down_tx_we			;
	wire			m6x_uart_down_tx_en			;
	wire	[7:0]	m6x_uart_down_tx_add		;
	wire	[31:0]	m6x_uart_down_tx_dat		;
	wire	[31:0]	m6x_uart_down_tx_dat_i		;

	//TOD
	wire			m6x_tod_ram_data_flag		;
	wire			m6x_tod_ram_data_flag_clr	;
	wire	[8:0]	m6x_tod_ram_data_len		;
	
	wire			m6x_tod_ram_clk				;
	wire			m6x_tod_ram_we				;
	wire			m6x_tod_ram_en				;
	wire	[8:0]	m6x_tod_ram_add				;
	wire	[31:0]	m6x_tod_ram_dat				;
    
    wire            uart_ustod_latch_flag       ;
    wire    [31:0]  bar_year_month_day          ;
    wire    [31:0]  bar_hour_min_sec            ;
    wire    [31:0]  bar_nano_sec                ;

	Gige2PCIe u_Gige2PCIe(
		.link_up					(link_up					),

		.clk_125m					(clk_125m					),
		.pps    					(pps_in  					),

		//upstream ram interface
		.ram_data_flag				(ram_data_flag				),
		.ram_data_flag_clr			(ram_data_flag_clr			),

		//0
		.ram_dat_len0				(ram_dat_len0				),
		.eth_ram_clk0				(eth_ram_clk0				),
		.eth_ram_we0				(eth_ram_we0				),
		.eth_ram_en0				(eth_ram_en0				),
		.eth_ram_add0				(eth_ram_add0				),
		.eth_ram_dat0				(eth_ram_dat0				),

		.ts_ram_clk0				(ts_ram_clk0				),
		.ts_ram_we0					(ts_ram_we0					),
		.ts_ram_en0					(ts_ram_en0					),
		.ts_ram_add0				(ts_ram_add0				),
		.ts_ram_dat0				(ts_ram_dat0				),
		//1
		.ram_dat_len1				(ram_dat_len1				),
		.eth_ram_clk1				(eth_ram_clk1				),
		.eth_ram_we1				(eth_ram_we1				),
		.eth_ram_en1				(eth_ram_en1				),
		.eth_ram_add1				(eth_ram_add1				),
		.eth_ram_dat1				(eth_ram_dat1				),

		.ts_ram_clk1				(ts_ram_clk1				),
		.ts_ram_we1					(ts_ram_we1					),
		.ts_ram_en1					(ts_ram_en1					),
		.ts_ram_add1				(ts_ram_add1				),
		.ts_ram_dat1				(ts_ram_dat1				),
		//2
		.ram_dat_len2				(ram_dat_len2				),
		.eth_ram_clk2				(eth_ram_clk2				),
		.eth_ram_we2				(eth_ram_we2				),
		.eth_ram_en2				(eth_ram_en2				),
		.eth_ram_add2				(eth_ram_add2				),
		.eth_ram_dat2				(eth_ram_dat2				),

		.ts_ram_clk2				(ts_ram_clk2				),
		.ts_ram_we2					(ts_ram_we2					),
		.ts_ram_en2					(ts_ram_en2					),
		.ts_ram_add2				(ts_ram_add2				),
		.ts_ram_dat2				(ts_ram_dat2				),					
		//3
		.ram_dat_len3				(ram_dat_len3				),
		.eth_ram_clk3				(eth_ram_clk3				),
		.eth_ram_we3				(eth_ram_we3				),
		.eth_ram_en3				(eth_ram_en3				),
		.eth_ram_add3				(eth_ram_add3				),
		.eth_ram_dat3				(eth_ram_dat3				),

		.ts_ram_clk3				(ts_ram_clk3				),
		.ts_ram_we3					(ts_ram_we3					),
		.ts_ram_en3					(ts_ram_en3					),
		.ts_ram_add3				(ts_ram_add3				),
		.ts_ram_dat3				(ts_ram_dat3				),
		//4
		.ram_dat_len4				(ram_dat_len4				),
		.eth_ram_clk4				(eth_ram_clk4				),
		.eth_ram_we4				(eth_ram_we4				),
		.eth_ram_en4				(eth_ram_en4				),
		.eth_ram_add4				(eth_ram_add4				),
		.eth_ram_dat4				(eth_ram_dat4				),

		.ts_ram_clk4				(ts_ram_clk4				),
		.ts_ram_we4					(ts_ram_we4					),
		.ts_ram_en4					(ts_ram_en4					),
		.ts_ram_add4				(ts_ram_add4				),
		.ts_ram_dat4				(ts_ram_dat4				),
		//5
		.ram_dat_len5				(ram_dat_len5				),
		.eth_ram_clk5				(eth_ram_clk5				),
		.eth_ram_we5				(eth_ram_we5				),
		.eth_ram_en5				(eth_ram_en5				),
		.eth_ram_add5				(eth_ram_add5				),
		.eth_ram_dat5				(eth_ram_dat5				),

		.ts_ram_clk5				(ts_ram_clk5				),
		.ts_ram_we5					(ts_ram_we5					),
		.ts_ram_en5					(ts_ram_en5					),
		.ts_ram_add5				(ts_ram_add5				),
		.ts_ram_dat5				(ts_ram_dat5				),
		//6
		.ram_dat_len6				(ram_dat_len6				),
		.eth_ram_clk6				(eth_ram_clk6				),
		.eth_ram_we6				(eth_ram_we6				),
		.eth_ram_en6				(eth_ram_en6				),
		.eth_ram_add6				(eth_ram_add6				),
		.eth_ram_dat6				(eth_ram_dat6				),

		.ts_ram_clk6				(ts_ram_clk6				),
		.ts_ram_we6					(ts_ram_we6					),
		.ts_ram_en6					(ts_ram_en6					),
		.ts_ram_add6				(ts_ram_add6				),
		.ts_ram_dat6				(ts_ram_dat6				),	
		//7
		.ram_dat_len7				(ram_dat_len7				),
		.eth_ram_clk7				(eth_ram_clk7				),
		.eth_ram_we7				(eth_ram_we7				),
		.eth_ram_en7				(eth_ram_en7				),
		.eth_ram_add7				(eth_ram_add7				),
		.eth_ram_dat7				(eth_ram_dat7				),

		.ts_ram_clk7				(ts_ram_clk7				),
		.ts_ram_we7					(ts_ram_we7					),
		.ts_ram_en7					(ts_ram_en7					),
		.ts_ram_add7				(ts_ram_add7				),
		.ts_ram_dat7				(ts_ram_dat7				),	

		//downstream
		.ram_tx_start				(ram_tx_start				),
		.ram_tx_end					(ram_tx_end					),
		.ram_byte_len				(ram_byte_len				),
		.tx_completed				(tx_completed				),
		.ram_tx_clk					(ram_tx_clk					),
		.ram_tx_we					(ram_tx_we					),
		.ram_tx_en					(ram_tx_en					),
		.ram_tx_add					(ram_tx_add					),
		.ram_tx_dat					(ram_tx_dat					),

		//uart controll interface
		//upstream
		.m6x_uart_ram_data_flag		(m6x_uart_ram_data_flag		),
		.m6x_uart_ram_data_flag_clr	(m6x_uart_ram_data_flag_clr	),
		.m6x_uart_ram_dat_len		(m6x_uart_ram_dat_len		),

		.m6x_uart_ram_clk			(m6x_uart_ram_clk			),
		.m6x_uart_ram_we			(m6x_uart_ram_we			),
		.m6x_uart_ram_en			(m6x_uart_ram_en			),
		.m6x_uart_ram_add			(m6x_uart_ram_add			),
		.m6x_uart_ram_dat			(m6x_uart_ram_dat			),

		//down
		.m6x_uart_tx_start			(m6x_uart_tx_start			),
		.m6x_uart_tx_end			(m6x_uart_tx_end			),
		.m6x_uart_down_byte_len		(m6x_uart_down_byte_len		),
		.m6x_uart_down_tx_completed	(m6x_uart_down_tx_completed	),

		.m6x_uart_down_tx_clk		(m6x_uart_down_tx_clk		),
		.m6x_uart_down_tx_we		(m6x_uart_down_tx_we		),
		.m6x_uart_down_tx_en		(m6x_uart_down_tx_en		),
		.m6x_uart_down_tx_add		(m6x_uart_down_tx_add		),
		.m6x_uart_down_tx_dat		(m6x_uart_down_tx_dat		),
		.m6x_uart_down_tx_dat_i		(m6x_uart_down_tx_dat_i		),

		//TOD 
		.m6x_tod_ram_data_flag		(m6x_tod_ram_data_flag		),
		.m6x_tod_ram_data_flag_clr	(m6x_tod_ram_data_flag_clr	),
		.m6x_tod_ram_data_len		(m6x_tod_ram_data_len		),

		.m6x_tod_ram_clk			(m6x_tod_ram_clk			),
		.m6x_tod_ram_we				(m6x_tod_ram_we				),
		.m6x_tod_ram_en				(m6x_tod_ram_en				),
		.m6x_tod_ram_add			(m6x_tod_ram_add			),
		.m6x_tod_ram_dat			(m6x_tod_ram_dat			),                    

        .uart_ustod_latch_flag      (uart_ustod_latch_flag      ),
        .bar_year_month_day         (bar_year_month_day         ),
        .bar_hour_min_sec           (bar_hour_min_sec           ),
        .bar_nano_sec               (bar_nano_sec               ),
        
		//pcie interface
		.pcie_rst					(pcie_rst),
		.refclk_p					(pcie_clk_p					),
		.refclk_n					(pcie_clk_n					),
		.pcie_txp					(pci_txp					),
		.pcie_txn					(pci_txn					),
		.pcie_rxp					(pci_rxp					),
		.pcie_rxn					(pci_rxn					)
	);
	
	M6X u_M6X(
		.user_clk					(user_clk					),
		.user_rst					(link_up && user_rst        ),
		.clk_125m					(clk_125m					),
		.rgmii_clk_125m				(rgmii_clk_125m				),

		.uart_rx					(uart_rx					),
		.uart_tx					(uart_tx					),
		.pps_in						(pps_in						),
		.tod_in						(tod_in						),

		.rgmii_rxdv					(rgmii_rxdv					),//输入有效信号
		.rgmii_rxclk				(rgmii_rxclk				),//输入时钟
		.rgmii_rxd					(rgmii_rxd					),//数据输入

		.rgmii_txdv					(rgmii_txdv					),//输出有效信号
		.rgmii_txclk				(rgmii_txclk				),//输出时钟
		.rgmii_txd					(rgmii_txd					),//数据输出

		//NET数据上行方向		
		.ram_net_up_flag0       	(ram_data_flag[0]       	),
		.ram_net_up_clr0        	(ram_data_flag_clr[0]   	),
		.ram_net_up_len0        	(ram_dat_len0	        	),
		.ram_net_up_rd_clk0			(eth_ram_clk0				),
		.ram_net_up_rd_en0      	(eth_ram_en0	     		),
		.ram_net_up_rd_we0      	(eth_ram_we0				),
		.ram_net_up_rd_addr0    	(eth_ram_add0[10:2]	    	),
		.ram_net_up_rd_data0    	(eth_ram_dat0				),
		.ram_ts_up_rd_clk0			(ts_ram_clk0				),
		.ram_ts_up_rd_en0       	(ts_ram_en0       			),
		.ram_ts_up_rd_we0       	(ts_ram_we0       			),
		.ram_ts_up_rd_addr0     	(ts_ram_add0[3:2]  			),
		.ram_ts_up_rd_data0     	(ts_ram_dat0	     		),

		.ram_net_up_flag1       	(ram_data_flag[1]       	),
		.ram_net_up_clr1        	(ram_data_flag_clr[1]   	),
		.ram_net_up_len1        	(ram_dat_len1	        	),
		.ram_net_up_rd_clk1			(eth_ram_clk1				),
		.ram_net_up_rd_en1      	(eth_ram_en1	     		),
		.ram_net_up_rd_we1      	(eth_ram_we1				),
		.ram_net_up_rd_addr1    	(eth_ram_add1[10:2]	    	),
		.ram_net_up_rd_data1    	(eth_ram_dat1				),
		.ram_ts_up_rd_clk1			(ts_ram_clk1				),
		.ram_ts_up_rd_en1       	(ts_ram_en1       			),
		.ram_ts_up_rd_we1       	(ts_ram_we1       			),
		.ram_ts_up_rd_addr1     	(ts_ram_add1[3:2]  			),
		.ram_ts_up_rd_data1     	(ts_ram_dat1	     		),

		.ram_net_up_flag2       	(ram_data_flag[2]       	),
		.ram_net_up_clr2        	(ram_data_flag_clr[2]   	),
		.ram_net_up_len2        	(ram_dat_len2	        	),
		.ram_net_up_rd_clk2			(eth_ram_clk2				),
		.ram_net_up_rd_en2      	(eth_ram_en2	     		),
		.ram_net_up_rd_we2      	(eth_ram_we2				),
		.ram_net_up_rd_addr2    	(eth_ram_add2[10:2]	    	),
		.ram_net_up_rd_data2    	(eth_ram_dat2				),
		.ram_ts_up_rd_clk2			(ts_ram_clk2				),
		.ram_ts_up_rd_en2       	(ts_ram_en2       			),
		.ram_ts_up_rd_we2       	(ts_ram_we2       			),
		.ram_ts_up_rd_addr2     	(ts_ram_add2[3:2]  			),
		.ram_ts_up_rd_data2     	(ts_ram_dat2	     		),

		.ram_net_up_flag3       	(ram_data_flag[3]       	),
		.ram_net_up_clr3        	(ram_data_flag_clr[3]   	),
		.ram_net_up_len3        	(ram_dat_len3	        	),
		.ram_net_up_rd_clk3			(eth_ram_clk3				),
		.ram_net_up_rd_en3      	(eth_ram_en3	     		),
		.ram_net_up_rd_we3      	(eth_ram_we3				),
		.ram_net_up_rd_addr3    	(eth_ram_add3[10:2]	    	),
		.ram_net_up_rd_data3    	(eth_ram_dat3				),
		.ram_ts_up_rd_clk3			(ts_ram_clk3				),
		.ram_ts_up_rd_en3       	(ts_ram_en3       			),
		.ram_ts_up_rd_we3       	(ts_ram_we3       			),
		.ram_ts_up_rd_addr3     	(ts_ram_add3[3:2]  			),
		.ram_ts_up_rd_data3     	(ts_ram_dat3	     		),

		.ram_net_up_flag4       	(ram_data_flag[4]       	),
		.ram_net_up_clr4        	(ram_data_flag_clr[4]   	),
		.ram_net_up_len4        	(ram_dat_len4	        	),
		.ram_net_up_rd_clk4			(eth_ram_clk4				),
		.ram_net_up_rd_en4      	(eth_ram_en4	     		),
		.ram_net_up_rd_we4      	(eth_ram_we4				),
		.ram_net_up_rd_addr4    	(eth_ram_add4[10:2]	    	),
		.ram_net_up_rd_data4    	(eth_ram_dat4				),
		.ram_ts_up_rd_clk4			(ts_ram_clk4				),
		.ram_ts_up_rd_en4       	(ts_ram_en4       			),
		.ram_ts_up_rd_we4       	(ts_ram_we4       			),
		.ram_ts_up_rd_addr4     	(ts_ram_add4[3:2]  			),
		.ram_ts_up_rd_data4     	(ts_ram_dat4	     		),

		.ram_net_up_flag5       	(ram_data_flag[5]       	),
		.ram_net_up_clr5        	(ram_data_flag_clr[5]   	),
		.ram_net_up_len5        	(ram_dat_len5	        	),
		.ram_net_up_rd_clk5			(eth_ram_clk5				),
		.ram_net_up_rd_en5      	(eth_ram_en5	     		),
		.ram_net_up_rd_we5      	(eth_ram_we5				),
		.ram_net_up_rd_addr5    	(eth_ram_add5[10:2]	    	),
		.ram_net_up_rd_data5    	(eth_ram_dat5				),
		.ram_ts_up_rd_clk5			(ts_ram_clk5				),
		.ram_ts_up_rd_en5       	(ts_ram_en5       			),
		.ram_ts_up_rd_we5       	(ts_ram_we5       			),
		.ram_ts_up_rd_addr5     	(ts_ram_add5[3:2]  			),
		.ram_ts_up_rd_data5     	(ts_ram_dat5	     		),

		.ram_net_up_flag6       	(ram_data_flag[6]       	),
		.ram_net_up_clr6        	(ram_data_flag_clr[6]   	),
		.ram_net_up_len6        	(ram_dat_len6	        	),
		.ram_net_up_rd_clk6			(eth_ram_clk6				),
		.ram_net_up_rd_en6      	(eth_ram_en6	     		),
		.ram_net_up_rd_we6      	(eth_ram_we6				),
		.ram_net_up_rd_addr6    	(eth_ram_add6[10:2]	    	),
		.ram_net_up_rd_data6    	(eth_ram_dat6				),
		.ram_ts_up_rd_clk6			(ts_ram_clk6				),
		.ram_ts_up_rd_en6       	(ts_ram_en6       			),
		.ram_ts_up_rd_we6       	(ts_ram_we6       			),
		.ram_ts_up_rd_addr6     	(ts_ram_add6[3:2] 			),
		.ram_ts_up_rd_data6     	(ts_ram_dat6	     		),

		.ram_net_up_flag7       	(ram_data_flag[7]       	),
		.ram_net_up_clr7        	(ram_data_flag_clr[7]   	),
		.ram_net_up_len7        	(ram_dat_len7	        	),
		.ram_net_up_rd_clk7			(eth_ram_clk7				),
		.ram_net_up_rd_en7      	(eth_ram_en7	     		),
		.ram_net_up_rd_we7      	(eth_ram_we7				),
		.ram_net_up_rd_addr7    	(eth_ram_add7[10:2]	    	),
		.ram_net_up_rd_data7    	(eth_ram_dat7				),
		.ram_ts_up_rd_clk7			(ts_ram_clk7				),
		.ram_ts_up_rd_en7       	(ts_ram_en7       			),
		.ram_ts_up_rd_we7       	(ts_ram_we7       			),
		.ram_ts_up_rd_addr7     	(ts_ram_add7[3:2]  			),
		.ram_ts_up_rd_data7     	(ts_ram_dat7	     		),

		//NET数据下行方向		
		.ram_net_down_wr_clk		(ram_tx_clk					),
		.ram_net_down_wr_en			(ram_tx_en					),
		.ram_net_down_wr_we			(ram_tx_we					),
		.ram_net_down_wr_addr		(ram_tx_add[8:0]			),
		.ram_net_down_wr_data		(ram_tx_dat					),
		.ram_net_down_start			(ram_tx_start				),
		.ram_net_down_len			(ram_byte_len				),
		.ram_net_down_completed		(tx_completed				),

		//TOD串口数据上行方向	
		.ram_tod_up_rd_clk			(m6x_tod_ram_clk			),
		.ram_tod_up_rd_en			(m6x_tod_ram_en				),
		.ram_tod_up_rd_we			(m6x_tod_ram_we				),
		.ram_tod_up_rd_addr			(m6x_tod_ram_add[8:2]		),
		.ram_tod_up_rd_data			(m6x_tod_ram_dat			),
		.ram_tod_up_len				(m6x_tod_ram_data_len		),
		.ram_tod_up_flag			(m6x_tod_ram_data_flag		),
		.ram_tod_up_clr				(m6x_tod_ram_data_flag_clr	),

        .uart_ustod_latch_flag      (uart_ustod_latch_flag      ),
        .bar_year_month_day         (bar_year_month_day         ),
        .bar_hour_min_sec           (bar_hour_min_sec           ),
        .bar_nano_sec               (bar_nano_sec               ),
    
		//M6X uart 上行方向     	 /M6X uart 上行方向
		.ram_uart_up_rd_clk			(m6x_uart_ram_clk			),
		.ram_uart_up_rd_en			(m6x_uart_ram_en			),
		.ram_uart_up_rd_we			(m6x_uart_ram_we			),
		.ram_uart_up_rd_addr		(m6x_uart_ram_add[12:2]		),
		.ram_uart_up_rd_data		(m6x_uart_ram_dat			),
		.ram_uart_up_len			(m6x_uart_ram_dat_len		),
		.ram_uart_up_flag			(m6x_uart_ram_data_flag		),
		.ram_uart_up_clr			(m6x_uart_ram_data_flag_clr	),

		//M6X uart 下行方向     	 /M6X uart 下行方向
		.ram_uart_down_wr_clk		(m6x_uart_down_tx_clk		),
		.ram_uart_down_wr_en		(m6x_uart_down_tx_en		),
		.ram_uart_down_wr_we		(m6x_uart_down_tx_we		),
		.ram_uart_down_wr_addr		(m6x_uart_down_tx_add[7:2]	),
		.ram_uart_down_wr_data		(m6x_uart_down_tx_dat		),
		.ram_uart_down_start		(m6x_uart_tx_start			),
		.ram_uart_down_len			(m6x_uart_down_byte_len		),
		.ram_uart_down_completed	(m6x_uart_down_tx_completed	)
	);
    
//////////////////////////////////////////////////////////////////////////////////
// led灯
//////////////////////////////////////////////////////////////////////////////////
    assign m6x_rst = user_rst;
	led u_led(
		.clk		(clk_125m		    ),
		.rgmii_clk	(rgmii_clk_125m    	),
		.rst_n		(user_rst			),
		.led1		(led[1]				),
		.led2		(led[2]				),
		.led3 		(led[3] 			)
	);

	assign led[0] = 1'b1;
	
endmodule
