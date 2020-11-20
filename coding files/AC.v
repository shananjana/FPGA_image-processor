module AC (input wire  [ 4:0] enables,
           output wire [31:0] AC_to_out,
			  output wire        Z,
			  input wire  [31:0] R_to_AC,
			  input wire  [31:0] ncols_to_AC,
			  input wire  [31:0] nrows_to_AC,
			  input wire  [31:0] rows_to_AC,
			  input wire  [31:0] cols_to_AC,
			  input wire  [31:0] SP1_to_AC,
			  input wire  [31:0] SP2_to_AC,
			  input wire  [31:0] SP3_to_AC,
			  input wire  [7:0 ] memory_to_AC,
			  input wire  [7:0 ] Ins_to_AC,
			  input wire  [17:0] NA_to_AC,
			  input wire         clk
			  );
reg [31:0] AC;
always@(negedge clk) begin
  case(enables)
  5'b1: begin
    AC<=R_to_AC;
  end
  5'b10010: begin
    AC<=ncols_to_AC;
  end
  5'b10: begin
    AC<=nrows_to_AC;
  end
  5'b11: begin
    AC<=cols_to_AC;
  end
  5'b100:begin
    AC<=rows_to_AC;
  end
  5'b101:begin
    AC<=(AC<<8);
  end
  5'b110:begin
    AC<=(AC>>8);
  end
  5'b111:begin
    AC<=(AC<<1);
  end
  5'b1000:begin
    AC<=(AC>>1);
  end
  5'b1001:begin
    AC<=AC+R_to_AC;
  end
  5'b1010:begin
    AC<=AC^R_to_AC;
  end
  5'b1011:begin
    AC<=0;
  end
  5'b1100:begin
    AC<=AC+1;
  end
  5'b1101:begin
    AC<=AC-1;
  end
  5'b1110:begin
    AC[7:0]<=memory_to_AC;
  end
  5'b1111:begin
    AC[7:0]<=Ins_to_AC;
  end
  5'b10000:begin
    AC<=SP1_to_AC;
  end
  5'b10001:begin
    AC[17:0]<=NA_to_AC;
  end
  5'b10011:begin
    AC<=AC-R_to_AC; 
  end
  5'b10100:begin
    AC<=SP2_to_AC; 
  end
  5'b10101:begin
    AC<=SP3_to_AC;
  end
  default: begin
    
  end
  endcase
end
assign AC_to_out=AC;
assign Z=(AC==0);
endmodule