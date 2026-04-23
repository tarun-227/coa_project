module gshare_predictor #(
    parameter BHT_SIZE = 8,
    parameter HISTORY_BITS = 3
)(
    input clk,
    input rst,

    input  [31:0] pc,
    output prediction,

    input update,
    input actual_taken,
    input [31:0] update_pc,

    output reg [HISTORY_BITS-1:0] GHR
);

reg [1:0] BHT [0:BHT_SIZE-1];
reg [HISTORY_BITS-1:0] GHR_snapshot;  

integer i;

// -------- Index --------
wire [HISTORY_BITS-1:0] index;
wire [HISTORY_BITS-1:0] update_index;

assign index = pc[HISTORY_BITS+1:2] ^ GHR;

assign update_index = update_pc[HISTORY_BITS+1:2] ^ GHR_snapshot;

// -------- Prediction --------
assign prediction = BHT[index][1];

// -------- Initialization --------
initial begin
    for (i = 0; i < BHT_SIZE; i = i + 1)
        BHT[i] = 2'b01; // weakly not taken
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        GHR <= 0;
        GHR_snapshot <= 0;
    end
end

// -------- Update --------
always @(posedge clk) begin
    if (update) begin

        GHR_snapshot <= GHR;

        // Update BHT
        case (BHT[update_index])
            2'b00: BHT[update_index] <= actual_taken ? 2'b01 : 2'b00;
            2'b01: BHT[update_index] <= actual_taken ? 2'b10 : 2'b00;
            2'b10: BHT[update_index] <= actual_taken ? 2'b11 : 2'b01;
            2'b11: BHT[update_index] <= actual_taken ? 2'b11 : 2'b10;
        endcase

        // Update GHR
        GHR <= {GHR[HISTORY_BITS-2:0], actual_taken};
    end
end

// -------- Debug Print --------
task print_bht;
    integer j;
    begin
        $display("Index | Counter | Meaning");
        $display("--------------------------------------");
        for (j = 0; j < BHT_SIZE; j = j + 1) begin
            case (BHT[j])
                2'b00: $display("%4b  |   %2b    | Strongly Not Taken", j, BHT[j]);
                2'b01: $display("%4b  |   %2b    | Weakly Not Taken", j, BHT[j]);
                2'b10: $display("%4b  |   %2b    | Weakly Taken", j, BHT[j]);
                2'b11: $display("%4b  |   %2b    | Strongly Taken", j, BHT[j]);
            endcase
        end
        $display("--------------------------------------\n");
    end
endtask

endmodule