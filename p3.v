module branch_control(
    input predicted,
    input actual_taken,

    output mispredict,
    output flush
);

assign mispredict = (predicted != actual_taken);
assign flush      = mispredict;

endmodule