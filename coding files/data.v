module data(input wire clk,
            input wire[31:0] AC_to_data,
				input wire[7:0]  tr_to_data,
		      input wire[1:0]  enables,
				output wire[7:0] data_to_out
				);
reg [7:0] data;
always@ (negedge clk) begin
  case(enables)
   2'b1: begin
     data<=AC_to_data[7:0];
	end
   2'b10:begin
     data<=tr_to_data;
	end
	default:begin
	end
  endcase
end
assign data_to_out=data;
endmodule