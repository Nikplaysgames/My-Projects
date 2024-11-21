module reg_file(
    input clk, //! clock
    input reset, //! reset
    input logic ld_reg, //! load new value into dr - control signal
    input logic [2:0] dr, //! destination register select
    input logic [2:0] sr2, //! select source register 2
    input logic [2:0] sr1_mux, //! select source register 1
    input logic [15:0] data_in, //! data input from bus

    output logic [15:0] sr1_out, //! sr1 output value
    output logic [15:0] sr2_out  //! sr2 output value 
);
    // create internal signals 
    logic [15:0] r0, r1, r2, r3, r4, r5, r6, r7; //! output wires from each register
    logic ld_r0, ld_r1, ld_r2, ld_r3, ld_r4, ld_r5, ld_r6, ld_r7; //! load signals for each register
    logic [15:0] data_in; //! data to send to drmux

    // instantiate registers
    load_reg #(.DATA_WIDTH(16)) reg_0( //! r0
        .clk(clk),
        .reset(reset),

        .load(ld_r0),
        .data_i(data_in),

        .data_q(r0)
    );

    load_reg #(.DATA_WIDTH(16)) reg_1( //! r1
        .clk(clk),
        .reset(reset),

        .load(ld_r1),
        .data_i(data_in),

        .data_q(r1)
    );

    load_reg #(.DATA_WIDTH(16)) reg_2( //! r2
        .clk(clk),
        .reset(reset),

        .load(ld_r2),
        .data_i(data_in),

        .data_q(r2)
    );

    load_reg #(.DATA_WIDTH(16)) reg_3( //! r3
        .clk(clk),
        .reset(reset),

        .load(ld_r3),
        .data_i(data_in),

        .data_q(r3)
    );

    load_reg #(.DATA_WIDTH(16)) reg_4( //! r4
        .clk(clk),
        .reset(reset),

        .load(ld_r4),
        .data_i(data_in),

        .data_q(r4)
    );

    load_reg #(.DATA_WIDTH(16)) reg_5( //! r5
        .clk(clk),
        .reset(reset),

        .load(ld_r5),
        .data_i(data_in),

        .data_q(r5)
    );

    load_reg #(.DATA_WIDTH(16)) reg_6( //! r6
        .clk(clk),
        .reset(reset),

        .load(ld_r6),
        .data_i(data_in),

        .data_q(r6)
    );

    load_reg #(.DATA_WIDTH(16)) reg_7( //! r7
        .clk(clk),
        .reset(reset),

        .load(ld_r7),
        .data_i(data_in),

        .data_q(r7)
    );

    // send load signal based on DRMUX output (mux is external) 
    always_comb
    begin : sel_dr //! send load signal destination register
    // avoid latch : set all to 0 first
    ld_r0 = 1'b0;
    ld_r1 = 1'b0;
    ld_r2 = 1'b0;
    ld_r3 = 1'b0;
    ld_r4 = 1'b0;
    ld_r5 = 1'b0;
    ld_r6 = 1'b0;
    ld_r7 = 1'b0;
    //if (ld_reg) begin //! load new values only when ld_reg is high
    unique case (dr)
        3'b000 : ld_r0 = ld_reg ? 1'b1 : 1'b0;
        3'b001 : ld_r1 = ld_reg ? 1'b1 : 1'b0;
        3'b010 : ld_r2 = ld_reg ? 1'b1 : 1'b0;
        3'b011 : ld_r3 = ld_reg ? 1'b1 : 1'b0;
        3'b100 : ld_r4 = ld_reg ? 1'b1 : 1'b0;
        3'b101 : ld_r5 = ld_reg ? 1'b1 : 1'b0;
        3'b110 : ld_r6 = ld_reg ? 1'b1 : 1'b0;
        3'b111 : ld_r7 = ld_reg ? 1'b1 : 1'b0;
        default : ; 
    endcase
    //end
    end

    // use 3 bit sr1 signal (from sr1mux output) to select sr1_out
    always_comb
    begin : sel_sr1_out //! assign sr1_out based on sr1 mux output
    unique case (sr1_mux)
        3'b000 : sr1_out = r0;
        3'b001 : sr1_out = r1;
        3'b010 : sr1_out = r2;
        3'b011 : sr1_out = r3;
        3'b100 : sr1_out = r4;
        3'b101 : sr1_out = r5;
        3'b110 : sr1_out = r6;
        3'b111 : sr1_out = r7;
        default : sr1_out = 16'b0; // should not be reached 
    endcase
    end

    // use 3 bit sr2 signal to select sr2_out
    always_comb
    begin : sel_sr2_out //! assign sr2_out based on sr2 signal 
    unique case (sr2)
        3'b000 : sr2_out = r0;
        3'b001 : sr2_out = r1;
        3'b010 : sr2_out = r2;
        3'b011 : sr2_out = r3;
        3'b100 : sr2_out = r4;
        3'b101 : sr2_out = r5;
        3'b110 : sr2_out= r6;
        3'b111 : sr2_out= r7;
        default : sr2_out = 16'b0; // should not be reached 
    endcase
    end



endmodule