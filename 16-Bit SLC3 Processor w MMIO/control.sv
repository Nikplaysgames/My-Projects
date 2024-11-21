//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Given Code - Incomplete ISDU for SLC-3
// Module Name:    Control - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//    Revised 07-25-2023
//    Xilinx Vivado
//	  Revised 12-29-2023
// 	  Spring 2024 Distribution
// 	  Revised 6-22-2024
//	  Summer 2024 Distribution
//	  Revised 9-27-2024
//	  Fall 2024 Distribution
//------------------------------------------------------------------------------
//WARNING: WE SHOULD NOT be assinging things to 0 in the state (since theyre already assigned to 0)
//comment those out
//ISSUES: redo LDR without gate_marmux. Figure out syntax errors
module control (
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

	output logic 		gate_alu, //!control output GateALU
	output logic        gate_marmux, //!control output gateMarMux

	output logic [1:0] ALUK, //!control output ALUK
	output logic sr1, //!control output SR1MUX //WARNING: CHANGE NAME TO SR1, CHANGE TO 1 BIT
	output logic sr2mux,  //!control output SR2MUX
	output logic addr1mux, //!control output addr1mux
	output logic [1:0] addr2mux, //!control output addr2mux
	output logic dr_sel, //!control output drmux //WARNING: change name to dr_sel, CHANE to 1 BIT
	//NOTE: drmux can be 1 bit here
	output logic ld_reg, //!control output ld_reg
	output logic ld_cc, //!control output ld_cc
	output logic ld_ben //!control output ld_ben .... Uncommented this 10/9

);

	// control signals to add: current list
	// 10/3, 13:53:00 
	/*
	output logic [1:0] ALUK,
	output logic gate_alu, 
	output logic [1:0] sr1mux,
	output logic sr2mux, // equivalent to ir[5]
	output logic addr1mux,
	output logic [1:0] addr2mux,
	output logic [1:0] drmux,
	
	output logic ld_reg,
	output logic ld_cc,
	output logic ld_ben,
	*/	
	enum logic [4:0] {
		halted, 
		pause_ir1,
		pause_ir2, 
		s_18, 
		s_33_1,
		s_33_2,
		s_33_3,
		s_35,

		//adding new states 10/7/24
		s_32,
		
		s_1,
		s_5,
		s_9,
		
		s_6,
		s_25_1,
		s_25_2,
		s_25_3,
		s_27,

		s_7,
		s_23,
		s_16_1,
		s_16_2,
		s_16_3,

		s_4,
		s_21,

		s_12,
		s_22,
		s_0

	} state, state_nxt;   // Internal state logic


	always_ff @ (posedge clk)
	begin
		if (reset) 
			state <= halted;
		else 
			state <= state_nxt;
	end
   
	always_comb
	begin 
		
		// Default controls signal values so we don't have to set each signal
		// in each state case below (If we don't set all signals in each state,
		// we can create an inferred latch)
		ld_mar = 1'b0;
		ld_mdr = 1'b0;
		ld_ir = 1'b0;
		ld_pc = 1'b0;
		ld_led = 1'b0;
		
		gate_pc = 1'b0;
		gate_mdr = 1'b0;
		gate_marmux = 1'b0;
		 
		pcmux = 2'b00;
		
		mem_mem_ena = 1'b0; //! added this to avoid inferred latch


		//10/7/24 - adding new states (Nikhil):
		//! set new control signals to 0 here so we don't needa manually set every one in each state

		mem_wr_ena = 1'b0; //unsure about if we need this, since it wasn't in original (but shouldve been)

		gate_alu = 1'b0;
		ALUK = 2'b0;

		sr1 = 1'b0; //this can be 1 bit i believe
		sr2mux = 1'b0;

		addr1mux = 1'b0;
		addr2mux = 2'b00;

		dr_sel = 1'b0;

		ld_reg = 1'b0;
		ld_cc = 1'b0;
		ld_ben = 1'b0; // uncommented

		
		// Assign relevant control signals based on current state
		case (state)
			halted: ;

			// Lab 5.1: SLC-3 Fetch Cycle
			// State 18 -> 33 -> 35 
			s_18 : 
				begin 
					gate_pc = 1'b1;
					ld_mar = 1'b1;
					//pcmux = 2'b00;
					ld_pc = 1'b1;
				end
			s_33_1, s_33_2, s_33_3 : //you may have to think about this as well to adapt to ram with wait-states
				begin
					mem_mem_ena = 1'b1;
					ld_mdr = 1'b1;
				end
			s_35 : 
				begin 
					gate_mdr = 1'b1;
					ld_ir = 1'b1;
				end
			pause_ir1: 
			begin
				ld_led = 1'b1; 	
			end
			pause_ir2: 
			begin
				ld_led = 1'b1; 
			end
			// you need to finish the rest of state output logic..... ok

			//(10/7/24): adding output state logic

			s_1: //!add state
				begin
					ld_reg = 1'b1;
					gate_alu = 1'b1;
					ld_cc = 1'b1;
					//	dr_sel = 1'b0;
					sr1 = 1'b1;
					sr2mux = ir[5] ? 1: 0;
				end

			s_5: //!and state
				begin
					ld_reg = 1'b1;
					ALUK = 2'b01;
					gate_alu = 1'b1;
					ld_cc = 1'b1;
					sr1 = 1'b1;
					sr2mux = ir[5] ? 1 : 0; 
				end

			s_9: //!DR = NOT SR1
				begin
					ld_reg = 1'b1;
					ALUK = 2'b10;
					gate_alu = 1'b1;
					//dr_sel = 1'b0;
					ld_cc = 1'b1;
					sr1 = 1'b1;
				end
			s_6: //!MAR <- BaseR + SEXT[off6]
				begin 
					sr1 = 1'b1;
					addr1mux = 1'b1;
					addr2mux = 2'b01;
					gate_marmux = 1'b1;
					ld_mar = 1'b1;
				end
				s_25_1, s_25_2, s_25_3 : //!MDR <- M[MAR]
				begin
					mem_mem_ena = 1'b1;
					ld_mdr = 1'b1;
					//mem_wr_ena = 1'b0;
				end
				s_27://!DR = MDR, set CC
				begin
					gate_mdr = 1'b1;
					ld_cc = 1'b1;
					//dr_sel = 1'b0;
					ld_reg = 1'b1;
				end

				s_7://!MAR <- BaseR + SEXT[off6]
				begin
					sr1 = 1'b1;
					addr1mux = 1'b1;
					addr2mux = 2'b01;
					gate_marmux = 1'b1;
					ld_mar = 1'b1;
				end

				s_23://!MDR <- SR
				begin
					//sr1 = 1'b0;
					ALUK = 2'b11;
					gate_alu = 1'b1;
					//mem_mem_ena = 1'b0;
					ld_mdr = 1'b1;
				end

				s_16_1, s_16_2, s_16_3://!M[MAR] <- MDR
				begin //WARNING: Not 100% sure abt this one
					mem_mem_ena = 1'b1;
					mem_wr_ena = 1'b1;
				end 
				
				s_4: //!R7 <- PC
				begin
					dr_sel = 1'b1;
					gate_pc = 1'b1;
					ld_reg = 1'b1;
				end

				s_21://!PC <- PC + SEXT[off11]
				begin
					addr2mux = 2'b11;
					//addr1mux = 1'b0;
					pcmux = 2'b10;
					ld_pc = 1'b1;
				end

				s_12: //!PC <-BaseR
				begin
					sr1 = 1'b1;
					addr1mux = 1'b1;
					//addr2mux = 2'b00;
					pcmux = 2'b10; //possible bug - abhi set the pc_mux select bits wrong (they are unintuitive)
					ld_pc = 1'b1;
				end

				s_0: //!BEN - do nothing here
				begin

				end
				s_22: //!PC <- PC + off9
				begin
					//addr1mux = 1'b0;
					addr2mux = 2'b10;
					pcmux = 2'b10;
					ld_pc = 1'b1;
				end
			// 10/9/24
				// adding changes to state 32 for ld.ben

				s_32:
					ld_ben = 1'b1;



			default : ;
		endcase
	end 


	// always_comb
	// begin
	// 	// default next state is staying at current state
	// 	state_nxt = state;

	// 	unique case (state)
	// 		halted : 
	// 			if (run_i) 
	// 				state_nxt = s_18;
	// 		s_18 : 
	// 			state_nxt = s_33_1; //notice that we usually have 'r' here, but you will need to add extra states instead 
	// 		s_33_1 :                 //e.g. s_33_2, etc. how many? as a hint, note that the bram is synchronous, in addition, 
	// 			state_nxt = s_33_2;   //it has an additional output register. 
	// 		s_33_2 :
	// 			state_nxt = s_33_3;
	// 		s_33_3 : 
	// 			state_nxt = s_35;
	// 		s_35 : 
	// 			state_nxt = s_32;
	// 		// pause_ir1 and pause_ir2 are only for week 1 such that TAs can see 
	// 		// the values in ir.
	// 		pause_ir1 : 
	// 			if (continue_i) 
	// 				state_nxt = pause_ir2;
	// 		pause_ir2 : 
	// 			if (~continue_i)
	// 				state_nxt = s_18;
	// 		// you need to finish the rest of state transition logic.....

	// 		// 10/7/24 adding more state logic
	// 		s_1:
	// 			state_nxt = s_18;
	// 		s_5:
	// 			state_nxt = s_18;
	// 		s_9:
	// 			state_nxt = s_18;
			
	// 		s_6:
	// 			state_nxt = s_25_1;
	// 		s_25_1:
	// 			state_nxt = s_25_2;
	// 		s_25_2:
	// 			state_nxt = s_25_3;
	// 		s_25_3:
	// 			state_nxt = s_27;
	// 		s_27 :
	// 			state_nxt = s_18;

	// 		s_7:
	// 			state_nxt = s_23;
	// 		s_23:
	// 			state_nxt = s_16_1;
	// 		s_16_1:
	// 			state_nxt = s_16_2;
	// 		s_16_2:
	// 			state_nxt = s_16_3;
	// 		s_16_3:
	// 			state_nxt = s_18;

	// 		s_4:
	// 			state_nxt = s_21;
	// 		s_21:
	// 			state_nxt = s_18;

	// 		s_12:
	// 			state_nxt = s_18;
	// 		s_22:
	// 			state_nxt = s_18;
			
	// 		s_0:
	// 		begin
	// 			// if(ben)
	// 			// 	state_nxt = s_22;
	// 			// else
	// 			// 	state_nxt = s_18;
	// 			state_nxt = ben ? s_22 : s_18;
	// 		end

	// 		s_32:
	// 		begin
				
	// 		//		state_nxt = s_18; //we f*cking HATE inferred latches
	// 			unique case (ir[15:12])
	// 				4'b0001: state_nxt = s_1;
	// 				4'b0101: state_nxt = s_5;
	// 				4'b0110: state_nxt = s_6;
	// 				4'b0111: state_nxt = s_7;
	// 				4'b0100: state_nxt = s_4;
	// 				4'b1100: state_nxt = s_12;
	// 				4'b0000: state_nxt = s_0;
	// 				4'b1001: state_nxt = s_9;
	// 				4'b1101: state_nxt = pause_ir1;
	// 				// default:
	// 				// 	state_nxt = s_18;
	// 			endcase




	// 		end
			
			
	// 		default :;
	// 	endcase
	// end



	always_comb
    begin : next_state_assign //! assign next state based on current state
        state_nxt = state; // avoid latch
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
			s_1 	: 	state_nxt = s_18; // add complete, return to fetch
			
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
			s_0		: state_nxt = ben ? s_22 : s_18; 	// br incomplete - update pc
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
	
endmodule