
module  pulse_gen(
                    input           user_clk,
                    input           user_reset,                 
                    
                    //input           clk_1m,
                    input           clk_125m,
                    input           pps,
                    
                    input [31:0]    pps_freq_cnt1,
                    input [31:0]    pps_freq_cnt2,
                    input           pps_freq_sel, 

                    output          pulse
                    );
                    
reg [3:0]            rst_1m; 
reg [3:0]            rst_125m;                   

reg [31:0]      freq_cnt1;
reg [31:0]      freq_cnt2;                    
                       
reg     pps_1m; 
reg     pps_125m; 
                  

always  @(posedge clk_125m) begin
    rst_125m    <= {rst_125m[2:0],user_reset};
end

reg [6:0]	clk_div_cnt;
wire 		clk_div_en;

always  @(posedge clk_125m) begin
	if( rst_125m[3] == 1'b1 )
		clk_div_cnt		<= 7'd0;
	else if( clk_div_cnt < 7'd124 )
        clk_div_cnt     <= clk_div_cnt + 1'b1;
    else
        clk_div_cnt     <= 7'd0;
end

assign  clk_div_en   = ( clk_div_cnt == 7'd124 ) ? 1'b1 : 1'b0 ;

always  @(posedge clk_125m) begin
    if( rst_125m[3] == 1'b1 )
        freq_cnt1           <= 32'd0;
    else if( clk_div_en == 1'b1 ) begin
        if( freq_cnt1 < pps_freq_cnt1 )
            freq_cnt1       <= freq_cnt1 + 1'b1;
        else
            freq_cnt1       <= 32'd0;
    end 
    else
        freq_cnt1           <= freq_cnt1;        
end    

always  @(posedge clk_125m) begin
    if( rst_125m[3] == 1'b1 )
        pps_1m          <= 1'b0;
    else if( freq_cnt1 >= 0 && freq_cnt1 <= 6)
        pps_1m          <= 1'b1;
    else
        pps_1m          <= 1'b0;
end

always  @(posedge clk_125m) begin
    if( rst_125m[3] == 1'b1 )
        freq_cnt2       <= 32'd0;
    else if( freq_cnt2 < pps_freq_cnt2 )
        freq_cnt2       <= freq_cnt2 + 1'b1;
    else
        freq_cnt2       <= 32'd0;
   
end

always  @(posedge clk_125m) begin
    if( rst_125m[3] == 1'b1 )
        pps_125m        <= 1'b0;
    else if( freq_cnt2 >= 0 &&  freq_cnt2 <= 6)
        pps_125m        <= 1'b1;
    else
        pps_125m        <= 1'b0;
end 


// reg [1:0]   pps_1m_d;
// reg [1:0]   pps_125m_d;

// always  @(posedge user_clk) begin
    // if( user_reset == 1'b1 )
        // pps_1m_d        <= 2'b00;
    // else
        // pps_1m_d        <= {pps_1m_d[0],pps_1m};
// end

// always  @(posedge user_clk) begin
    // if( user_reset == 1'b1 )
        // pps_125m_d        <= 2'b00;
    // else
        // pps_125m_d        <= {pps_125m_d[0],pps_125m};
// end


assign  pulse = ( pps_freq_sel == 1'b0 ) ? pps_1m : pps_125m;


endmodule 




