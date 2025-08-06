`timescale 1ns / 1ps



module tb_CLA_try();

reg [3:0] a,b;
reg cin;
wire [3:0] sum;
wire cout;

CLA_try dut (.a(a),.b(b),.cin(cin),.Sum(sum),.C(cout));

integer i=0;

initial begin
for(i=0;i<20;i=i+1)
begin
a=$urandom % 16;
b=$urandom % 16;
cin=1'b0;
#20;
$display("Time=%0t | a=%b b=%b cin=%b | sum=%b cout=%b", $time, a, b, cin, sum, cout);
end
end
    
initial begin 

#500;
$finish;
end



endmodule
