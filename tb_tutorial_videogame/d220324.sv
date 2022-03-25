
module tb_ball_absolute_top();

endmodule

`define log_en 1

module tb_220325_tile_test();

    timeprecision       1ns;
    timeunit            1ns;

    parameter           T = 10,
                        rst_delay = 7;

                        
    logic   [0 : 0]     clk;
    logic   [0 : 0]     reset; 
    logic   [0 : 0]     hsync;
    logic   [0 : 0]     vsync; 
    logic   [2 : 0]     rgb;
    logic   [3 : 0]     keys;

    wrapper_tiletest
    wrapper_tiletest_0
    (
        .clk        ( clk       ), 
        .reset      ( reset     ), 
        .keys       ( keys      ),
        .hsync      ( hsync     ), 
        .vsync      ( vsync     ), 
        .rgb        ( rgb       )
    );

    initial 
    begin
        clk = '0;
        forever
            #(T/2) clk = ~clk;
    end
    initial
    begin
        reset = '1;
        repeat(rst_delay) @(posedge clk);
        reset = '0;
    end

//    initial
       // $readmemh("../fpga-examples/cp437.hex", wrapper_tiletest_0.test_tilerender_top_0.tile_rom.bitarray);

    
    `ifdef log_en

    integer file;
    integer frame_c;
    parameter repeat_cycles = 200;

    string color = "";

    initial
    begin
        frame_c = 0;
        file = $fopen("../log_output.txt", "w");
        fork 
            forever
            begin
                if((hsync == '1) && (vsync == '1))
                begin
                    color = (rgb == 0) && ( color == "" ) ? " " : color;
                    color = (rgb == 1) && ( color == "" ) ? "1" : color;
                    color = (rgb == 2) && ( color == "" ) ? "2" : color;
                    color = (rgb == 3) && ( color == "" ) ? "3" : color;
                    color = (rgb == 4) && ( color == "" ) ? "4" : color;
                    color = (rgb == 5) && ( color == "" ) ? "5" : color;
                    color = (rgb == 6) && ( color == "" ) ? "6" : color;
                    color = (rgb == 7) && ( color == "" ) ? "7" : color;

                    $fwrite(file, "%s", color);
                    color = "";
                end
                else if((hsync == '1) && (vsync=='0))
                begin
                    $fwrite(file, "-");
                end
                    @(negedge clk);
                    @(negedge clk);
            end
            forever
            begin
                @(negedge hsync);
                $fwrite(file, "|\n");
            end
            forever
            begin
                @(negedge vsync);
                frame_c++;
                $fwrite(file, "number of frame = %d", frame_c);
                $display("number of frame = %d %tns", frame_c, $time);
                if ( frame_c == repeat_cycles + 1)
                    $stop;
            end
        join
    end

    `endif

endmodule

module d220324_dat_main();
    tb_220325_tile_test tiletest();
    initial begin
        $display("d220324_dat_main module s");
    end
endmodule