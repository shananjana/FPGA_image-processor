module Address_reg(input wire clk,
                    input wire [7:0] Ins,
						  input wire [17:0] Na,
						  input wire[1:0] enables,
						  output wire[17:0] Add_to_out
						  );
reg [17:0] Address_reg;
always@(negedge clk) begin
  case(enables)
  2'b1: begin
    Address_reg<=Na;
  end
  2'b10:begin
    Address_reg[7:0]<=Ins;
  end
  2'b11:begin
     Address_reg<=(Address_reg<<8);
  end
  default: begin
  end
  endcase
end
assign Add_to_out=Address_reg;
endmodule