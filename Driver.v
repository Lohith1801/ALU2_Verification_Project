module Driver #(parameter WIDTH = 8, parameter CMD_WIDTH = 4)(
    input CLK,
    output reg MODE,
    output reg CE,
    output reg [1:0] INP_VALID,
    output reg [CMD_WIDTH-1:0] CMD,
    output reg [WIDTH-1:0] OPA,
    output reg [WIDTH-1:0] OPB,
    output reg CIN
);

    integer i;

    task basic_arithmatic_operation;
    begin
        for(i=0;i<13;i=i+1) begin
            @(negedge CLK);
            CMD <= i;
            INP_VALID <= 2'b11;
            OPA <= $urandom_range(0,127);
            OPB <= $urandom_range(0,127);
            CIN <= $urandom_range(0,1);
            MODE <= 1'b1;
            CE <= 1'b1;
        end
    end
    endtask

    task basic_logical_operation;
    begin
        for(i=0;i<14;i=i+1) begin
            @(negedge CLK);
            CMD <= i;
            INP_VALID <= 2'b11;
            OPA <= $urandom_range(0,255);
            OPB <= $urandom_range(0,255);
            CIN <= 1'b0;
            MODE <= 1'b0;
            CE <= 1'b1;
        end
    end
    endtask

    initial begin
        MODE = 0;
        CE = 0;
        INP_VALID = 0;
        CMD = 0;
        OPA = 0;
        OPB = 0;
        CIN = 0;

        #30;

        basic_arithmatic_operation();
        basic_logical_operation();
    end

endmodule
