
//--------------------------------------------------------------------------------------------------------
// Module  : tb_sha256
// Type    : simulation, top
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: testbench for sha256
//--------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module tb_sha256 ();

initial $dumpvars(1, tb_sha256);

reg rstn = 1'b0;
reg clk = 1'b1;
always #5000 clk = ~clk;   // 100MHz


wire         tready;
reg          tvalid = 1'b0;
reg          tlast  = 1'b0;
reg  [ 31:0] tid    = '0;
reg  [  7:0] tdata  = '0;


wire         ovalid;
wire [ 31:0] oid;
wire [ 60:0] olen;
wire [255:0] osha;


sha256 sha_i (
    .rstn   ( rstn   ),
    .clk    ( clk    ),
    .tvalid ( tvalid ),
    .tready ( tready ),
    .tlast  ( tlast  ),
    .tid    ( tid    ),
    .tdata  ( tdata  ),
    .ovalid ( ovalid ),
    .oid    ( oid    ),
    .olen   ( olen   ),
    .osha   ( osha   )
);


always @ (posedge clk)
    if(ovalid)
        $display("id=%x   len=%6d   sha256=%x", oid, olen, osha);


function automatic int check_fopen(input int fp);
    if(fp == 0) begin
        $error("could not open file.\n");
        $finish;
    end
    return fp;
endfunction


task automatic push_file(input int id, input int fp);
    int rbyte;
    {tvalid,tlast,tid,tdata} <= '0;
    @(posedge clk);
    while(~tready) @(posedge clk);
    tid <= id;
    tdata <= $fgetc(fp);
    rbyte = $fgetc(fp);
    tlast <= rbyte == -1;
    while( rbyte != -1 ) @(posedge clk) begin
        if(~tvalid | tready)
            tvalid <= ($random % 2) == 0;
        if( tvalid & tready) begin
            tdata <= rbyte;
            rbyte  = $fgetc(fp);
            tlast <= rbyte == -1;
        end
    end
    tvalid <= 1'b1;
    while(~tready) @(posedge clk);
    @(posedge clk);
    {tvalid,tlast,tid,tdata} <= '0;
    $fclose(fp);
endtask


initial begin
    repeat(4) @(posedge clk);
    rstn <= 1'b1;
    push_file('h111, check_fopen($fopen("./test_data/test1.bin", "rb")));
    push_file('h222, check_fopen($fopen("./test_data/test2.bin", "rb")));
    push_file('h333, check_fopen($fopen("./test_data/test3.bin", "rb")));
    push_file('h444, check_fopen($fopen("./test_data/test4.bin", "rb")));
    push_file('h555, check_fopen($fopen("./test_data/test5.bin", "rb")));
    push_file('h666, check_fopen($fopen("./test_data/test6.bin", "rb")));
    push_file('h777, check_fopen($fopen("./test_data/test7.bin", "rb")));
    repeat(2000) @(posedge clk);
    $finish;
end

endmodule

