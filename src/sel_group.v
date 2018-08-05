
module sel_group(
                input               user_clk,
                input               user_reset,
                
                input               ram_data_flag,
                input [2:0]         ram_ptr,
                input [2:0]         group_id,
                    
                output reg [1:0]    ts_add,
                output reg [8:0]    eth_add,
                
                output reg          flag_clr,
                
                input [10:0]        ram_dat_len,
                
                input [31:0]        ts_dat,
                input [31:0]        eth_dat,
                
                output reg          wrfifo_en,
                output reg [31:0]   wrfifo_dat
                );
                
parameter   DAT_DLY = 2;                 

reg                     ram_valid;

reg                     rdts;
reg                     rdeth;
// reg [1:0]               ts_add;
// reg [8:0]               eth_add;

reg [10:0]              dat_len_r;
reg [10:0]              dat_len_rr;
reg [1:0]               dat_flag;

reg [DAT_DLY - 1 : 0]   rdts_r;
reg [DAT_DLY - 1 : 0]   rdeth_r;

//reg                     flag_clr;
reg                     cyc_extend;
//wire                    wrfifo_en;

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        dat_flag       <= 9'd0;
    else
        dat_flag       <= {dat_flag[0],ram_data_flag};
end 

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        dat_len_r      <= 11'd0;
    else
        dat_len_r      <= ram_dat_len;
end        

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        dat_len_rr     <= 11'd0;
    else
        dat_len_rr     <= ( dat_len_r[1:0] == 2'b00 ) ? dat_len_r[10:2] : dat_len_r[10:2] + 1'b1;
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        ram_valid                  <= 1'b0;
    else if( dat_flag[1] == 1'b1 ) begin
        case( ram_ptr )
            group_id :  ram_valid  <= 1'b1;        
            default :   ram_valid  <= 1'b0;
        endcase
    end
    else 
        ram_valid                  <= 1'b0;    
end 

always  @(posedge user_clk) begin
    if( ( user_reset == 1'b1 )  || ( ram_valid == 1'b0 ) )
        rdts               <= 1'b0;
    else if( ( ram_valid == 1'b1 ) && ( ts_add < 2'd3 ))
        rdts               <= 1'b1;
    else    
        rdts               <= 1'b0;
end

always  @(posedge user_clk) begin
    if( ( user_reset == 1'b1 ) || ( ram_valid == 1'b0 ))
        ts_add             <= 2'd0;
    else if( ( rdts == 1'b1 ) && ( ts_add < 2'd3 ) )    
        ts_add             <= ts_add + 1'b1;
    else        
        ts_add             <= ts_add;
end       

always  @(posedge user_clk) begin
    if( ( user_reset == 1'b1 )  || ( ram_valid == 1'b0 ) )
        rdeth              <= 1'b0;
    else if( ( ram_valid == 1'b1 ) && ( ts_add >= 2'd3 ) && ( eth_add <= dat_len_rr )) //1 more
        rdeth              <= 1'b1;
    else    
        rdeth              <= 1'b0;
end
 
always  @(posedge user_clk) begin
    if( ( user_reset == 1'b1 ) || ( ram_valid == 1'b0 ))
        eth_add            <= 2'd0;
    else if( rdeth == 1'b1 )    
        eth_add            <= eth_add + 1'b1;
    else        
        eth_add            <= eth_add;
end 

always  @(posedge user_clk) begin
    if( ( user_reset == 1'b1 ) || ( ram_valid == 1'b0 ) )
        cyc_extend         <= 1'b0;
    else if( flag_clr == 1'b1 ) 
        cyc_extend         <= 1'b1;
    else
        cyc_extend         <= cyc_extend;
end        

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        flag_clr           <= 1'b0;
    else if( cyc_extend == 1'b1 )
        flag_clr           <= 1'b0;
    else if( ( eth_add > dat_len_rr ) && ( cyc_extend == 1'b0 ) ) 
        flag_clr           <= 1'b1;
    else
        flag_clr           <= flag_clr;
end        
   
always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        rdts_r             <= {DAT_DLY{1'b0}};
    else
        rdts_r             <= {rdts_r[DAT_DLY - 2 : 0],rdts};
end

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        rdeth_r            <= {DAT_DLY{1'b0}};
    else
        rdeth_r            <= {rdeth_r[DAT_DLY - 2 : 0],rdeth};
end


always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        wrfifo_en           <= 1'b0;
    else
        wrfifo_en           <= rdts_r[DAT_DLY - 1] | rdeth_r[DAT_DLY - 1];
end    

always  @(posedge user_clk) begin
    if( user_reset == 1'b1 )
        wrfifo_dat          <= 32'h0;
    else if( rdts_r[DAT_DLY - 1] == 1'b1 )
        wrfifo_dat          <= ts_dat;
    else
        wrfifo_dat          <= eth_dat;
end

endmodule 

