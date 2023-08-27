# 64-Bit ALU Processor Project

This project involves the design and simulation of a simple 64-bit Arithmetic Logic Unit (ALU) processor using the Verilog hardware description language. The ALU processor is capable of performing a variety of basic mathematical and logical operations, including addition, subtraction, multiplication, division, modulus, and various logic functions. It also incorporates error detection for scenarios like divide-by-zero and overflow.

## Features

The 64-bit ALU processor offers the following key features:

1. **Mathematical Operations:**
   - Addition
   - Subtraction
   - Multiplication
   - Division
   - Modulus

2. **Logical Operations:**
   - AND
   - OR
   - NOT
   - NAND
   - NOR
   - XOR
   - XNOR

3. **Bitwise Shifting:**
   - Left shift
   - Right shift
   - Circular left shift
   - Circular right shift
   - Concatenation-based shifting

4. **Error Handling:**
   - Detects and reports divide-by-zero errors
   - Detects and reports overflow conditions

5. **Component Architecture:**
   - Utilizes a 16-channel 64-bit multiplexer (MUX) for efficient data selection
   - Incorporates a 16-channel 2-bit error multiplexer (Error MUX) for error handling
   - Memory registers constructed using D flip-flops, supporting up to 64-bit data storage

## Simulation

The project includes simulation using Verilog, which allows for testing and validation of the ALU processor's functionality. Simulations can be carried out to verify the correctness and robustness of the processor's operations, error detection mechanisms, and handling of various scenarios.

## Getting Started

Follow these steps to get started with the 64-bit ALU Processor project:

1. Clone or download the project repository to your local machine.

2. Install a Verilog simulation tool such as ModelSim or any other Verilog simulator of your choice.

3. Open the Verilog project files in your simulation tool.

4. Run simulations with test cases designed to cover different mathematical, logical, and error scenarios.

## Usage

1. Instantiate the 64-bit ALU Processor module in your Verilog testbench.

2. Provide appropriate inputs to the module, including operation codes and operands.

3. Monitor the output of the module to observe the results of the operations and error flags.

4. Modify or create additional test cases to thoroughly validate the processor's capabilities.

## Contributions

Contributions to the project are welcome! If you find ways to enhance the ALU processor's functionality, optimize its design, or improve its error handling, feel free to submit a pull request.

---

This ReadMe provides an overview of the 64-bit ALU Processor project, its features, usage instructions, and contribution guidelines. For detailed implementation details and code, please refer to the project's repository.
