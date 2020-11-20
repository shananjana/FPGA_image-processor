module uart(input wire clear,
				input wire clk_50m,
				output wire Tx,
				input wire Rx,
				output wire ready,
				input wire ready_clr,
				input wire en,
				input wire dis,
				output reg [7:0] data_in,
				output reg start,
				output wire[7:0] data_out,
				output reg [4:0] Proc_state,
				output reg state,
				output reg tester,
				output wire[9:0] PC,
				output wire[17:0] NA_to_out
				);
initial begin
  start=1'b0;
  data_in=8'b0;
  state=1'b0;
  tester=0;
end
wire [31:0] rows_to_out;
wire[7:0] Ins_to_out;
wire [31:0] SP1_to_out; 
wire [31:0] ncols_to_out;
wire [31:0] AC_to_out;
wire [31:0] R_to_out;
wire [31:0] nrows_to_out;
wire [31:0] RNext_to_out;
wire [31:0] TNext_to_out;
wire [31:0] cols_to_out;
wire [31:0] SP2_to_out;
wire [31:0] SP3_to_out;
wire [17:0] Ad_to_out;
wire [ 7:0] data_to_out;
wire [ 7:0] operands;
wire [ 7:0] q;
wire        Z;
wire        Tx_busy;
wire        Rx_busy;
wire        Rxclk_en;
wire        Txclk_en;
reg  [17:0] address;
reg  [28:0] enables=29'b0;
wire clk;
clock clk1(clk,clk_50m);
AC AC(enables[13:9] ,AC_to_out, Z,R_to_out,ncols_to_out,nrows_to_out,rows_to_out,cols_to_out,SP1_to_out,SP2_to_out,SP3_to_out,q,operands,NA_to_out,clk_50m);
SP        Num_cols(clk_50m,enables[2] ,AC_to_out,ncols_to_out);
SP        Num_rows(clk_50m,enables[3] ,AC_to_out,nrows_to_out);
SP        Rows(clk_50m, enables[5],AC_to_out,rows_to_out);
SP        Cols(clk_50m, enables[4],AC_to_out,cols_to_out);
Next_Address next_address(clk_50m, enables[14], AC_to_out, NA_to_out);
Rx_TX_regs r_next(clk_50m,enables[21:20], RNext_to_out);
Rx_TX_regs t_next(clk_50m,enables[19:18], TNext_to_out);
IU IU(clk_50m,Ins_to_out,operands,enables[26:24],PC);
SP SP1(clk_50m,enables[23],AC_to_out,SP1_to_out);
SP SP2(clk_50m,enables[27],AC_to_out,SP2_to_out);
SP SP3(clk_50m,enables[28],AC_to_out,SP3_to_out);
SP R(clk_50m,enables[6],AC_to_out,R_to_out);
baudrate uart_baud(clk_50m,enables[17],Rxclk_en, Txclk_en);
transmitter uart_Tx(	data_in,enables[22],clk_50m,Txclk_en, Tx,Tx_busy);
receiver uart_Rx(	Rx,ready,ready_clr,clk_50m,Rxclk_en, data_out,Rx_busy);
Address_reg ad_reg(clk_50m,operands,NA_to_out,enables[8:7], Ad_to_out);
SDRAM RAM(Ad_to_out,clk_50m,data_to_out,enables[16],enables[15],q);
data data_reg(clk_50m,AC_to_out,data_out,enables[1:0],data_to_out);
always@ (posedge clk_50m) begin
 if(~dis) begin
   start<=0;
	enables<=29'b00100000000000000000000000000;
	state<=0;
 end
 if(~en) begin
   start<=1'b1;
	enables<=29'b00000000000000000000000000000;
 end
 if(start==1'b1) begin
   case(state)
	1'b0: begin
	  enables<=29'b00001000000000000000000000000;
	  Proc_state<=0;
	  state<=1'b1;
	end
	1'b1: begin
	  case(Ins_to_out)
	  0:begin
	    enables<=29'b00000000000000000000000000000;
		 state<=1'b0;
	  end
	  8'b1: begin
		  case(Proc_state) 
		  5'b0: begin
		   enables<=29'b00011001000000001011000000000;
			Proc_state<=5'b1;
		  end
		  5'b1: begin
		   enables<=29'b00000000000000001111000000000;
			Proc_state<=5'b10;
		  end
		  5'b10: begin
		   enables<=29'b00000000000000000101000000000;
			Proc_state<=5'b11;
		  end
		  5'b11: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b100;
		  end
		  5'b100: begin
		   enables<=29'b00000000000000001111000000000;
			Proc_state<=5'b101;
		  end
		  5'b101: begin
		   enables<=29'b00000000000000000101000000000;
			Proc_state<=5'b110;
		  end
		  5'b110: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b111;
		  end
		  5'b111: begin
		   enables<=29'b00000000000000001111000000000;
			Proc_state<=5'b1000;
		  end
		  5'b1000: begin
		   enables<=29'b00000100000000000000000000000;
			Proc_state<=5'b1001;
		  end
		  5'b1001: begin
		   if(SP1_to_out>RNext_to_out) begin
			  Proc_state<=5'b1010;
			  enables<=29'b00000000000000000000000000000;
			 end
			 else begin
			  enables<=29'b00000001000000000000000000000;
			  Proc_state<=5'b10011;
			 end
			end
		  5'b1010: begin
			 data_in<=8'd240;
			 enables<=29'b00000010100000000000000000000;
			 Proc_state<=5'b1011;
		  end
		  5'b1011: begin
		    enables<=29'b00000010000000000000000000000;
			 if(Tx_busy==1'b1) 
			    Proc_state<=5'b1100;
		  end
		  5'b1100: begin
		    enables<=29'b00000000000000000000000000000;
			 if(Tx_busy==0)
				Proc_state<=5'b1101;
		  end
		  5'b1101: begin
			 enables<=29'b00000000000100000000000000000;
			 Proc_state<=5'b1110;
		  end
		  5'b1110:begin
		      if(Rx_busy==1'b1) begin
				  Proc_state<=5'b1111;
				  enables<=29'b00000000000100001011000000000;
				end
				else
				  enables<=29'b00000000000100000000000000000;
				
		  end
		  5'b1111:begin
			if(Rx_busy==0) begin
			 enables<=29'b00000000000010010001010000010;
			 Proc_state<=5'b10000;
			end
			else
			 enables<=29'b00000000000100000000000000000;
		  end
		  5'b10000:begin
		    enables<=29'b00000000000000001100000000000;
			 Proc_state<=5'b10001;
		  end
		  5'b10001: begin
			 enables<=29'b00000000000000100000000000000;
			 Proc_state<=5'b10010;
		  end
		  5'b10010: begin
		    enables<=29'b00000000000000000000000000000;
			 Proc_state<=5'b1001;
		  end
		  5'b10011: begin
			 enables<=29'b00000000000000000000000000000;
			 state<=0;
		  end
		 endcase
	  end
	  8'b10: begin
	    case(Proc_state)
		  5'b0: begin
		   enables<=29'b00011000010000001011000000000;
			Proc_state<=5'b1;
		  end
		  5'b1: begin
		   enables<=29'b00000000000000001111000000000;
			Proc_state<=5'b10;
		  end
		  5'b10: begin
		   enables<=29'b00000000000000000101000000000;
			Proc_state<=5'b11;
		  end
		  5'b11: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b100;
		  end
		  5'b100: begin
		   enables<=29'b00000000000000001111000000000;
			Proc_state<=5'b101;
		  end
		  5'b101: begin
		   enables<=29'b00000000000000000101000000000;
			Proc_state<=5'b110;
		  end
		  5'b110: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b111;
		  end
		  5'b111: begin
		   enables<=29'b00000000000000001111000000000;
			Proc_state<=5'b1000;
		  end
		  5'b1000: begin
		   enables<=29'b00000100000000000000000000000;
			Proc_state<=5'b1001;
		  end
		  5'b1001: begin
		    if(SP1_to_out>TNext_to_out) begin
			  Proc_state<=5'b1010;
			  enables<=29'b00000000000000000000000000000;
			 end
			 else begin
			  enables<=29'b00000000010000001011000000000;
			  Proc_state<=5'b10000;
			 end
		  end
		  5'b1010: begin
		     enables<=29'b00000000000001010001010000000;
			  Proc_state<=5'b1011;
		  end
		  5'b1011: begin
		     enables<=29'b00000000000000001100000000000;
			  Proc_state<=5'b1100;
		  end
		  5'b1100:begin
		     enables<=29'b00000000000000100000000000000;
			  Proc_state<=5'b1101;
		  end
		  5'b1101: begin
		     enables<=29'b00000010001000000000000000000;
			  data_in<=q;
			  Proc_state<=5'b1110;
		  end
		  5'b1110: begin
		     enables<=29'b00000010000000000000000000000;
			  if(Tx_busy==1'b1)
			    Proc_state<=5'b1111;
		  end
		  5'b1111: begin
		     enables<=29'b00000000000000000000000000000;
			  if(Tx_busy==0)
			     Proc_state<=5'b1001;
		  end
		  5'b10000:begin
		     enables<=29'b00000000000000000000000000000;
			  state<=0;
		  end
		 endcase
	 end
	 8'b11: begin
	    case(Proc_state)
		  5'b0: begin
		   enables<=29'b00011000000000001011000000000;
			Proc_state<=5'b1;
		  end
		  5'b1: begin
		   enables<=29'b00000000000000000000100000000;
			Proc_state<=5'b10;
		  end
		  5'b10: begin
		   enables<=29'b00000000000000000000110000000;
			Proc_state<=5'b11;
		  end
		  5'b11: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b100;
		  end
		  5'b100: begin
		   enables<=29'b00000000000000000000100000000;
			Proc_state<=5'b101;
		  end
		  5'b101: begin
		   enables<=29'b00000000000000000000110000000;
			Proc_state<=5'b110;
		  end
		  5'b110: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b111;
		  end
		  5'b111: begin
		   enables<=29'b00000000000000000000100000000;
			Proc_state<=5'b1000;
		  end
		  5'b1000: begin
		   enables<=29'b00000000000001000000000000000;
			Proc_state<=5'b1001;
		  end
		  5'b1001: begin
		   enables<=29'b00000000000000000000000000000;
			Proc_state<=5'b1111;
		  end
		  5'b1111:begin
		   enables<=29'b00000000000000000000000000000;
			Proc_state<=5'b1010;
		  end
		  5'b1010:begin
		   enables<=29'b00000000000000001110000000000;
			Proc_state<=5'b1011;
		  end
		  5'b1011:begin
		   enables<=29'b00000000000000000000000000000;
			state<=0;
		  end
		 endcase
	 end
	 8'b100: begin
	   case(Proc_state)
		  5'b0: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b1;
		  end
		  5'b1: begin
		   enables<=29'b00000000000000000000100000000;
			Proc_state<=5'b10;
		  end
		  5'b10: begin
		   enables<=29'b00000000000000000000110000000;
			Proc_state<=5'b11;
		  end
		  5'b11: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b100;
		  end
		  5'b100: begin
		   enables<=29'b00000000000000000000100000000;
			Proc_state<=5'b101;
		  end
		  5'b101: begin
		   enables<=29'b00000000000000000000110000000;
			Proc_state<=5'b110;
		  end
		  5'b110: begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b111;
		  end
		  5'b111: begin
		   enables<=29'b00000000000000000000100000000;
			Proc_state<=5'b1000;
		  end
		  5'b1000: begin
		   enables<=29'b00000000000010000000000000001;
			Proc_state<=5'b1001;
		  end
		  5'b1001: begin
		   enables<=29'b00000000000000000000000000000;
			Proc_state<=5'b1010;
		  end
		  5'b1010:begin
		   enables<=29'b00000000000000000000000000000;
			Proc_state<=5'b1011;
		  end
		  5'b1011:begin
		   enables<=29'b00000000000000000000000000000;
			state<=0;
		  end
		 endcase
	 end
	 8'b101: begin
	    enables<=29'b00000000000000000101000000000;
		 state<=0;
	 end
	 8'b110: begin
	    enables<=29'b00000000000000000111000000000;
		 state<=0;
	 end
	 8'b111: begin
	    enables<=29'b00000000000000000110000000000;
		 state<=0;
	 end
	 8'b1000:begin
	    enables<=29'b00000000000000001000000000000;
		 state<=0;
	 end
	 8'b1001: begin
	    enables<=29'b00000000000000000000001000000;
		 state<=0;
	 end
	 8'b1010: begin
	    enables<=29'b00000000000000000000000100000;
		 state<=0;
	 end
	 8'b1011: begin
	    enables<=29'b00000000000000000100000000000;
		 state<=0;
	 end
	 8'b1100: begin
	    enables<=29'b00000000000000000000000010000;
		 state<=0;
	 end
	 8'b1101: begin
	    enables<=29'b00000000000000000011000000000;
		 state<=0;
	 end
	 8'b1110: begin
	    enables<=29'b00000000000000010010000000000;
		 state<=0;
	 end
	 8'b1111: begin
	    enables<=29'b00000000000000000000000000100;
		 state<=0;
	 end
	 8'b10000: begin
	    enables<=29'b00000000000000000010000000000;
		 state<=0;
	 end
	 8'b10001:begin
	    enables<=29'b00000000000000000000000001000;
		 state<=0;
	 end
	 8'b10010:begin
	    enables<=29'b00000000000000010001000000000;
		 state<=0;
	 end
	 8'b10011:begin
	  case(Proc_state)
		5'b0: begin
		   enables<=29'b00000000000010000000010000001;
			Proc_state<=5'b1;
		end
	   5'b1: begin
		   enables<=29'b00000000000000000000000000000;
		   Proc_state<=5'b10;
		end
		5'b10: begin
		   enables<=29'b00000000000000000000000000000;
		   Proc_state<=5'b11;
		end
		5'b11:begin
		   enables<=29'b00000000000000000000000000000;
		   state<=0;
		end
	 endcase
	 end
	 8'b10100:begin
	    case(Proc_state)
	     5'b0: begin
		   enables<=29'b00000000000001000000010000000;
			Proc_state<=5'b1;
		  end
		  5'b1: begin
		   enables<=29'b00000000000000000000000000000;
			Proc_state<=5'b10;
		  end
		  5'b10: begin
		   enables<=29'b00000000000000000000000000000;
			Proc_state<=5'b11;
		  end
		  5'b11:begin
		   enables<=29'b00000000000000001110000000000;
			Proc_state<=5'b100;
		  end
		  5'b100:begin
		   enables<=29'b00000000000000000000000000000;
			state<=0;
		  end
		 endcase
	 end
	 8'b10101:begin
	    enables<=29'b00000000000000001010000000000;
		 state<=0;
	 end
	 8'b10110:begin
	    enables<=29'b00000000000000000001000000000;
		 state<=0;
	 end
	 8'b10111: begin
	    enables<=29'b00000000000000001100000000000;
		 state<=0;
	 end
	 8'b11000: begin
	    enables<=29'b00000000000000001101000000000;
		 state<=0;
	 
	 end
	 8'b11001:begin
	    enables<=29'b00000000000000001011000000000;
		 state<=0;
	 end
	 8'b11010:begin
	  case(Proc_state)
	  5'b0: begin
		   if(Z==0) begin
			  enables<=29'b00010000000000000000000000000;
			  Proc_state<=5'b1;
			end
			else begin
			  enables<=29'b00011000000000000000000000000;
			  Proc_state<=5'b101;
			end
	  end
	  5'b1:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b10;
	  end
	  5'b10:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b11;
	  end
	  5'b11:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b100;
	  end
	  5'b100: begin
	    enables<=29'b00000000000000000000000000000;
		 state<=0;
	  end
	  5'b101:begin
	    enables<=29'b00011000000000000000000000000;
		 Proc_state<=5'b100;
	  end
	  endcase
	 end
	 8'b11011:begin
	  case(Proc_state)
	  5'b0:begin
	    enables<=29'b00010000000000000000000000000;
		 Proc_state<=5'b1;
	  end
	  5'b1:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b10;
	  end
	  5'b10:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b11;
	  end
	  5'b11:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b100;
	  end
	  5'b100: begin
	    enables<=29'b00000000000000000000000000000;
		 state<=0;
	  end
	  endcase
	 end
	 8'b11100:begin
	  case(Proc_state)
	  5'b0:begin
	    if(Z==1'b1) begin
	      enables<=29'b00010000000000000000000000000;
			Proc_state<=5'b1;
		 end
		 else begin
		   enables<=29'b00011000000000000000000000000;
			Proc_state<=5'b101;
		 end
		 
	  end
	  5'b1:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b10;
	  end
	  5'b10:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b11;
	  end
	  5'b11:begin
	    enables<=29'b00000000000000000000000000000;
		 Proc_state<=5'b100;
	  end
	  5'b100: begin
	    enables<=29'b00000000000000000000000000000;
		 state<=0;
	  end
	  5'b101:begin
	    enables<=29'b00011000000000000000000000000;
		 Proc_state<=5'b100;
	  end
	  endcase
	 end
	 8'b11101: begin
	   enables<=29'b00000000000000001001000000000;
		state<=0;
	 end
	 8'b11110: begin
	   enables<=29'b00000000000000010011000000000;
		state<=0;
	 end
	 8'b11111: begin
	   enables<=29'b00000100000000000000000000000;
		state<=0;
	 end
	 8'b100000:begin
	   enables<=29'b00000000000000010000000000000;
		state<=0;
	 end
	 8'b100001:begin
	   enables<=29'b00000000000000100000000000000;
		state<=0;
	 end
	 8'b100010:begin
	   enables<=29'b00000000000000010100000000000;
		state<=0;
	 end
	 8'b100011:begin
	   enables<=29'b00000000000000010101000000000;
		state<=0;
	 end
	 8'b100100:begin
	   enables<=29'b01000000000000000000000000000;
		state<=0;
	 end
	 8'b100101:begin
	   enables<=29'b10000000000000000000000000000;
		state<=0;
	 end
	 8'b100110:begin
	   enables<=29'b00000000000000000000000000000;
		start<=0;
	 end
	 endcase
   end
  endcase
 end
end
endmodule
