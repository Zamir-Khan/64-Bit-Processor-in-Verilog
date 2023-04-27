//========================================================================
// Written in Verilog using Icarus Verilog extension on Visual Studio Code
//========================================================================

//========================================================================
// Breadboard
//========================================================================
module breadboard(clk,rst,A,B,C,opcode,error);

// Parameter Definitions
input clk;
input rst;
input 	[31:0] A;
input 	[31:0] B;
input 	[3:0] opcode;
output 	[63:0] C;
output 	[1:0]error;

wire clk;
wire rst;

wire 	[31:0] A;
wire 	[31:0] B;
wire 	[3:0] opcode;
reg  	[63:0] C;
reg  	[1:0] error;

//------------------------------------------------------------------------
// CONTROL
//------------------------------------------------------------------------
wire [15:0] select;
Dec4x16 dec1(opcode,select);

wire [15:0][ 31:0] channels;
wire       [ 63:0] b;
wire       [ 3:0] unknown;

wire [15:0][ 1:0]  chErr;
wire       [ 1:0]   bErr;
wire       [ 1:0] unkErr;

//------------------------------------------------------------------------
// INTERFACES
//------------------------------------------------------------------------

// ADDITION
wire [63:0] outputADDSUB;
wire ADDerror;
wire Carry;

// SUBTRACTION
reg modeSUB;

// DIVISION/MODULUS
wire [63:0] outputQuotient;
wire [63:0] outputRemainder;
wire DIVerror;


// GATE LOGIC 
wire [63:0] outputAND;
wire [63:0] outputOR;
wire [63:0] outputNOT;
wire [63:0] outputNAND;
wire [63:0] outputNOR;
wire [63:0] outputXOR;
wire [63:0] outputXNOR;
wire [63:0] outputMultiply;

//------------------------------------------------------------------------
// Error Reporting
//------------------------------------------------------------------------
reg errHigh;
reg errLow;

reg [31:0] regA;
reg [31:0] regB;

reg [63:0] next;
wire [63:0] cur;

//========================================================================
// Connect the MUX to the OpCodes
//
// Channel 0, Opcode 0000, No-Op
// Channel 1, Opcode 0001, Reset
// Channel 2, Opcode 0010, AND
// Channel 3, Opcode 0011, OR
// Channel 4, Opcode 0100, ADD
// Channel 5, Opcode 0101, Subtraction
// Channel 6, Opcode 0110, NOT
// Channel 7, Opcode 0111, NAND
// Channel 8, Opcode 1000, Division (Behavioral)
// Channel 9, Opcode 1001, Modulus (Behavioral)
// Channel 10, Opcode 1010, NOR
// Channel 11,Opcode 1011, XOR
// Channel 12,Opcode 1100, XNOR
// Channel 13,Opcode 1101, Algorithmic Multiplication
//========================================================================
 
assign channels[ 0]=cur;
assign channels[ 1]=0;
assign channels[ 2]=outputAND; 
assign channels[ 3]=outputOR;
assign channels[ 4]=outputADDSUB; 
assign channels[ 5]=outputADDSUB;
assign channels[ 6]=outputNOT;
assign channels[ 7]=outputNAND;
assign channels[ 8]=outputQuotient;
assign channels[ 9]=outputRemainder;
assign channels[10]=outputNOR;
assign channels[11]=outputXOR;
assign channels[12]=outputXNOR;
assign channels[13]=outputMultiply;
assign channels[14]=unknown;
assign channels[15]=unknown;

 
assign chErr[ 0]={1'b0,errLow};
assign chErr[ 1]={1'b0,errLow};
assign chErr[ 2]={1'b0,errLow};
assign chErr[ 3]={1'b0,errLow};
assign chErr[ 4]={1'b0,errLow};
assign chErr[ 5]={1'b0,errLow};
assign chErr[ 6]={1'b0,errLow};
assign chErr[ 7]={1'b0,errLow};
assign chErr[ 8]={errHigh,1'b0};
assign chErr[ 9]={errHigh,1'b0};
assign chErr[10]={1'b0,errLow};
assign chErr[11]={1'b0,errLow};
assign chErr[12]={1'b0,errLow};
assign chErr[13]={1'b0,errLow};
assign chErr[14]=unkErr;
assign chErr[15]=unkErr;


//------------------------------------------------------------------------
// INSTANTIATE MODULES
//------------------------------------------------------------------------
ThirtyTwoBitAddSub add1(regB,regA,modeSUB,outputADDSUB,Carry,ADDerror); 
BehavioralDivision div1(regB,regA,outputQuotient,outputRemainder,DIVerror);
StructMux64 muxOps(channels,select,b);
StructMux2 muxErr(chErr,select,bErr);
ANDER and1(regB,regA,outputAND);
ORER  or1(regB,regA,outputOR);
NOTER nt1(regB,outputNOT);
NANDER nd1(regB,regA,outputNAND);
NORER nr1(regB,regA,outputNOR);
XORER xr1(regB,regA,outputXOR);
XNORER xnr1(regB,regA,outputXNOR);

//Accumumulator Register
DFF ACC1 [63:0] (clk,next,cur);

algorithmicMultiplier M0 (outputMultiply, regB, regA);



//------------------------------------------------------------------------
//Perform the gate-level operations in the Breadboard
//------------------------------------------------------------------------ 
always@(*)
begin

	regA = A;
	regB = cur[31:0]; 
	
	//Check for Subtraction Mode
  	modeSUB=~opcode[3]& opcode[2]&~opcode[1]& opcode[0]; //0101, Channel 5
    
  	// Set output of Operations to C
  	
	assign C=b; //Just a jumper
  	assign next = b;
	
	
	errHigh=DIVerror;
  	errLow=ADDerror;

  	// Set Errors of Operations to Error
  	error=bErr;
	
	end

endmodule

//------------------------------------------------------------------------
// 4x16 Decoder
//------------------------------------------------------------------------
module Dec4x16(binary,onehot);
	input [3:0] binary;
	output [15:0]onehot;
	
	assign onehot[ 0]=~binary[3]&~binary[2]&~binary[1]&~binary[0];
	assign onehot[ 1]=~binary[3]&~binary[2]&~binary[1]& binary[0];
	assign onehot[ 2]=~binary[3]&~binary[2]& binary[1]&~binary[0];
	assign onehot[ 3]=~binary[3]&~binary[2]& binary[1]& binary[0];
	assign onehot[ 4]=~binary[3]& binary[2]&~binary[1]&~binary[0];
	assign onehot[ 5]=~binary[3]& binary[2]&~binary[1]& binary[0];
	assign onehot[ 6]=~binary[3]& binary[2]& binary[1]&~binary[0];
	assign onehot[ 7]=~binary[3]& binary[2]& binary[1]& binary[0];
	assign onehot[ 8]= binary[3]&~binary[2]&~binary[1]&~binary[0];
	assign onehot[ 9]= binary[3]&~binary[2]&~binary[1]& binary[0];
	assign onehot[10]= binary[3]&~binary[2]& binary[1]&~binary[0];
	assign onehot[11]= binary[3]&~binary[2]& binary[1]& binary[0];
	assign onehot[12]= binary[3]& binary[2]&~binary[1]&~binary[0];
	assign onehot[13]= binary[3]& binary[2]&~binary[1]& binary[0];
	assign onehot[14]= binary[3]& binary[2]& binary[1]&~binary[0];
	assign onehot[15]= binary[3]& binary[2]& binary[1]& binary[0];
	
endmodule


//------------------------------------------------------------------------
// 32-Bit Adder 
//------------------------------------------------------------------------
module ThirtyTwoBitAddSub(inputA,inputB,mode,sum,carry,overflow);
//parameters    
input [31:0] inputA;
input [31:0] inputB;
input mode;
output [63:0] sum;
output carry;
output overflow;
	
wire [31:0] inputA;
wire [31:0] inputB;
wire mode;
	
reg carry;
reg overflow;
 

//Local Variables
wire c0; //MOde assigned to C0
wire b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, 
		b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, 
		b28, b29, b30, b31; //XOR Interfaces

wire c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, 
		c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, 
		c29, c30, c31, c32; //Carry Interfaces

assign c0=mode;//Mode=0, Addition; Mode=1, Subtraction
	
//    WIRE    WIRE      WIRE	
assign b0 = inputB[0] ^ mode;
assign b1 = inputB[1] ^ mode;
assign b2 = inputB[2] ^ mode;
assign b3 = inputB[3] ^ mode;
assign b4 = inputB[4] ^ mode;
assign b5 = inputB[5] ^ mode;
assign b6 = inputB[6] ^ mode;
assign b7 = inputB[7] ^ mode;
assign b8 = inputB[8] ^ mode;
assign b9 = inputB[9] ^ mode;
assign b10 = inputB[10] ^ mode;
assign b11 = inputB[11] ^ mode;
assign b12 = inputB[12] ^ mode;
assign b13 = inputB[13] ^ mode;
assign b14 = inputB[14] ^ mode;
assign b15 = inputB[15] ^ mode;
assign b16 = inputB[16] ^ mode;
assign b17 = inputB[17] ^ mode;
assign b18 = inputB[18] ^ mode;
assign b19 = inputB[19] ^ mode;
assign b20 = inputB[20] ^ mode;
assign b21 = inputB[21] ^ mode;
assign b22 = inputB[22] ^ mode;
assign b23 = inputB[23] ^ mode;
assign b24 = inputB[24] ^ mode;
assign b25 = inputB[25] ^ mode;
assign b26 = inputB[26] ^ mode;
assign b27 = inputB[27] ^ mode;
assign b28 = inputB[28] ^ mode;
assign b29 = inputB[29] ^ mode;
assign b30 = inputB[30] ^ mode;
assign b31 = inputB[31] ^ mode;

 
FullAdder FA0(inputA[0],b0,c0,c1,sum[0]);
FullAdder FA1(inputA[1],b1,c1,c2,sum[1]);
FullAdder FA2(inputA[2],b2,c2,c3,sum[2]);
FullAdder FA3(inputA[3],b3,c3,c4,sum[3]);
FullAdder FA4(inputA[4],b4,c4,c5,sum[4]);
FullAdder FA5(inputA[5],b5,c5,c6,sum[5]);
FullAdder FA6(inputA[6],b6,c6,c7,sum[6]);
FullAdder FA7(inputA[7],b7,c7,c8,sum[7]);
FullAdder FA8(inputA[8],b8,c8,c9,sum[8]);
FullAdder FA9(inputA[9],b9,c9,c10,sum[9]);
FullAdder FA10(inputA[10],b10,c10,c11,sum[10]);
FullAdder FA11(inputA[11],b11,c11,c12,sum[11]);
FullAdder FA12(inputA[12],b12,c12,c13,sum[12]);
FullAdder FA13(inputA[13],b13,c13,c14,sum[13]);
FullAdder FA14(inputA[14],b14,c14,c15,sum[14]);
FullAdder FA15(inputA[15],b15,c15,c16,sum[15]);
FullAdder FA16(inputA[16],b16,c16,c17,sum[16]);
FullAdder FA17(inputA[17],b17,c17,c18,sum[17]);
FullAdder FA18(inputA[18],b18,c18,c19,sum[18]);
FullAdder FA19(inputA[19],b19,c19,c20,sum[19]);
FullAdder FA20(inputA[20],b20,c20,c21,sum[20]);
FullAdder FA21(inputA[21],b21,c21,c22,sum[21]);
FullAdder FA22(inputA[22],b22,c22,c23,sum[22]);
FullAdder FA23(inputA[23],b23,c23,c24,sum[23]);
FullAdder FA24(inputA[24],b24,c24,c25,sum[24]);
FullAdder FA25(inputA[25],b25,c25,c26,sum[25]);
FullAdder FA26(inputA[26],b26,c26,c27,sum[26]);
FullAdder FA27(inputA[27],b27,c27,c28,sum[27]);
FullAdder FA28(inputA[28],b28,c28,c29,sum[28]);
FullAdder FA29(inputA[29],b29,c29,c30,sum[29]);
FullAdder FA30(inputA[30],b30,c30,c31,sum[30]);
FullAdder FA31(inputA[31],b31,c31,c32,sum[31]);


always@(*)
begin
	 overflow=c32^c31;
	 end
 
endmodule


//------------------------------------------------------------------------
// 1-Bit Adder
//------------------------------------------------------------------------
module FullAdder(A,B,C,carry,sum);
input A;
input B;
input C;
output carry;
output sum;

wire A;
wire B;
wire C;
reg carry;
reg sum;

always@(*) 
  begin
	  sum= A^B^C;
	  carry= ((A^B)&C)|(A&B);  
	  end

endmodule


//------------------------------------------------------------------------
// 2x16 Error MUX
//------------------------------------------------------------------------
module StructMux2(channels, select, b);
parameter chansize=2;
input [15:0][chansize-1:0] channels;
input [15:0]               select;
output      [chansize-1:0] b;

assign b = ({chansize{select[15]}} & channels[15]) | 
			({chansize{select[14]}} & channels[14]) |
			({chansize{select[13]}} & channels[13]) |
			({chansize{select[12]}} & channels[12]) |
			({chansize{select[11]}} & channels[11]) |
			({chansize{select[10]}} & channels[10]) |
			({chansize{select[ 9]}} & channels[ 9]) | 
			({chansize{select[ 8]}} & channels[ 8]) |
			({chansize{select[ 7]}} & channels[ 7]) |
			({chansize{select[ 6]}} & channels[ 6]) |
			({chansize{select[ 5]}} & channels[ 5]) |  
			({chansize{select[ 4]}} & channels[ 4]) |  
			({chansize{select[ 3]}} & channels[ 3]) |  
			({chansize{select[ 2]}} & channels[ 2]) |  
			({chansize{select[ 1]}} & channels[ 1]) |  
			({chansize{select[ 0]}} & channels[ 0]) ;

endmodule


//------------------------------------------------------------------------
// 64x16 MUX
//------------------------------------------------------------------------
module StructMux64(channels, select, b);
parameter chansize=64;
input [15:0][chansize-63:32] channels;
input [15:0]      		   	select;
output      [chansize-1:0] b;

assign b = ({chansize{select[15]}} & channels[15]) | 
			({chansize{select[14]}} & channels[14]) |
			({chansize{select[13]}} & channels[13]) |
			({chansize{select[12]}} & channels[12]) |
			({chansize{select[11]}} & channels[11]) |
			({chansize{select[10]}} & channels[10]) |
			({chansize{select[ 9]}} & channels[ 9]) | 
			({chansize{select[ 8]}} & channels[ 8]) |
			({chansize{select[ 7]}} & channels[ 7]) |
			({chansize{select[ 6]}} & channels[ 6]) |
			({chansize{select[ 5]}} & channels[ 5]) |  
			({chansize{select[ 4]}} & channels[ 4]) |  
			({chansize{select[ 3]}} & channels[ 3]) |  
			({chansize{select[ 2]}} & channels[ 2]) |  
			({chansize{select[ 1]}} & channels[ 1]) |  
			({chansize{select[ 0]}} & channels[ 0]) ;

endmodule

//------------------------------------------------------------------------
//AND Module
//------------------------------------------------------------------------
module ANDER(inputA,inputB,outputC);
input  [31:0] inputA;
input  [31:0] inputB;
output [63:0] outputC;
wire   [31:0] inputA;
wire   [31:0] inputB;
reg    [63:0] outputC;

reg    [63:0] result;

always@(*)
begin
 
	result=inputA&inputB;
	outputC=result;
end
 
endmodule

//------------------------------------------------------------------------
//OR Module
//------------------------------------------------------------------------
module ORER(inputA,inputB,outputC);
input  [31:0] inputA;
input  [31:0] inputB;
output [63:0] outputC;
wire   [31:0] inputA;
wire   [31:0] inputB;
reg    [63:0] outputC;

reg    [63:0] result;

always@(*)
begin
 
	result=inputA|inputB;
	outputC=result;
end
 
endmodule

//------------------------------------------------------------------------
//NOT Module
//------------------------------------------------------------------------
module NOTER(inputB,outputC);
input  [31:0] inputB;
output [63:0] outputC;

wire   [31:0] inputB;
reg    [63:0] outputC;

reg    [63:0] result;

always@(*)
begin
 
	result= ~inputB;
	outputC=result;
end
 
endmodule

//------------------------------------------------------------------------
//NAND Module
//------------------------------------------------------------------------
module NANDER(inputA,inputB,outputC);
input  [31:0] inputA;
input  [31:0] inputB;
output [63:0] outputC;
wire   [31:0] inputA;
wire   [31:0] inputB;
reg    [63:0] outputC;

reg    [63:0] result;

always@(*)
begin
 
	result= ~(inputA&inputB);
	outputC=result;
end
 
endmodule

//------------------------------------------------------------------------
//NOR Module
//------------------------------------------------------------------------
module NORER(inputA,inputB,outputC);
input  [31:0] inputA;
input  [31:0] inputB;
output [63:0] outputC;
wire   [31:0] inputA;
wire   [31:0] inputB;
reg    [63:0] outputC;

reg    [63:0] result;

always@(*)
begin
 
	result= ~(inputA|inputB);
	outputC=result;
end
 
endmodule

//------------------------------------------------------------------------
//XOR Module
//------------------------------------------------------------------------
module XORER(inputA,inputB,outputC);
input  [31:0] inputA;
input  [31:0] inputB;
output [63:0] outputC;
wire   [31:0] inputA;
wire   [31:0] inputB;
reg    [63:0] outputC;

reg    [63:0] result;

always@(*)
begin
 
	result=inputA ^ inputB;
	outputC=result;
end
 
endmodule

//------------------------------------------------------------------------
//XNOR Module
//------------------------------------------------------------------------
module XNORER(inputA,inputB,outputC);
input  [31:0] inputA;
input  [31:0] inputB;
output [63:0] outputC;
wire   [31:0] inputA;
wire   [31:0] inputB;
reg    [63:0] outputC;

reg    [63:0] result;

always@(*)
begin
 
	result= ~(inputA^inputB);
	outputC=result;
end
 
endmodule

//------------------------------------------------------------------------
// Behavioral Division
//------------------------------------------------------------------------
module BehavioralDivision (dividend, divisor,quotient,remainder,error);
input 	[31:0] dividend;
input 	[31:0] divisor;
output 	[63:0] quotient;
output 	[63:0] remainder;
output error;

wire [31:0] dividend;
wire [31:0] divisor;
reg [63:0] quotient;
reg [63:0] remainder;
reg error;

always @(dividend,divisor)
begin
	quotient =dividend/divisor;
	remainder=dividend%divisor;
	
	error=~(divisor[31]|divisor[30]|divisor[29]|divisor[28]|divisor[27]|
			divisor[26]|divisor[25]|divisor[24]|divisor[23]|divisor[22]|
			divisor[21]|divisor[20]|divisor[19]|divisor[18]|divisor[17]|
			divisor[16]|divisor[15]|divisor[14]|divisor[13]|divisor[12]|
			divisor[11]|divisor[10]|divisor[9]|divisor[8]|divisor[7]|divisor[6]|
			divisor[5]|divisor[4]|divisor[3]|divisor[2]|divisor[1]|divisor[0]);
			
			end

endmodule

//------------------------------------------------------------------------
//D Flip-Flop 
//------------------------------------------------------------------------
module DFF(clk,in,out);
	input   clk;
	input   in;
	output  out;
	reg     out;

	always @(posedge clk)
	out = in;
endmodule

//------------------------------------------------------------------------
// Algorithmic Multiplier (PART4)
//------------------------------------------------------------------------
module algorithmicMultiplier #(parameter dp_width = 32) (

output [2*dp_width -1: 0] Product, input [dp_width -1: 0] Multiplicand, Multiplier);

reg [dp_width -1: 0]	A, B, Q;	// Sized for datapath
reg	C;

integer	k;
assign	Product = {C, A, Q};
always @ (Multiplier, Multiplicand) begin
 Q = Multiplier;
 B = Multiplicand;
 C = 0;
 A = 0;

 for (k = 0; k <= dp_width -1; k = k + 1) begin
 if (Q[0])
	{C, A} = A + B;
    {C, A, Q} = ({C, A, Q} >> 1);
    end
    end
endmodule


//========================================================================
//TEST BENCH
//========================================================================
module testbench();

//Local Variables
reg clk;
reg rst;
reg  [31:0]	temp;
reg  [31:0] temp2;
reg  [31:0] inputB;
reg  [31:0] inputA;
reg  [3:0] opcode;
wire [63:0] outputC;
wire [1:0] error;
   
// Create Breadboard
breadboard bb8(clk,rst,inputA,inputB,outputC,opcode,error);

//=================================================
//CLOCK Thread
//=================================================
initial begin //Start Clock Thread
forever //While TRUE
	begin //Do Clock Procedural
          clk=0; //square wave is low
          #5; //half a wave is 5 time units
          clk=1;//square wave is high
          #5; //half a wave is 5 time units
		  //$display("Tick");
        end
end 

//------------------------------------------------------------------------
// STIMULOUS
//------------------------------------------------------------------------
initial begin//Start Stimulous Thread
	
    #6
    //---------------------------------
	opcode=4'b0000;//NO-OP
	#10; 
	//---------------------------------
	opcode=4'b0001;//RESET
	#10
	//--------------------------------------------------------------------------------------
	
	// Equation 01
	$display("**************************************");
	$display("            Area of a Square          ");
	$display("**************************************");

    inputA=32'd4;
	opcode=4'b0100; //ADDITION, for loading the side length
	#10;
	$display("Length of Side: %1d m", bb8.regB);

	opcode= 4'b1101; //Algo Multiplication to calculate square power		
	
	#10
	$display("The Area of Square: %1d * %1d = %1d m^2", bb8.regA, bb8.regA, bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	//Equation 02
	$display("**************************************");
	$display("         Perimeter of a Square        ");
	$display("**************************************");

	inputA= 32'd2;
	opcode= 4'b0100; //Adding/loading the side length
	#10

	temp = bb8.regB;
	$display("Length of Side: %1d m", temp);
	

	inputA= 32'd4;	//loading the multipicand
	opcode= 4'b1101; //Multiplying using Algo Multiplier
	#10

	$display("Perimiter of Square: %1d * %1d = %1d m", temp,inputA,bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	// Equation 03
	$display("**************************************");
	$display("       Area of a Parallelogram        ");
	$display("**************************************");

	inputA= 32'd4;
	opcode= 4'b0100; //Adding/loading the height
	#10

	temp = bb8.regB;
	$display("Height of Parallelogram: %1d m", temp);
	
	inputA= 32'd8;	// loading the base 
	$display("Base of Parallelogram: %1d m",inputA);
	opcode= 4'b1101; // Multiplying for area
	#10
	
	$display("Area of Parallelogram: %1d * %1d = %1d m^2", temp,inputA,bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	// Equation 04
	$display("**************************************");
	$display("    Perimeter of a Parallelogram      ");
	$display("**************************************");
	
	inputA= 32'd6;
	opcode= 4'b0100; //Adding/loading the side
	#10

	temp = bb8.regB;
	$display("Side of Parallelogram: %1d m", temp);

	inputA= 32'd8;
	temp2= inputA;
	opcode= 4'b0100; //Adding/loading the base
	#10
	$display("Base of Parallelogram: %1d m",inputA);

	
	inputA= 32'd2;
	opcode= 4'b1101; //Multiply, 2*(side+base)
	#10
	
	$display("Perimeter of Parallelogram: %1d * (%1d + %1d) = %1d m", inputA,temp,temp2,bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	// Equation 05
	$display("**************************************");
	$display("         Area of a Rectangle          ");
	$display("**************************************");

	inputA= 32'd10;
	opcode= 4'b0100; //Adding/loading the length
	#10

	temp = bb8.regB;
	$display("Length of Rectangle: %1d m", temp);
	
	inputA= 32'd5;	// loading the width 
	$display("Width of Rectangle: %1d m",inputA);
	opcode= 4'b1101; // Multiplying for area
	#10
	
	$display("Area of Rectangle: %1d * %1d = %1d m^2", temp,inputA,bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	// Equation 06
	$display("**************************************");
	$display("       Perimeter of a Rectange        ");
	$display("**************************************");
	
	inputA= 32'd10;
	opcode= 4'b0100; //Adding/loading the length
	#10

	temp = bb8.regB;
	$display("Length of Rectangle: %1d m", temp);

	inputA= 32'd5; //loading then adding the width
	temp2= inputA;
	opcode= 4'b0100; //Adding
	#10
	$display("Width of Rectangle: %1d m",temp2);

	
	inputA= 32'd2;
	opcode= 4'b1101; //Multiply, 2*(length+width)
	#10
	
	$display("Perimeter of Rectangle: %1d * (%1d + %1d) = %1d m", inputA,temp,temp2,bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	// Equation 07
	$display("**************************************");
	$display("     Volume of a Rectangular Prism    ");
	$display("**************************************");

	inputA= 32'd10;
	opcode= 4'b0100;
	#10

	temp = bb8.regB;
	$display("Length of Prism: %1d m", temp);

	inputA= 32'd5;
	temp2= inputA;
	opcode= 4'b1101; //Multiply
	#10

	$display("Width of Prism: %1d m",temp2);

	inputA= 32'd7;
	$display("Height of Prism: %1d m",inputA);
	opcode= 4'b1101; //Mult
	#10

	$display("Volume of Rectangluar Prism: %1d * %1d * %1d = %1d m^3",temp,temp2,inputA,bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	// Equation 08
	$display("**************************************");
	$display("            Volume of a Cube          ");
	$display("**************************************");

	inputA= 32'd13; //edge length
	opcode= 4'b0100;
	#10

	temp = bb8.regB;

	$display("Edge length of Cube: %1d m",temp);

	inputA= temp;
	opcode= 4'b1101; //mult
	#10

	inputA= temp;
	opcode= 4'b1101;
	#10

	$display("Volume of the Cube: %1d * %1d * %1d = %1d m^3",temp,temp,temp,bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------

	// Equation 09
	$display("**************************************");
	$display("     Newton's Equation of Motion      ");
	$display("**************************************");

	inputA= 32'd15; //Acceleration
	opcode= 4'b0100;
	#10

	temp = bb8.regB;
	$display("Acceleration a: %1d m/s^2",temp);

	inputA= 32'd7; //Time
	temp2= inputA;
	opcode= 4'b1101; 
	#10

	$display("Time t: %1d s",temp2);

	inputA= 32'd10; //initial velocity
	$display("Initial Velocity u: %1d m/s^2",inputA);
	opcode= 4'b0100;
	#10

	$display("The Velocity v = u+at = %1d + (%1d * %1d) = %1d m/s", inputA, temp, temp2, bb8.regB);
	$display("\n");

	//--------------------------------------------------------------------------------------
	//RESET
	opcode = 4'b0001;
	#10
	//--------------------------------------------------------------------------------------
	
	// Equation 10
	$display("**************************************");
	$display("         Newton's Second Law          ");
	$display("**************************************");

	inputA= 32'd675;	//Mass
	opcode= 4'b0100;
	#10

	temp = bb8.regB;
	$display("Mass of the object m: %1d kg", inputA);

	inputA= 32'd17; //Acceleration
	$display("Acceleration a: %1d m/s^2",inputA);
	opcode= 4'b1101; 
	#10

	$display("Force F = ma = %1d * %1d = %1d N",temp,inputA,bb8.regB); 
	$display("\n");
	
	$finish;
	end

endmodule
