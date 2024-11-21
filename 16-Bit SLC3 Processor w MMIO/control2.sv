`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 03:28:14 PM
// Design Name: 
// Module Name: control2
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


module control2(
    input logic			clk, //! clock 
	input logic			reset, //! reset

	input logic  [15:0]	ir, //! instruction register
	input logic			ben, //! branch enable

	input logic 		continue_i, //! continue after fetching instruction ?? 
	input logic 		run_i, 

	output logic		ld_mar, //! control output LD_MAR
	output logic		ld_mdr, //! control output LD_MDR 
	output logic		ld_ir, 	//! control output LD_IR 
	output logic		ld_pc, 	//! control output LD_PC
	output logic        ld_led,	//! control output LD_LED
						
	output logic		gate_pc, //! control output GatePC
	output logic		gate_mdr, //! control output GateMDR
						
	output logic [1:0]	pcmux, 	//! control output PCmux
	
	//You should add additional control signals according to the SLC-3 datapath design

	output logic		mem_mem_ena,//! memory operation enable
	output logic		mem_wr_ena,  //! memory wren 

	//adding new control signals

	output logic 		gate_alu, //! control output GateALU
	output logic        gate_marmux, //! control output gateMarMux

	output logic [1:0] ALUK, //! control output ALUK
	output logic sr1, //! control output SR1MUX //WARNING: CHANGE NAME TO SR1, CHANGE TO 1 BIT
	output logic sr2mux,  //! control output SR2MUX
	output logic addr1mux, //! control output addr1mux
	output logic [1:0] addr2mux, //! control output addr2mux
	output logic dr_sel, //! control output drmux //WARNING: change name to dr_sel, CHANE to 1 BIT
	output logic ld_reg, //! control output ld_reg
	output logic ld_cc //! control output ld_cc
);

// state enum encoding 
enum logic [4:0] {
    // halt
    halted,
    
    // fetch states
    s_18,  

	s_33_1,
	s_33_2,
	s_33_3,
	s_35,

    // decode 
	s_32,

    // execute states
    // instruction initial states
	s_1, // ADD

	s_5, // AND

	s_9, // NOT
	
	s_6, // LDR
	s_25_1, // next states
	s_25_2,
	s_25_3,
	s_27,

    s_7, // STR
	s_23, // next states
	s_16_1,
	s_16_2,
	s_16_3,

	s_4, // JSR
	s_21,

	s_12, //JMP

	s_0, // BR
	s_22,

    // PSE // pause states
    pause_ir1,
    pause_ir2

    } state, state_nxt;   // Internal state logic

    

	always_ff @ (posedge clk)
	begin : state_transition //! go to next state at posedge clk
		if (reset) 
			state <= halted;
		else 
			state <= state_nxt;
	end

    always_comb
    begin : next_state_assign //! assign next state based on current state
        state = state_nxt; // avoid latch
        unique case(state)
            halted : 
                    if (run_i)
                        state_nxt = s_18; // return to fetch on run button
			// fetch
            s_18    :   state_nxt = s_33_1;
            s_33_1  :   state_nxt = s_33_2;
            s_33_2  :   state_nxt = s_33_3;
            s_33_3  :   state_nxt = s_35;
            s_35    :   state_nxt = s_32;

			// decode
            s_32    :	
			begin
				unique case (ir[15:12])
					4'b0001 : state_nxt = s_1;  // add - state 1
					4'b0101 : state_nxt = s_5;  // and - state 5
					4'b1001 : state_nxt = s_9;  // not - state 9
					4'b0110 : state_nxt = s_6;  // ldr - state 6
					4'b0111 : state_nxt = s_7;  // str - state 7
					4'b0100 : state_nxt = s_4;  // jsr - state 4
					4'b1100 : state_nxt = s_12; // jmp - state 12
					4'b0000 : state_nxt = s_0;  // br - state 0
					4'b1101 : state_nxt = pause_ir1; // pse - state pause_ir1
				endcase
			end

			// execute

			// add
			s_0 	: 	state_nxt = s_18; // add complete, return to fetch
			
			// and
			s_5 	: 	state_nxt = s_18; // and complete, return to fetch

			// not
			s_9 	: 	state_nxt = s_18; // not complete, return to fetch

			// ldr
			s_6 	: 	state_nxt = s_25_1; // ldr incomplete- mem state 1
			s_25_1	:	state_nxt = s_25_2; // ldr incomplete- mem state 2
			s_25_2 	: 	state_nxt = s_25_3; // ldr incomplete- mem state 3
			s_25_3 	: 	state_nxt = s_27; 	// ldr incomplete- write to reg
			s_27 	: 	state_nxt = s_18;	// ldr complete, return to fetch

			// str
			s_7 	: 	state_nxt = s_23;	// str incomplete- update mdr
			s_23 	: 	state_nxt = s_16_1; // str incomplete- write to mem
			s_16_1 	:	state_nxt = s_16_2; // str incomplete- mem state 2
			s_16_2 	:	state_nxt = s_16_3; // str incomplete- mem state 3
			s_16_3 	:	state_nxt = s_18; 	// str complete, return to fetch
			
			// jsr
			s_4 	:	state_nxt = s_21; 	// jsr incomplete- update pc
			s_21	: 	state_nxt = s_18; 	// jsr complete, return to fetch

			// jmp
			s_12	: 	state_nxt = s_18;	// jmp complete, return to fetch
			
			// br
			s_0		: state_nxt = s_22; 	// br incomplete - update pc
			s_22	: state_nxt = s_18; 	// br complete, return to fetch

			// pse
			// using given code
			// pause_ir1 and pause_ir2 are only for week 1 such that TAs can see 
			// the values in ir.
			pause_ir1 : 
				if (continue_i) 
					state_nxt = pause_ir2;
			pause_ir2 : 
				if (~continue_i)
					state_nxt = s_18;
        endcase
    end

	always_comb
		begin : assign_control_outputs //! assign output signals
		// initialize all low to avoid latch
		
		// loads
		ld_ben = 1'b0;
		ld_cc = 1'b0;
		ld_ir = 1'b0;
		ld_led = 1'b0;
		ld_mar = 1'b0;
		ld_mdr = 1'b0;
		ld_pc = 1'b0;
		ld_reg = 1'b0;

		// gates
		gate_alu = 1'b0;
		gate_marmux = 1'b0;
		gate_mdr = 1'b0;
		gate_pc = 1'b0;

		// muxes
		ALUK = 2'b0;
		sr1 = 1'b0;
		sr2mux = 1'b0;
		addr1mux = 1'b0;
		addr2mux = 2'b0;
		dr_sel = 1'b0;

		// memory
		mem_mem_ena = 1'b0;
		mem_wr_ena = 1'b0;

		case(state) 
		
		// halt
		halted 	:;

		// fetch
		s_18 	:  //! MAR <- PC, PC <- PC + 1 
		begin
			gate_pc = 1'b1;
			ld_mar 	= 1'b1;
			pc_mux 	= 2'b01;
			ld_pc 	= 1'b1;
		end


		s_33_1, s_33_2, s_33_3 : //! MDR <- M[PC]
		begin
			mem_mem_ena = 1'b1;
			ld_mdr = 1'b1;
		end
			s_35 : 
		begin 
			gate_mdr = 1'b1;
			ld_ir = 1'b1;
		end









		endcase
	
	end 



endmodule