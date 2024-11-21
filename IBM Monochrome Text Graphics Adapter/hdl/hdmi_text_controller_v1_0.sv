//Provided HDMI_Text_controller_v1_0 for HDMI AXI4 IP 
//Fall 2024 Distribution

//Modified 3/10/24 by Zuofu
//Updated 11/18/24 by Zuofu


`timescale 1 ns / 1 ps

module hdmi_text_controller_v1_0 #
(
    // Parameters of Axi Slave Bus Interface S00_AXI
    // Modify parameters as necessary for access of full VRAM range

    parameter integer C_AXI_DATA_WIDTH	= 32, //! AXI4-Lite Data width (32 bit MicroBlaze syste,)
    parameter integer C_AXI_ADDR_WIDTH	= 16 //! 11/6 - changed from 4 (provided) to 12 (week 1) to 16 (week 2)
)
(
    // Users to add ports here

    output logic hdmi_clk_n, //! negative end of HDMI TDMS clock
    output logic hdmi_clk_p, //! positive end of HDMI TDMS clock
    output logic [2:0] hdmi_tx_n, //! negative end of HDMI TDMS data
    output logic [2:0] hdmi_tx_p, //! positive end of HDMI TDMS data  

    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface AXI
    input logic  axi_aclk, //! AXI clock
    input logic  axi_aresetn, ///! AXI reset, active low
    input logic [C_AXI_ADDR_WIDTH-1 : 0] axi_awaddr, //! AXI Write Address
    input logic [2 : 0] axi_awprot, //! unused 
    input logic  axi_awvalid, //! AXI Write Address valid 
    output logic  axi_awready, //! AXI Write Address ready
    input logic [C_AXI_DATA_WIDTH-1 : 0] axi_wdata, //! AXI Write Data
    input logic [(C_AXI_DATA_WIDTH/8)-1 : 0] axi_wstrb, //! AXI Write Data Strobe (Byte select)
    input logic  axi_wvalid, //! AXI Write Valid 
    output logic  axi_wready, //! AXI Write Ready
    output logic [1 : 0] axi_bresp, //! AXI Write Response 
    output logic  axi_bvalid, //! AXI Write Response valid 
    input logic  axi_bready, //! AXI Write Response ready
    input logic [C_AXI_ADDR_WIDTH-1 : 0] axi_araddr, //! AXI Read Address 
    input logic [2 : 0] axi_arprot, //! unused 
    input logic  axi_arvalid, //! AXI Read Address Valid 
    output logic  axi_arready, //! AXI Read Address Ready
    output logic [C_AXI_DATA_WIDTH-1 : 0] axi_rdata, //! AXI Read Data
    output logic [1 : 0] axi_rresp, //! AXI Read response 
    output logic  axi_rvalid, //! AXI Read valid 
    input logic  axi_rready //! AXI Read ready
);

//additional logic variables as necessary to support VGA, and HDMI modules.

// global clock is axi_aclk
// global rst is axi_aresetn
// block design reset is reset_ah from clkwiz 
logic reset_ah; //! reset



// for clocking wizard
// 10/30 : removed clk_100MHz
logic clk_25MHz, clk_125MHz;
logic locked; //! locked pin from clocking wizard

//! for VGA_controller and text_mapper
logic hsync, vsync, vde;
logic [3:0] red, green, blue;

logic [9:0] drawX, drawY; //! current pixel drawing coordinates
logic [31:0] ctrl_params; //! port control RGB parameters from AXI slave reg to text mapper (week 1)

// for font_rom
logic [10:0] rom_addr; //! address of line to read from font_rom
logic [7:0] current_word; //! current line of the pixel being read from font_rom

// added 10/29
logic [31:0] vram_word;    //! from AXI interface --> text_mapper
logic [11:0] addr;         //! from AXI interface --> text_mapper

// added 10/6
logic [2:0] colorAddr;      //! from AXI interface slave regs --> text_mapper
logic [31:0] colorData;     //! from AXI interface slave regs --> text_mapper

// Instantiation of Axi Bus Interface AXI
hdmi_text_controller_v1_0_AXI # ( 
    .C_S_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH)
) hdmi_text_controller_v1_0_AXI_inst (
    .S_AXI_ACLK(axi_aclk),
    .S_AXI_ARESETN(axi_aresetn),
    .S_AXI_AWADDR(axi_awaddr),
    .S_AXI_AWPROT(axi_awprot),
    .S_AXI_AWVALID(axi_awvalid),
    .S_AXI_AWREADY(axi_awready),
    .S_AXI_WDATA(axi_wdata),
    .S_AXI_WSTRB(axi_wstrb),
    .S_AXI_WVALID(axi_wvalid),
    .S_AXI_WREADY(axi_wready),
    .S_AXI_BRESP(axi_bresp),
    .S_AXI_BVALID(axi_bvalid),
    .S_AXI_BREADY(axi_bready),
    .S_AXI_ARADDR(axi_araddr),
    .S_AXI_ARPROT(axi_arprot),
    .S_AXI_ARVALID(axi_arvalid),
    .S_AXI_ARREADY(axi_arready),
    .S_AXI_RDATA(axi_rdata),
    .S_AXI_RRESP(axi_rresp),
    .S_AXI_RVALID(axi_rvalid),
    .S_AXI_RREADY(axi_rready),
    // adding new vram_word and addr signals from AXI interface
    .vram_word(vram_word),
    .addr(addr),
    .colorAddr(colorAddr),
    .colorData(colorData)
);


//Instiante clocking wizard, VGA sync generator modules, and VGA-HDMI IP here. For a hint, refer to the provided
//top-level from the previous lab. You should get the IP to generate a valid HDMI signal (e.g. blue screen or gradient)
//prior to working on the text drawing.

// clocking wizard IP
    clk_wiz_0 clk_wiz (
        .clk_out1(clk_25MHz),
        .clk_out2(clk_125MHz),
        .reset(reset_ah),
        .locked(locked),
        .clk_in1(axi_aclk)
    );

//VGA Sync signal generator
    vga_controller vga (
        .pixel_clk(clk_25MHz),
        .reset(reset_ah),
        .hs(hsync),
        .vs(vsync),
        .active_nblank(vde),
        .drawX(drawX),
        .drawY(drawY)
    );

//Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(clk_25MHz),
        .pix_clkx5(clk_125MHz),
        .pix_clk_locked(locked),
        //Reset is active LOW
        .rst(reset_ah),
        //Color and Sync Signals
        .red(red),
        .green(green),
        .blue(blue),
        .hsync(hsync),
        .vsync(vsync),
        .vde(vde),
        
        //aux Data (unused)
        .aux0_din(4'b0),
        .aux1_din(4'b0),
        .aux2_din(4'b0),
        .ade(1'b0),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_clk_p),          
        .TMDS_CLK_N(hdmi_clk_n),          
        .TMDS_DATA_P(hdmi_tx_p),         
        .TMDS_DATA_N(hdmi_tx_n)          
    );
    
    // Make sure that you generate an inverted reset signal as well, as the reset expected in a Block
    // Design is active low. As you may have already noticed, pushbuttons are active high on the
    // Urbana board, but MicroBlaze (and any AXI4 IPs) expect resets to be active low.
        // have to make new output pin? or assign to existing 
        // probably reset_ah
        // can just flip AXI rst pin (?)
     
    assign reset_ah = ~axi_aresetn; 
    
   
    
    // font_rom instantiation
    font_rom font_rom_(
        .addr(rom_addr),            // address/index to read ROM
        .data(current_word)         // data word read from ROM NOT AXI!!!!!
    );
    
    // text_mapper instantiation
    text_mapper drawText (
        .DrawX(drawX),
        .DrawY(drawY),
        .Red(red),
        .Green(green),
        .Blue(blue),
        .Vram_Word(vram_word),
        .addr(addr),
        .font_data(current_word),
        .font_addr(rom_addr),
        .colorAddr(colorAddr),
        .colorData(colorData)
    );

// User logic ends

endmodule