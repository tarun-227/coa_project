module pc_logic(
    input clk,
    input rst,

    input prediction,
    input [31:0] branch_target,

    input mispredict,
    input [31:0] correct_pc,

    output reg [31:0] pc
);

always @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 0;
    else if (mispredict)
        pc <= correct_pc;
    else if (prediction)
        pc <= branch_target;
    else
        pc <= pc + 4;
end

endmodule