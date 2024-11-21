`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2024 01:09:45 AM
// Design Name: 
// Module Name: text_mapper
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

// modify color_mapper.sv to draw font from font_rom instead of ball

module text_mapper(
    input logic [9:0] DrawX,            //! Pixel drawn X Coord
    input logic [9:0] DrawY,            //! Pixel drawn Y Coord
   // input logic [31:0] data_in,
    // need to get control register for colors
   // input logic [31:0] Ctrl_Params,      // ! FG and BG RGB Values from control register
    //now useless
    input logic [7:0] font_data,        // ! 8 bit font line data from font_rom
    output logic [10:0] font_addr,      //! 12 bit font rom address to read
    output logic [3:0] Red, Green, Blue,//! 4-bit color of current pixel
    input logic [31:0] Vram_Word,       //! VRAM 15-bit value with code and color indexes

    //output logic [11:0] Addr,            //! AXI Interface Address to read from
    output logic [11:0] addr,          //!

    output logic [2:0] colorAddr,       //! RAM Interface Address to get color register
    input logic [31:0] colorData        //! RAM Interace Address to get color for color palette
    );
    
    // internal  signals 
    // use ints for indexing?   (remember int vs integer)
    //logic [31:0] current_byte;//! byte in the word we're reading from
    
    // ROM interfacing
    logic [15:0] read_code;    //! 8-bit character code w/ invert bit
    //CHANGED THIS ^^ its now 16 bits long :)

    //logic [10:0] rom_addr;    //! 11 bit address into font_rom
    //assign font_addr = rom_addr;
    assign font_addr = {read_code[14:8], DrawY[3:0]}; // rom address into a code, add offset from Y for line within the char drawing
    
 
    
    // Pixel drawing
    // store color of current pixel
    logic inv_n;              //! Invert bit: 0 is inverted/bg color, 1 is non inverted/fg color

    
    logic [3:0] backgroundidx; //! Index of the current characters background color
    logic [3:0] foregroundidx; //! Index of current characters foreground color

    logic [9:0] math; //calculations to grab select bit
    logic select; //! Select whether to use first or second word from vram_word input

    logic colorAddrFinalBit;
   
    // location mapping 
    //CHANGE THIS - VRAM_WORD IS NOW 16 BTIS WIDE
    
   
    
    // font drawing logic
    // invert_n bit - set active when inv bit from word is not the same as the pixel we're drawing from font_rom
    



    always_comb begin: figure_out_select
        addr = DrawY[9:4] * 40 + DrawX[9:4]; //assign word address to read from
        math = DrawX[9:3] + (DrawY[9:4]*80); //this may be wrong!!
        select = math[0]; //


    end

    always_comb begin: set_params //assuming we have select bit, set invert bit, bgidx, and fgidx
        if(select)
        begin
            read_code =Vram_Word[31:16];
        end
        else
        begin
            read_code = Vram_Word[15:0];
        end
        inv_n = read_code[15] ^ font_data[7 - DrawX[2:0]]; //wrong!! should be font data
        backgroundidx = read_code[3:0];
        foregroundidx = read_code[7:4];
    end
    

    always_comb begin: send_color_signals

        if(inv_n) //assign the color address
        begin
            colorAddr = backgroundidx[3:1]; //ignore the last bit since that is the offset
            colorAddrFinalBit = backgroundidx[0];
        end
        else
        begin
            colorAddr = foregroundidx[3:1]; 
            colorAddrFinalBit = foregroundidx[0];
        end

        if(~colorAddrFinalBit) //assign the actual colors
        begin
//            Red  = 4'b1010;
//            Blue = 4'b1011;
//            Green = 4'b1111;
            Red = colorData[24:21];
            Green = colorData[20:17];
            Blue = colorData[16:13];
        end
        else
        begin
        
//            Red  = 4'b1010;
//            Blue = 4'b0111;
//            Green = 4'b1011;
            Red = colorData[12:9];
            Green = colorData[8:5];
            Blue = colorData[4:1];
        end
    end //gg vros!
endmodule