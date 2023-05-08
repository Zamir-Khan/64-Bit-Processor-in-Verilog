A simple 64-bit ALU processor using Verilog simulation.

The processor has the ability to do the basic math functions: Addition, Subtraction, Multiplication, Division, and Modulus. 
It also has the ability to do logic functions (using Modules): AND, OR, NOT, NAND, NOR, XOR, XNOR. 
In addition to that, it has the ability to shift a binary number left or right, either as a circular form or by doing concatenation. 
Also, it can report basic errors such as divide-by-zero or overflow.

The main parts of the processor utilizes a 16-channel 64-bit Multiplexer(MUX) as well as another 16-channel 2-bit Error MUX.
D Flip-Flops are used to construct the memory register which can handle up-to 64-bit.
