module pll_1k(
	input clk_in,  // 50MHz时钟
	output reg clk_out  // 1KHz时钟
);
 
reg [16:0] cnt;

initial
begin
cnt= 16'd0 ;
clk_out = 0;
end


always @(posedge clk_in)
begin
if(cnt == 16'd24_999) 
	begin
	clk_out = ~clk_out;
	cnt <= 0;
	end
else
	cnt <= cnt + 17'd1;
end

endmodule