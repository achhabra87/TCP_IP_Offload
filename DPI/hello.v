module hello_top;
int ret;
export "DPI-C" task verilog_task;
task verilog_task(input int ug, output int og);
#10;
$display("Hello from verilog_task()");
endtask
import "DPI-C" context task c_task(input int ug, output int og);
initial
begin
c_task(1, ret); // Call the c task named 'c_task()'
end
endmodule
