module pipeline_top(
    input clk,
    input rst
);

// Signals
wire [31:0] pc;
wire prediction;
wire actual_taken;
wire update;
wire mispredict;
wire flush;
wire [2:0] GHR;

wire [31:0] branch_target;
wire [31:0] correct_pc;

// -------- Branch behavior (synthetic) --------
// Pattern depends on PC → for testing only
assign actual_taken  = pc[2];
assign update        = 1'b1;   // always update (demo purpose)

// -------- Target logic --------
assign branch_target = pc + 16;
assign correct_pc    = actual_taken ? branch_target : (pc + 4);

// -------- Predictor --------
gshare_predictor bp (
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .prediction(prediction),
    .update(update),
    .actual_taken(actual_taken),
    .update_pc(pc),
    .GHR(GHR)
);

// -------- Control --------
branch_control ctrl (
    .predicted(prediction),
    .actual_taken(actual_taken),
    .mispredict(mispredict),
    .flush(flush)
);

// -------- PC --------
pc_logic pc_unit (
    .clk(clk),
    .rst(rst),
    .prediction(prediction),
    .branch_target(branch_target),
    .mispredict(mispredict),
    .correct_pc(correct_pc),
    .pc(pc)
);

endmodule