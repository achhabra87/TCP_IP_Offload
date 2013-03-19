module dflipflop(q,q1,d,clk);
output q,q1;
 input d,clk;
 reg q,q1;
	initial 
	   begin
		   q=1'b0; q1=1'b1;
	  end
	always @ (posedge clk)
	   begin 
		 q=d;
		 q1= ~d;
	   end
endmodule