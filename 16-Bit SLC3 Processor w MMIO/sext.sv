module sext #(
    parameter INPUT_WIDTH = 1 //! 1 bit default input size
)(
    input logic [INPUT_WIDTH - 1 : 0] in,//! input value to sign extend
    output logic [15:0] out //! output sign extended value
);

  assign out = {{16-INPUT_WIDTH{in[INPUT_WIDTH-1]}}, in};

endmodule