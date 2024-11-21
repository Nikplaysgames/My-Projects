//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Given Code - SLC-3 core
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 06-09-2020
//	  Revised 03-02-2021
//    Xilinx vivado
//    Revised 07-25-2023 
//    Revised 12-29-2023
//    Revised 09-25-2024
//------------------------------------------------------------------------------

module cpu (
    input   logic        clk, //! clock
    input   logic        reset, //! reset

    input   logic        run_i, //! run proccessor 
    input   logic        continue_i, //! continue to next fetch state 
    output  logic [15:0] hex_display_debug, //! Hex display output to read IR
    output  logic [15:0] led_o, //! LED output signals
   
    input   logic [15:0] mem_rdata,  //! data being read from memory
    output  logic [15:0] mem_wdata,  //! data written to memory
    output  logic [15:0] mem_addr,   //! memory address to +rw from
    output  logic        mem_mem_ena,//! enable memory operations (from control signal) 
    output  logic        mem_wr_ena  //! wren
);


// Internal connections, follow the datapath block diagram and add the additional needed signals
logic ld_mar;  //! control output LD_MAR
logic ld_mdr;  //! control output LD_MDR
logic ld_ir;   //! control output LD_IR
logic ld_pc;   //! control output LD_PC
logic ld_led;  //! control output LD_LED

logic gate_pc; //! control output GatePC 
logic gate_mdr; //! control output GateMDR
logic gate_alu; //! control output GateALU

logic gate_marmux; //! control output GateMARMUX

// adding new control signals
logic sr1;  //! control output mux select for sr1 mux 
logic [1:0] pcmux; //! control output PCmux
logic ld_reg; //! control output load register signal from control
logic dr_sel; //! control output drmux select bit from control 
logic [1:0] addr2mux; //! control output addr2mux
logic addr1mux; //! control output addr1mux
logic sr2mux; //! control output sr2mux for sr2MUX!!! not SR2, SR2 is INTERNAL

// branch
logic ld_cc; //! control output, set status bits from bus
logic ld_ben; //! control output, loads branch enable into decode state
logic ben;         //! branch enable - control input signal

// adding internal signals
// memory
logic [15:0] mar;  //! memory address register
logic [15:0] mdr;  //! memory data register
// fetch/decode 
logic [15:0] ir;   //! instruction register 
logic [15:0] pc;   //! program counter
// reg file
logic [2:0] sr1_mux; //! output of SR1 mux, depends on sr1 signal
//logic [2:0] sr2;  //! select bits for SR2, ir[2:0] - sr2 signal, not sr2mux!!  
logic [2:0] dr; //! output of DR mux, depends on dr_sel signal
// ALU select
logic [1:0] ALUK; //! control output to select ALU operation
// branch logic
logic ben_logic; 

// given assigns 
assign mem_addr = mar;
assign mem_wdata = mdr;
//assign led_o = ir;
assign hex_display_debug = ir; //! display instruction register on hex display bits
// new assigns 
//assign sr2 = ir[2:0];



/* 
    adding new internal signals
    added bus, PCmux
    added ALU instantiation and connections 
*/
// special registers
logic [15:0] bus; //! system bus
logic [15:0] pc_in; //! program counter input from PC_MUX
// ALU
logic [15:0] ALU_OUT; //! 16-bit ALU output 
logic [15:0] sr2_mux_out; 
// Register unit 
logic [15:0] sr1_out; //! sr1_out from register file 
logic [15:0] sr2_out; //! sr2_out from register file
// sign extensions 
logic [15:0] ir_sext_5; //! ir[4:0] sign extension into SR2MUX
logic [15:0] ir_sext_6; //! ir[5:0] sign extension into addr2mux
logic [15:0] ir_sext_9; //! ir[8:0] sign extension into addr2mux
logic [15:0] ir_sext_11; //! ir[10:0] sign extension into addr2mux
// misc
logic [15:0] addr_adder_in1; //! address adder input 1 from addr1mux output
logic [15:0] addr_adder_in2;  //! address adder input 2 from addr2mux output 
logic [15:0] addr_adder; //! address adder (add addr1 and addr2 muxes)

// branch logic
logic [2:0] nzp_val; //! current CC status
logic [2:0] nzp_status; //! 3 bit value to decode bus into NZP status (the LOGIC block going into NZP)



// State machine, you need to fill in the code here as well
// .* auto-infers module input/output connections which have the same name
// This can help visually condense modules with large instantiations, 
// but can also lead to confusing code if used too commonly
control cpu_control (
    .*
);



// Lab 5.1: SLC-3 Fetch Cycle
// Create bus, bus mux
// 10/1/24

// edited 10/7/24 to add gate_marmux
always_comb 
    begin: bus_mux //! assign data to bus based on control signals
    unique case ({gate_pc, gate_mdr, gate_alu, gate_marmux})
        4'b0001 : bus = addr_adder; 
        4'b0010 : bus = ALU_OUT;
        4'b0100 : bus = mdr;
        4'b1000 : bus = pc;
        //default : bus = 16'b0;
    endcase
end



// Create PC incrementor mux, connect MDR to datapath
// 10/2/24
always_comb
    begin: pc_mux //! program counter input mux 
    //! need to add 2 leftmost paths to PCMUX
    unique case ({pcmux})
        2'b00 : pc_in = pc + 1'b1;
        2'b01 : pc_in = bus;
        2'b10 : pc_in = addr_adder; //choose address adder output
        default : pc_in = bus;
    endcase
end



// Instantiate ALU module, connected GateALU to bus above
// 10/3/24
alu alu_(
    .a(sr1_out),
    .b(sr2_mux_out),
    .ALUK(ALUK),
    .alu_out(ALU_OUT)
);



// Instantiated register file, created DR mux, SR1 mux and SR2 signal
// 10/3/24

always_comb
    begin : dr_mux_out //! select dr register
        //dr = dr_sel ? ir[11:9] : 3'b111; 
        dr = dr_sel ?  3'b111 : ir[11:9] ; 
end 

always_comb
    begin : sr1_mux_out//! select sr1 register 
    sr1_mux = sr1 ? ir[8:6] : ir[11:9];   
end

reg_file reg_file_( //! instantiate register file module, create ext. connections
    .clk(clk),
    .reset(reset),
    .ld_reg(ld_reg),
    .dr(dr),
    .sr2(ir[2:0]), // was sr2
    .sr1_mux(sr1_mux),
    .data_in(bus),

    .sr1_out(sr1_out),
    .sr2_out(sr2_out)
);



// Creating sign extends for IR bit vects
// 10/3/24
sext #(.INPUT_WIDTH(5)) sext5 ( //! sign extend 6-bit ir[5:0]
    .in(ir[4:0]),
    .out(ir_sext_5)
);
sext #(.INPUT_WIDTH(6)) sext6 ( //! sign extend 6-bit ir[5:0]
    .in(ir[5:0]),
    .out(ir_sext_6)
);

sext #(.INPUT_WIDTH(9)) sext9 ( //! sign extend 6-bit ir[5:0]
    .in(ir[8:0]),
    .out(ir_sext_9)
);

sext #(.INPUT_WIDTH(11)) sext11 ( //! sign extend 6-bit ir[5:0]
    .in(ir[10:0]),
    .out(ir_sext_11)
);



// Creating addr1mux,addr2mux, address adder, their control/select signals
// 10/3/24
always_comb
    begin: addr1mux_sel //! create addr1 mux, send output to addr_adder_in1
    addr_adder_in1 = addr1mux ? sr1_out : pc;
end

always_comb
    begin : addr2mux_sel //! create addr2 mux, send output to addr_adder_in2
    unique case (addr2mux)
        2'b00 : addr_adder_in2 = 16'b0;
        2'b01 : addr_adder_in2 = ir_sext_6;
        2'b10 : addr_adder_in2 = ir_sext_9;
        2'b11 : addr_adder_in2 = ir_sext_11; 
    endcase
end

always_comb
    begin : assign_addr_adder //! add addr_adder_in1 and _in2 to send to PCmux
        addr_adder = addr_adder_in1 + addr_adder_in2;
end



// Adding SR2 mux 
// 10/3/24
assign sr2_mux_out = sr2mux ? ir_sext_5 : sr2_out; 



// Adding NZP Branch register logic
// 10/7/24
load_reg #(.DATA_WIDTH(3)) nzp_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_cc),
    .data_i(nzp_status),

    .data_q(nzp_val)
);

always_comb
    begin : set_status //! set status register depending on bus value
        nzp_status[2] = bus[15] ? 1'b1 : 1'b0; //! negative if MSB is high
        nzp_status[1] = (bus == 16'b0) ? 1'b1 : 1'b0; //! zero if entire value is 0
        nzp_status[0] = ((bus[15] == 1'b0) & (bus != 16'b0)) ? 1'b1 : 1'b0; //! positive if MSB is low and entire value is non zero
end



// Adding BEN set logic
// 10/7/24
// logic ben_logic declared above

always_comb
    begin : set_ben //! resolve branch enable based on NZP outputs
        ben_logic = | (ir[11:9] & nzp_val); 
end

load_reg #(.DATA_WIDTH(1)) ben_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_ben),
    .data_i(ben_logic),
    
    .data_q(ben)

);


// Adding PAUSE state LED Logic
always_comb
    begin : set_led
        led_o = ld_led ?  {4'b0 , ir[11:0]} : 16'b0;
end


// Lab 5.1 : added fetch cycle and memory management stuff
// 10/1/24 

load_reg #(.DATA_WIDTH(16)) ir_reg ( //! instruction register load reg
    .clk    (clk),
    .reset  (reset),

    .load   (ld_ir),
    .data_i (bus),

    .data_q (ir)
);

load_reg #(.DATA_WIDTH(16)) pc_reg ( //! program counter load reg
    .clk(clk),
    .reset(reset),

    .load(ld_pc),
    .data_i(pc_in),

    .data_q(pc)
);

load_reg #(.DATA_WIDTH(16)) mdr_reg ( //! MDR load reg
    .clk(clk),
    .reset(reset),
    
    .load(ld_mdr),
    .data_i(mem_mem_ena ? mem_rdata : bus),
    
    .data_q(mdr)
);

load_reg #(.DATA_WIDTH(16)) mar_reg ( //! MAR load reg 
    .clk(clk),
    .reset(reset),
    
    .load(ld_mar),
    .data_i(bus),
    
    .data_q(mar)
);


endmodule