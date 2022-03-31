
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE10_LITE(

    //////////// CLOCK //////////
    input                       ADC_CLK_10,
    input                       MAX10_CLK1_50,
    input                       MAX10_CLK2_50,

    //////////// SDRAM //////////
    output          [12:0]      DRAM_ADDR,
    output           [1:0]      DRAM_BA,
    output                      DRAM_CAS_N,
    output                      DRAM_CKE,
    output                      DRAM_CLK,
    output                      DRAM_CS_N,
    inout           [15:0]      DRAM_DQ,
    output                      DRAM_LDQM,
    output                      DRAM_RAS_N,
    output                      DRAM_UDQM,
    output                      DRAM_WE_N,

    //////////// SEG7 //////////
    output           [7:0]      HEX0,
    output           [7:0]      HEX1,
    output           [7:0]      HEX2,
    output           [7:0]      HEX3,
    output           [7:0]      HEX4,
    output           [7:0]      HEX5,

    //////////// KEY //////////
    input            [1:0]      KEY,

    //////////// LED //////////
    output           [9:0]      LEDR,

    //////////// SW //////////
    input            [9:0]      SW,

    //////////// VGA //////////
    output           [3:0]      VGA_B,
    output           [3:0]      VGA_G,
    output                      VGA_HS,
    output           [3:0]      VGA_R,
    output                      VGA_VS,

    //////////// Accelerometer //////////
    output                      GSENSOR_CS_N,
    input            [2:1]      GSENSOR_INT,
    output                      GSENSOR_SCLK,
    inout                       GSENSOR_SDI,
    inout                       GSENSOR_SDO,

    //////////// Arduino //////////
    inout           [15:0]      ARDUINO_IO,
    inout                       ARDUINO_RESET_N,

    //////////// GPIO, GPIO connect to GPIO Default //////////
    inout           [35:0]      GPIO
);

//=======================================================
//  REG/WIRE declarations
//=======================================================

    wire    [0 : 0]     clk;
    wire    [0 : 0]     reset; 
    wire    [7 : 0]     keys;
    wire    [0 : 0]     hsync;
    wire    [0 : 0]     vsync; 
    wire    [2 : 0]     rgb;

    assign reset  = ~ KEY[0];
    assign clk    = MAX10_CLK1_50;
    assign keys   = SW[0 +: 8];
    assign VGA_HS = hsync;
    assign VGA_VS = vsync;
    assign {VGA_R,VGA_G,VGA_B} = { { 4 { rgb[2] } } , { 4 { rgb[1] } } , { 4 { rgb[0] } } };
	 assign HEX0 = 8'b11111111;
	 assign HEX1 = 8'b11111111;
	 assign HEX2 = 8'b11111111;
	 assign HEX3 = 8'b11111111;
	 assign HEX4 = 8'b11111111;
	 assign HEX5 = 8'b11111111;
    
//=======================================================
//  Structural coding
//=======================================================

//`define FPGA_EXAMPLE wrapper_digits
//`define FPGA_EXAMPLE wrapper_ball_paddle
//`define FPGA_EXAMPLE wrapper_ball_absolute_top
//`define FPGA_EXAMPLE wrapper_ball_slipcounter_top
//`define FPGA_EXAMPLE wrapper_tiletest
//`define FPGA_EXAMPLE wrapper_paddle
//`define FPGA_EXAMPLE wrapper_spritetest
//`define FPGA_EXAMPLE wrapper_spriterender_test
//`define FPGA_EXAMPLE wrapper_racing_game
//`define FPGA_EXAMPLE wrapper_sprite_rotation
`define FPGA_EXAMPLE wrapper_tank_game


    `FPGA_EXAMPLE
    `FPGA_EXAMPLE
    (
        .clk    ( clk   ), 
        .reset  ( reset ), 
        .keys   ( keys  ),
        .hsync  ( hsync ), 
        .vsync  ( vsync ), 
        .rgb    ( rgb   )
    );


endmodule
