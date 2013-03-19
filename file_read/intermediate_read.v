module intermediate_read
(
	clock,
	reset,
	data_i,
	data_y,
	data_o
);
parameter out_bit=64;
parameter in_bit=8;


input reset;
input clock;
input[7:0] data_i;
output[63:0] data_o;
output[63:0] data_y;
reg [63:0] data_y;

wire clock;
wire reset;
wire [7:0] data_i;
reg [63:0] data_o;
reg [2:0] counter;
reg [2:0] jcounter;

initial counter=3'b000;
always @ (posedge clock)
begin: reading
	if(reset== 1'b0) begin
		data_y[7:0]<=data_i;
		data_y[63:8]<=data_y[55:0];
		counter=counter+1;
		if(counter==2) begin
			data_o[63:56]<=data_i;
		end else if(counter==3) begin
			data_o[55:48]<=data_i;	
		end else if(counter==4) begin
			data_o[47:40]<=data_i;
		end else if(counter==5) begin
			data_o[39:32]<=data_i;
		end else if(counter==6) begin
			data_o[31:24]<=data_i;
		end else if(counter==7) begin
			data_o[23:16]<=data_i;
		end else if(counter==0) begin
			data_o[15:8]<=data_i;
		end else if(counter==1) begin
			data_o[7:0]<=data_i;
		end
	end
end



endmodule
		