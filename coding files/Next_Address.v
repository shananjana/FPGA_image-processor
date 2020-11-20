module Next_Address(input wire clk,
                    input wire enables,
						  input wire[31:0] AC_to_NA,
						  output wire[17:0] NA_to_out
						  );
reg [17:0]  NA=0;
always@(negedge clk) begin
 case(enables)
   1'b1: begin
    NA<=AC_to_NA[17:0];
	end
	default: begin
	  
	end
  endcase
end
assign NA_to_out=NA;
endmodule