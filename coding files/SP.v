module SP(input wire clk,
         input wire    enable,
			input wire [31:0]   AC_to_SP,
			output wire [31:0] SP_to_out
			);
reg [31:0] SP=0;
always@(negedge clk) begin
	if(enable==1'b1)
	  SP<=AC_to_SP;
end
assign SP_to_out=SP;
endmodule