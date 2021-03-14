`define IncB 4'b0000
`define MovAB 4'b0001
`define MovBA 4'b0010
`define IncA 4'b0011
module main;
//Project 1
reg clk;
wire [5:0] Timing;
wire [3:0] Instruction;
wire [15:0] Decoded;

always #1 clk=~clk;
TSG counter1(clk,Timing);

//Project 2 (ALU & Program Counter)
wire [3:0] databus;
ProgramCounter PCount(databus, Timing[1],Timing[0]);

//Project 3 (MAR)
wire [3:0] MARaddress;
MemoryAccessRegister MAR1(databus,Timing[0],MARaddress); //clkout as input for MAR

//Project 4
RAM RAM1(MARaddress,Instruction,GND,1'b1);

//Project 5
wire BOut, BIn, AOut, AIn, SumIn, SumOut;
Decoder Decoder1(Instruction, Decoded);
CSG CSG1(Decoded, Timing[0], Timing[1], Timing[2], Timing[3], BOut, SumIn, SumOut, BIn, AOut, AIn);
dataregisterA drA(databus, AIn, AOut);
dataregisterB drB(databus, BIn, BOut);
ALU ALU1(databus, SumIn, SumOut);

initial begin
clk<=0;
$display ("Welcome to JDoodle!!!");

#100 $finish;
end
always @(*) begin
$display("%b %b %b %b",clk, Timing, databus, Instruction);
end

endmodule

//Project 1
module TSG(clk, T);
input clk;
output reg[5:0] T=6'b1;
always @(clk) begin

if(T==6'b100000)
T<=1;
else
#1 T<=T<<1;
end
endmodule

//Project 2
module ALU(bus,clkIn,clkOut);
inout [3:0] bus;
input clkIn,clkOut;
reg [3:0] ALUvalue=0;
always @(posedge clkIn) begin
#1 ALUvalue<=bus+1;
end
assign bus=clkOut?ALUvalue:4'bzzzz;
endmodule

module ProgramCounter(bus,clkIn,clkOut);
inout [3:0] bus;
input clkIn,clkOut;
reg [3:0] PCvalue=0;
always @(posedge clkIn) begin
#1 PCvalue<=bus;
end
assign bus=clkOut?PCvalue:4'bzzzz;
endmodule

//Project 3
module MemoryAccessRegister(bus, clkIn,MARaddress);//MAR, MARIn=clkIn;
input [3:0] bus;
input clkIn;
output [3:0] MARaddress;
reg [3:0] MARvalue;//This was MARvalue=0, but didn't work had to get rid of initilization
always @(posedge clkIn) begin
#1 MARvalue<=bus;
end
assign MARaddress = MARvalue;
endmodule

module dataregisterA(bus, clkIn,clkOut);
inout [3:0] bus;
input clkIn,clkOut;
reg [3:0] PCvalue=0;
always @(posedge clkIn) begin
#1 PCvalue<=bus;
end
assign bus=clkOut?PCvalue:4'bzzzz;
endmodule

module dataregisterB(bus, clkIn,clkOut);
inout [3:0] bus;
input clkIn,clkOut;
reg [3:0] PCvalue=0;
always @(posedge clkIn) begin
#1 PCvalue<=bus;
end
assign bus=clkOut?PCvalue:4'bzzzz;
endmodule
//Project 4
module RAM(address,bus,clkIn,clkOut);//clkIn=read;clkOut=write
input [3:0] address;
inout [3:0] bus;
input clkIn,clkOut;
reg [3:0] memory[15:0];
initial begin
memory[0]=`IncB;
memory[1]=`MovAB;
memory[2]=`MovBA;
memory[3]=`IncA;

end
always @(posedge clkIn) begin
#1 memory[address]<=bus;
end
assign bus=clkOut?memory[address]:4'bzzzz;
endmodule

//Project 5
module CSG(Decoded, T0, T1, T2, T3, BOut, SumIn, SumOut, BIn, AOut, AIn); //T0-3 will change later?
input [15:0] Decoded;
input T0, T1, T2, T3;
output BOut, SumIn, SumOut, BIn, AOut, AIn;

//Gate Control Signal Encoding
assign BOut=(Decoded[`IncB]&&T2) || (Decoded[`MovBA]&&T2);
assign BIn=(Decoded[`IncB]&&T3) || (Decoded[`MovAB]&&T2);
assign SumOut=(T1) || (T3&&Decoded[`IncB]) || (T3&&Decoded[`IncA]);
assign SumIn=(T0) || (T2&&Decoded[`IncB]) || (T2&&Decoded[`IncA]);
assign AIn = (Decoded[`MovBA] && T2) || (Decoded[`IncA] && T3);
assign AOut = (Decoded[`MovAB] && T2) || (Decoded[`IncA] && T2);

endmodule

module Decoder(instruct, decoded);
input [3:0] instruct;
output [15:0] decoded;

assign decoded = 1<<instruct;
endmodule