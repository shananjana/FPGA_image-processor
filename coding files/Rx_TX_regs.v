module Rx_TX_regs(input wire clk,
                  input wire [1:0] enables,
						output wire [31:0] RT_to_out
						);
reg [31:0] RT=0;
always@(negedge clk) begin
 case(enables)
  2'b1: begin
   RT<=RT+1;
  end
  2'b10: begin
   RT<=0;
  end
  default: begin
    
  end
 endcase
end
assign RT_to_out=RT;
endmodule