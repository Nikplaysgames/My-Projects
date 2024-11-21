`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2024 11:07:00 PM
// Design Name: 
// Module Name: top_sim
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
module sim_week1();

logic clk, reset; //ena, wren;
//logic [15:0] data, readout;
//logic [9:0] address;
//test_memory test_memory_(clk, reset, data, address, ena, wren, readout);

logic continue_i, run_i;
logic [15:0] sw_i, led_o;
logic [3:0] hex_grid_left, hex_grid_right; 
logic [7:0] hex_seg_left, hex_seg_right;
processor_top processor_top_(
    clk, reset, run_i, continue_i, sw_i, led_o, 
    hex_seg_left, hex_grid_left,  hex_seg_right, hex_grid_right);

logic [15:0] rd_pc, rd_ir, rd_mdr, rd_mar;
logic [15:0] rd_r0,rd_r1,rd_r2,rd_r3,rd_r4, rd_r5,rd_r6,rd_r7;
logic [1:0] ALUK;
logic [2:0] sr2;
logic [2:0] sr1_mux;
logic [15:0] sr2_mux_out;
logic [2:0]dr;


assign rd_pc = processor_top_.slc3.cpu.pc;
assign rd_ir = processor_top_.slc3.cpu.ir;
assign rd_mdr = processor_top_.slc3.cpu.mem_wdata;
assign rd_mar = processor_top_.slc3.cpu.mem_addr;
assign rd_r0 = processor_top_.slc3.cpu.reg_file_.r0;
assign rd_r1 = processor_top_.slc3.cpu.reg_file_.r1;
assign rd_r2 = processor_top_.slc3.cpu.reg_file_.r2;
assign rd_r3 = processor_top_.slc3.cpu.reg_file_.r3;
assign rd_r4 = processor_top_.slc3.cpu.reg_file_.r4;
assign rd_r5 = processor_top_.slc3.cpu.reg_file_.r5;
assign rd_r6 = processor_top_.slc3.cpu.reg_file_.r6;
assign rd_r7 = processor_top_.slc3.cpu.reg_file_.r7;

assign ALUK = processor_top_.slc3.cpu.ALUK;
assign sr1_mux = processor_top_.slc3.cpu.sr1_mux;
assign dr =  processor_top_.slc3.cpu.dr;
assign sr2_mux_out = processor_top_.slc3.cpu.sr2_mux_out; 
assign sr2 = processor_top_.slc3.cpu.ir[2:0];

always
begin : clk_gen
    clk = 1'b0;
    #5;
    clk = 1'b1;
    #5;
end

initial begin



    // reset sequence
    #50;
    sw_i = 16'd0;
    run_i = 1'b0;
    continue_i = 1'b0;
    reset = 1'b0;
    #50;
    reset = 1'b1;
    #50;
    reset = 1'b0;



    // week 1 test
    // run processor, continue after each instruction load
    // #50;
    // run_i = 1'b1;
    // #100; // wait 10 clock cycles
    // run_i = 1'b0;


    // continue_i = 1'b1;
    // #20;
    // continue_i = 1'b0;
    // #100;
    // continue_i = 1'b1;
    // #20;
    // continue_i = 1'b0;
    // #100;
    // continue_i = 1'b1;
    // #20;
    // continue_i = 1'b0;
    // #100;
    // continue_i = 1'b1;
    // #20;
    // continue_i = 1'b0;
    // #100;
    // continue_i = 1'b1;
    // #20;
    // continue_i = 1'b0;
    // #100;
    // continue_i = 1'b1;
    // #20;
    // continue_i = 1'b0;
    // #100;


    // week 2 test: test program XOR
    // program start: PC = 0x0014
    // Instructions: AND, ANDi, NOT, LDR, BR, PSE
    
    // set pc
    sw_i = 16'd20;
    
    // run processor, continue after each instruction load
    #50;
    run_i = 1'b1;
    #100; // wait 10 clock cycles
    run_i = 1'b0;
    // checkpoint 1
    #210;
    sw_i = 16'h0005; // 0101
    #200;
    continue_i = 1'b1;
    #200;
    continue_i = 1'b0;
    #200;
    sw_i = 16'h000c ; //1100
    #200;
    continue_i = 1'b1;
    #200;
    continue_i = 1'b0;
    #200;
    // result should be x0009 // 1001 
    sw_i = 16'd9;
    #200;





end

endmodule