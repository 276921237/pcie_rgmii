
`timescale	1ns/1ps


module	pcie_rx(
				input					user_clk,
				input					user_reset,

				//test
                inout [35:0]	        CONTROL,
                
				input [31:0]			m_axis_rx_tdata,
				input [3:0]				m_axis_rx_tkeep,
				input 					m_axis_rx_tlast,
				input 					m_axis_rx_tvalid,
				output reg				m_axis_rx_tready,
				input [16:0]			m_axis_rx_tuser, //[1] -- packet is error				
				
				//request
				output reg [31:0]      	req_addr_o,
				output reg [2:0]       	req_tc_o,
				output reg				req_td_o,
				output reg            	req_ep_o,
				output reg [1:0]       	req_attr_o,
				output reg [9:0]       	req_len_o,
				output reg [15:0]      	req_rid_o,
				output reg [7:0]       	req_tag_o,
				output reg [7:0]       	req_be_o,
			    output reg				req_compl_o,
                output reg              req_compld_o,
				
				input					compl_done_i,
				
				//write reg
				output reg [7:0]		wr_io_be,
				output reg [12:0]		wr_io_add,
				output reg [31:0]		wr_io_dat,
				output reg				wr_io_en,
                
                output [7:0]            wrbar_be,
                output [15:0]           wrbar_add,
                output [31:0]           wrbar_dat,
                output                  wrbar_en,

                //downstream
                input [10:0]            dma_byte_len,
                
                output reg              ram_tx_start,
                output reg              ram_tx_end,
                output [10:0]           ram_byte_len,                  
                
                output                  ram_tx_clk,
                output reg              ram_tx_we,
                output                  ram_tx_en,
                output reg [10:0]       ram_tx_add,
                output reg [31:0]       ram_tx_dat
				
				);

parameter	IO_WR_FMT_TYPE	=	7'b10_00010;
parameter	IO_RD_FMT_TYPE	=	7'b00_00010;

parameter	MEM_RD64_FMT_TYPE = 7'b01_00000;    //
parameter	MEM_WR64_FMT_TYPE = 7'b11_00000;//

parameter	MEM_RD32_FMT_TYPE = 7'b00_00000;
parameter	MEM_WR32_FMT_TYPE = 7'b10_00000;
parameter	CPL_FMT_TYPE      = 7'b00_01010;
parameter	CPLD_FMT_TYPE     = 7'b10_01010;


parameter	IDLE			= 6'd0,
			IO_WR_DW1		= 6'd1,
			IO_WR_DW2		= 6'd2,
			IO_WR_DW3		= 6'd3,
            IO_WR_WT        = 6'd4,
			IO_RD_DW1       = 6'd5,
            IO_RD_DW2       = 6'd6,
            IO_RD_WT        = 6'd7,
            CPLD_DW1        = 6'd8,
            CPLD_DW2        = 6'd9,
            CPLD_DWN        = 6'd10,
            DMA_JUDGE       = 6'd11,
            
            MEM_WR_DW1      = 6'd12,
            MEM_WR_DW2      = 6'd13,
            MEM_WR_DW3      = 6'd14,
            MEM_WR_DAT      = 6'd15,
            
            MEM_RD_DW1      = 6'd16,
            MEM_RD_DW2      = 6'd17,
            MEM_RD_DW3      = 6'd18,
            MEM_RD_WT       = 6'd19;

reg [5:0]		cs;

reg [9:0]       len_count;  
reg [9:0]       tlp_len;
reg [9:0]       dw_count;

reg [9:0]       dma_dw_len;

wire            tlp_end;
reg             dma_end;

always	@(posedge user_clk) begin
	if( ( user_reset == 1'b1 ) || ( cs == IDLE ) ) 
		dw_count            <= 10'd0;
    else if( ( cs == CPLD_DWN ) && ( m_axis_rx_tvalid ==  1'b1 ) )
        dw_count            <= dw_count + 1'b1;
    else
        dw_count            <= dw_count;
end      

always	@(posedge user_clk) begin
	if( user_reset == 1'b1 ) 
		dma_dw_len      <= 11'd0;      
    else
        dma_dw_len      <= ( dma_byte_len[1:0] == 2'b00 ) ? {1'b0,dma_byte_len[10:2]} : {1'b0,(dma_byte_len[10:2] + 1'b1)};
end        

assign  tlp_end = ( dw_count >= ( tlp_len - 1'b1 ) ) ? 1'b1 : 1'b0; 
//assign  dma_end = ( len_count >= dma_dw_len ) ? 1'b1 : 1'b0;

reg [9:0]   mwr_len;
reg [7:0]   mwr_be;
reg [63:0]  mwr_add;
reg         fmt_type_64;
reg         mwr_en;
reg [31:0]  mwr_dat;

assign  wrbar_be    = mwr_be;
assign  wrbar_add   = mwr_add[15:0];
assign  wrbar_dat   = {mwr_dat[7:0],mwr_dat[15:8],mwr_dat[23:16],mwr_dat[31:24]};//mwr_dat;
assign  wrbar_en    = mwr_en;

always	@(posedge user_clk) begin
	if( user_reset | dma_end ) 
        len_count       <= 10'd0;
    //else if( dma_end == 1'b1 )    
    else if( ( cs == IDLE ) && ( m_axis_rx_tvalid == 1'b1 ) && ( m_axis_rx_tdata[30:24] == CPLD_FMT_TYPE ) ) 
        len_count       <= len_count + m_axis_rx_tdata[9:0];
    else
        len_count       <= len_count;
end        

always	@(posedge user_clk) begin
	if( user_reset == 1'b1 ) begin
		req_tc_o       		<= 2'b0;
		req_td_o       		<= 1'b0;
		req_ep_o       		<= 1'b0;
		req_attr_o     		<= 2'b0;
		req_len_o      		<= 10'b0;
		req_rid_o      		<= 16'b0;
		req_tag_o      		<= 8'b0;
		req_be_o       		<= 8'b0;
		req_addr_o			<= 31'b0;	
		
		req_compl_o			<= 1'b0;
        req_compld_o        <= 1'b0;
		
		wr_io_be			<= 8'h0;
		wr_io_add			<= 13'h0;
		wr_io_dat			<= 32'h0;
		wr_io_en			<= 1'b0;
        
        mwr_en              <= 1'b0;
        mwr_dat             <= 32'h0;
        mwr_add             <= 64'h0;
        fmt_type_64         <= 1'b0;
        
		m_axis_rx_tready	<= 1'b1;
        
        tlp_len             <= 10'd0;
        dma_end             <= 1'b0;
        //len_count           <= 11'd0;        
		cs					<= IDLE;	
	end
	else begin
		case( cs )
			IDLE : begin				
				if( m_axis_rx_tvalid == 1'b1 ) begin
					case( m_axis_rx_tdata[30:24] )
						IO_WR_FMT_TYPE : begin
							req_tc_o	<= m_axis_rx_tdata[22:20];  
							req_td_o	<= m_axis_rx_tdata[15];
							req_ep_o	<= m_axis_rx_tdata[14]; 
							req_attr_o	<= m_axis_rx_tdata[13:12]; 
							req_len_o	<= m_axis_rx_tdata[9:0];                        
                        
							cs			<= IO_WR_DW1;
						end
						IO_RD_FMT_TYPE : begin
							req_tc_o	<= m_axis_rx_tdata[22:20];  
							req_td_o	<= m_axis_rx_tdata[15];
							req_ep_o	<= m_axis_rx_tdata[14]; 
							req_attr_o	<= m_axis_rx_tdata[13:12]; 
							req_len_o	<= m_axis_rx_tdata[9:0]; 	
							
							cs			<= IO_RD_DW1;
						end
                        MEM_WR32_FMT_TYPE : begin
                            mwr_len     <= m_axis_rx_tdata[9:0];
                            fmt_type_64 <= 1'b0;
                            
                            cs          <= MEM_WR_DW1;
                        end
                        MEM_RD32_FMT_TYPE : begin
							req_tc_o	<= m_axis_rx_tdata[22:20];  
							req_td_o	<= m_axis_rx_tdata[15];
							req_ep_o	<= m_axis_rx_tdata[14]; 
							req_attr_o	<= m_axis_rx_tdata[13:12]; 
							req_len_o	<= m_axis_rx_tdata[9:0]; 
                            
                            fmt_type_64 <= 1'b0;
                            
                            cs          <= MEM_RD_DW1;
                        end                        
                        MEM_WR64_FMT_TYPE : begin
                            mwr_len     <= m_axis_rx_tdata[9:0];
                            fmt_type_64 <= 1'b1;
                            
                            cs          <= MEM_WR_DW1;                        
                        end
                        MEM_RD64_FMT_TYPE : begin
							req_tc_o	<= m_axis_rx_tdata[22:20];  
							req_td_o	<= m_axis_rx_tdata[15];
							req_ep_o	<= m_axis_rx_tdata[14]; 
							req_attr_o	<= m_axis_rx_tdata[13:12]; 
							req_len_o	<= m_axis_rx_tdata[9:0]; 
                            
                            fmt_type_64 <= 1'b1;
                            
                            cs          <= MEM_RD_DW1;                        
                        end
						CPLD_FMT_TYPE : begin
                            tlp_len     <= m_axis_rx_tdata[9:0];    //DW len
                            cs          <= CPLD_DW1;
						end
						CPL_FMT_TYPE : begin
						
						end
						default : begin
							cs			<= IDLE;
						end	
					endcase
                    
                    req_compl_o			<= 1'b0;
                    req_compld_o        <= 1'b0;	
                    
                    //tlp_len             <= 10'd0;
                    //len_count           <= len_count;
                    dma_end             <= 1'b0;
                    
					m_axis_rx_tready	<= 1'b1;
					wr_io_en			<= 1'b0;
                    mwr_en              <= 1'b0;
				end
				else begin
                    dma_end             <= 1'b0;
                    wr_io_en			<= 1'b0;
                    mwr_en              <= 1'b0;
					m_axis_rx_tready	<= 1'b1;
					cs 					<= IDLE;
				end	
			end
			//io write
			IO_WR_DW1 : begin
				m_axis_rx_tready	<= 1'b1;
				
				if( m_axis_rx_tvalid == 1'b1 ) begin
					wr_io_be		<= m_axis_rx_tdata[7:0];
					cs				<= IO_WR_DW2;
				end
				else
					cs				<= IO_WR_DW1;
			end
			IO_WR_DW2 : begin
				m_axis_rx_tready	<= 1'b1;
				
				if( m_axis_rx_tvalid == 1'b1 ) begin
					wr_io_add		<= {m_axis_rx_tdata[10:2],2'b00};
					cs				<= IO_WR_DW3;
				end
				else begin
					cs				<= IO_WR_DW2;
				end
			end
			IO_WR_DW3 : begin
				if( m_axis_rx_tvalid == 1'b1 ) begin
					wr_io_dat		<= m_axis_rx_tdata;
					wr_io_en		<= 1'b1;
                    m_axis_rx_tready<= 1'b0;
                    req_compl_o     <= 1'b1;
                    
					cs				<= IO_WR_WT;
				end
				else begin
					m_axis_rx_tready<= 1'b1;
					cs				<= IO_WR_DW3;
				end	
			end
            IO_WR_WT : begin
                req_compl_o         <= 1'b0;
                
				if( compl_done_i == 1'b1 ) begin
					m_axis_rx_tready<= 1'b1;
					cs				<= IDLE;
				end	
				else begin
					m_axis_rx_tready<= 1'b0;
					cs				<= IO_WR_WT; 
				end		
            end
            
			//io read
			IO_RD_DW1 : begin
				if( m_axis_rx_tvalid == 1'b1 ) begin
					req_rid_o    	<= m_axis_rx_tdata[31:16]; 
					req_tag_o    	<= m_axis_rx_tdata[15:08]; 
					req_be_o     	<= m_axis_rx_tdata[07:00];

					cs				<= 	IO_RD_DW2;
				end
				else 
					cs				<= 	IO_RD_DW1;
			end
			IO_RD_DW2 : begin
				if( m_axis_rx_tvalid == 1'b1 ) begin
					req_addr_o		<= m_axis_rx_tdata;
					req_compld_o    <= 1'b1;
					
					m_axis_rx_tready<= 1'b0;
					cs				<= IO_RD_WT;
				end
				else 
					cs				<= IO_RD_DW2;
			end
			IO_RD_WT : begin
                req_compld_o        <= 1'b0;
                
				if( compl_done_i == 1'b1 )
					cs				<= IDLE;
				else
					cs				<= IO_RD_WT;
			end
            
            //memory write
            MEM_WR_DW1 : begin
				m_axis_rx_tready	<= 1'b1;
				
				if( m_axis_rx_tvalid == 1'b1 ) begin
					mwr_be		    <= m_axis_rx_tdata[7:0];
					cs				<= MEM_WR_DW2;
				end
				else
					cs				<= MEM_WR_DW1;                
            end
            MEM_WR_DW2 : begin
                m_axis_rx_tready	<= 1'b1;
                
				if( m_axis_rx_tvalid == 1'b1 ) begin
                    if( fmt_type_64 == 1'b1 ) begin
                        mwr_add[63:32]  <= m_axis_rx_tdata;
                        cs				<= MEM_WR_DW3;
                    end
                    else begin
                        mwr_add		    <= {32'h00,m_axis_rx_tdata[31:2],2'b00};
                        cs				<= MEM_WR_DAT;
                    end
				end
				else
					cs				<= MEM_WR_DW2;                 
            end
            MEM_WR_DW3 : begin
                m_axis_rx_tready	<= 1'b1;
                
                if( m_axis_rx_tvalid == 1'b1 ) begin
                    mwr_add[31:0]   <= {m_axis_rx_tdata[31:2],2'b00};
                    cs				<= MEM_WR_DAT;
                end
                else
                    cs              <= MEM_WR_DW3;
            end
            MEM_WR_DAT : begin
                m_axis_rx_tready	<= 1'b1;
                
                if( m_axis_rx_tvalid == 1'b1 ) begin
                    mwr_en          <= 1'b1;
                    mwr_dat         <= m_axis_rx_tdata;
                    cs				<= IDLE;
                end
                else
                    cs				<= MEM_WR_DAT;
            end
            
            //memory write 
            MEM_RD_DW1 : begin
                m_axis_rx_tready	<= 1'b1;
                
				if( m_axis_rx_tvalid == 1'b1 ) begin
					req_rid_o    	<= m_axis_rx_tdata[31:16]; 
					req_tag_o    	<= m_axis_rx_tdata[15:08]; 
					req_be_o     	<= m_axis_rx_tdata[07:00];

					cs				<= 	MEM_RD_DW2;
				end
				else 
					cs				<= 	MEM_RD_DW1;                
            end
            MEM_RD_DW2 : begin
				if( m_axis_rx_tvalid == 1'b1 ) begin
                    if( fmt_type_64 == 1'b1 ) begin
                        m_axis_rx_tready<= 1'b1;
                        cs              <= MEM_RD_DW3;
                    end
                    else begin
                        req_addr_o		<= m_axis_rx_tdata;
                        req_compld_o    <= 1'b1;
                        
                        m_axis_rx_tready<= 1'b0;                    
                        cs              <= MEM_RD_WT;
                    end
				end
				else 
					cs				<= MEM_RD_DW2;                
            end
            MEM_RD_DW3 : begin
                if( m_axis_rx_tvalid == 1'b1 ) begin
                    req_addr_o		<= m_axis_rx_tdata;
                    req_compld_o    <= 1'b1;
                    
                    m_axis_rx_tready<= 1'b0;                    
                    cs              <= MEM_RD_WT;                
                end
                else
                    cs              <= MEM_RD_DW3;
            end
            MEM_RD_WT : begin
                req_compld_o        <= 1'b0;
                
				if( compl_done_i == 1'b1 )
					cs				<= IDLE;
				else
					cs				<= MEM_RD_WT;
            end
            
            //CPLD 
            CPLD_DW1 : begin
                if( m_axis_rx_tvalid == 1'b1 ) begin
                    //len_count       <= len_count + m_axis_rx_tdata[10:0];
                    cs				<= CPLD_DW2;
                end
                else
                    cs				<= CPLD_DW1;
            end
            CPLD_DW2 : begin
                if( m_axis_rx_tvalid == 1'b1 )
                    cs				<= CPLD_DWN;
                else
                    cs				<= CPLD_DW2;
            end
            CPLD_DWN : begin
                if( m_axis_rx_tvalid == 1'b1 ) begin
                    if( tlp_end == 1'b1 ) begin
                        m_axis_rx_tready<= 1'b0;
                        cs              <= DMA_JUDGE;
                    end    
                    else
                        cs              <= CPLD_DWN;
                end
                else begin
                    cs                  <= CPLD_DWN;
                end
            end
            DMA_JUDGE : begin
                dma_end                 <= ( len_count >= dma_dw_len ) ? 1'b1 : 1'b0;
                cs                      <= IDLE;
            end           
			default : begin
			
			end
		endcase
	end
end

reg     cycle_extend;
reg     is_writing;

always	@(posedge user_clk) begin
	if( user_reset == 1'b1 )
        is_writing      <= 1'b0;
    else if( ( cs == CPLD_DWN ) && ( m_axis_rx_tvalid == 1'b1 ) )    
        is_writing      <= 1'b1;
    else if( ram_tx_end == 1'b1 ) 
        is_writing      <= 1'b0;
    else
        is_writing      <= is_writing;
end        

always	@(posedge user_clk) begin
	if( user_reset == 1'b1 )
        ram_tx_start    <= 1'b0;
    else if( ( cs == CPLD_DWN ) && ( m_axis_rx_tvalid == 1'b1 ) && ( is_writing == 1'b0 ))    
        ram_tx_start    <= 1'b1;
    else if( cycle_extend == 1'b1 )    
        ram_tx_start    <= 1'b0;
    else
        ram_tx_start    <= ram_tx_start;
end        

always	@(posedge user_clk) begin
	if( user_reset == 1'b1 )
        ram_tx_end      <= 1'b0;
    else if( dma_end == 1'b1 ) // ( cs == DMA_JUDGE ) &&
        ram_tx_end      <= 1'b1;
    else if( cycle_extend == 1'b1 )
        ram_tx_end      <= 1'b0;
    else
        ram_tx_end      <= ram_tx_end;
end    

always	@(posedge user_clk) begin
	if( user_reset == 1'b1 )
        cycle_extend    <= 1'b0;
    else if( ( ram_tx_end == 1'b1 ) || ( ram_tx_start == 1'b1 ))    
        cycle_extend    <= 1'b1;
    else
        cycle_extend    <= 1'b0;
end     
   
                
always	@(posedge user_clk) begin
	if( user_reset == 1'b1 ) 
        ram_tx_we       <= 1'b0;       
    else if( ( cs == CPLD_DWN ) && ( m_axis_rx_tvalid == 1'b1 )) 
        ram_tx_we       <= 1'b1;
    else
        ram_tx_we       <= 1'b0;
end    
     
always	@(posedge user_clk) begin
	if( ( user_reset == 1'b1 ) || ( ram_tx_end == 1'b1 ) ) 
        ram_tx_add      <= 11'h0;       
    else if( ram_tx_we == 1'b1 )//( ( cs == CPLD_DWN ) && ( m_axis_rx_tvalid == 1'b1 )) 
        ram_tx_add      <= ram_tx_add + 1'b1;
    else
        ram_tx_add      <= ram_tx_add;
end 
     
always	@(posedge user_clk) begin
	if( user_reset == 1'b1 ) 
        ram_tx_dat      <= 32'h0;       
    else if( ( cs == CPLD_DWN ) && ( m_axis_rx_tvalid == 1'b1 )) 
        ram_tx_dat      <= {m_axis_rx_tdata[7:0],m_axis_rx_tdata[15:8],m_axis_rx_tdata[23:16],m_axis_rx_tdata[31:24]};//m_axis_rx_tdata;
    else
        ram_tx_dat      <= ram_tx_dat;
end     

assign  ram_tx_clk      = user_clk;
assign  ram_tx_en       = 1'b1;
assign  ram_byte_len    = dma_byte_len;   


 // ila_grab ila_rx (
						  // .CONTROL		(CONTROL), // INOUT BUS [35:0]
						  // .CLK           (user_clk), // IN
						  // .TRIG0			({
                                                // ram_tx_end,
                                                // ram_tx_start,
                                                // ram_tx_add,
                                                // dma_dw_len,
                                                // len_count,
                                                // dma_end,
                                                // ram_tx_end,
                                                // ram_tx_dat,
                                                // ram_tx_we,
                                                // dw_count,
                                                // tlp_len,
                                                // m_axis_rx_tdata,
                                                // m_axis_rx_tlast,
                                                // m_axis_rx_tvalid,
                                                // m_axis_rx_tuser,
                                                // m_axis_rx_tready,
                                                // cs,
                                                // mwr_add,
                                                // mwr_dat,
                                                // mwr_en}) // IN BUS [255:0]
					 // );


endmodule 

