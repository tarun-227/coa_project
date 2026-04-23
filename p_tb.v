module tb_pipeline;

reg clk, rst;

pipeline_top uut (
    .clk(clk),
    .rst(rst)
);

always #5 clk = ~clk;

integer cycle = 0;

initial begin
    clk = 0;
    rst = 1;
    #10 rst = 0;

    $display("Cycle | PC       | Pred | Act | Misp | GHR");
    $display("------------------------------------------------");

    repeat (8) begin
        @(posedge clk);
        cycle = cycle + 1;

        #1;
        $display("%5d | %h |  %b   |  %b  |  %b   | %b",
            cycle,
            uut.pc,
            uut.prediction,
            uut.actual_taken,
            uut.mispredict,
            uut.GHR
        );

        // Print BHT
        uut.bp.print_bht();
    end

    #20 $finish;
end

endmodule