`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2024 01:36:10 PM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input logic [15:0] a, //! ALU input A from SR1_OUT
    input logic [15:0] b, //! ALU input B from SR2MUX
    input logic [1:0] ALUK, //! ALU operation select

    output logic [15:0] alu_out //! ALU output 
);
    always_comb 
    begin : assign_alu_out
        unique case (ALUK)
        2'b00 : alu_out = a + b;
        2'b01 : alu_out = a & b; 
        2'b10 : alu_out = ~a;
        2'b11 : alu_out = a;
        default : alu_out = 16'b0; // should never reach this
        endcase
    end
endmodule