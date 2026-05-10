
module test;

    parameter WIDTH = 8;
    parameter CMD_WIDTH = 4;

    reg CLK;
    reg RST;

    wire MODE;
    wire CE;
    wire [1:0] INP_VALID;
    wire [CMD_WIDTH-1:0] CMD;
    wire [WIDTH-1:0] OPA;
    wire [WIDTH-1:0] OPB;
    wire CIN;

    wire [2*WIDTH-1:0] RES;
    wire OFLOW;
    wire COUT;
    wire G;
    wire L;
    wire E;
    wire ERR;

    wire [2*WIDTH-1:0] RES_exp;
    wire OFLOW_exp;
    wire COUT_exp;
    wire G_exp;
    wire L_exp;
    wire E_exp;
    wire ERR_exp;

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        RST = 1;
        #20;
        RST = 0;

        #3000;
        $finish;
    end

    Driver #(WIDTH, CMD_WIDTH) drv (
        .CLK(CLK),
        .MODE(MODE),
        .CE(CE),
        .INP_VALID(INP_VALID),
        .CMD(CMD),
        .OPA(OPA),
        .OPB(OPB),
        .CIN(CIN)
    );

    ALU2 #(WIDTH) dut (
        .CLK(CLK),
        .RST(RST),
        .MODE(MODE),
        .CE(CE),
        .INP_VALID(INP_VALID),
        .CMD(CMD),
        .OPA(OPA),
        .OPB(OPB),
        .CIN(CIN),
        .RES(RES),
        .OFLOW(OFLOW),
        .COUT(COUT),
        .G(G),
        .L(L),
        .E(E),
        .ERR(ERR)
    );

    ref_mod #(WIDTH, CMD_WIDTH) ref_inst (
        .CLK(CLK),
        .RST(RST),
        .MODE(MODE),
        .CE(CE),
        .INP_VALID(INP_VALID),
        .CMD(CMD),
        .OPA(OPA),
        .OPB(OPB),
        .CIN(CIN),
        .RES_exp(RES_exp),
        .OFLOW_exp(OFLOW_exp),
        .COUT_exp(COUT_exp),
        .G_exp(G_exp),
        .L_exp(L_exp),
        .E_exp(E_exp),
        .ERR_exp(ERR_exp)
    );

    mon_scr #(WIDTH, CMD_WIDTH) mon (
        .CLK(CLK),
        .RST(RST),
        .RES_exp(RES_exp),
        .OFLOW_exp(OFLOW_exp),
        .COUT_exp(COUT_exp),
        .G_exp(G_exp),
        .L_exp(L_exp),
        .E_exp(E_exp),
        .ERR_exp(ERR_exp),

        .RES(RES),
        .OFLOW(OFLOW),
        .COUT(COUT),
        .G(G),
        .L(L),
        .E(E),
        .ERR(ERR)
    );

endmodule
