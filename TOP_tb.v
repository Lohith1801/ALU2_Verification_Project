`define WIDTH 8
`define CMD_WIDTH 4

module test;

    reg CLK, RST;

    wire MODE, CE, CIN;
    wire [1:0] INP_VALID;
    wire [`CMD_WIDTH-1:0] CMD;
    wire [`WIDTH-1:0] OPA, OPB;

    wire [2*`WIDTH-1:0] RES_exp, RES;
    wire OFLOW_exp, COUT_exp, G_exp, L_exp, E_exp, ERR_exp;
    wire OFLOW, COUT, G, L, E, ERR;

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        RST = 1;
        #20 RST = 0;
    end

    Driver #(.WIDTH(`WIDTH), .CMD_WIDTH(`CMD_WIDTH)) drv (.CLK(CLK), .MODE(MODE), .CE(CE), .INP_VALID(INP_VALID), .CMD(CMD), .OPA(OPA), .OPB(OPB), .CIN(CIN));

    ref_mod #(.WIDTH(`WIDTH), .CMD_WIDTH(`CMD_WIDTH)) ref_inst (.CLK(CLK), .RST(RST), .MODE(MODE), .CE(CE), .INP_VALID(INP_VALID), .CMD(CMD), .OPA(OPA), .OPB(OPB), .CIN(CIN), .RES_exp(RES_exp), .OFLOW_exp(OFLOW_exp), .COUT_exp(COUT_exp), .G_exp(G_exp), .L_exp(L_exp), .E_exp(E_exp), .ERR_exp(ERR_exp));

    alu_param #(.width(`WIDTH), .c(`CMD_WIDTH)) dut (.clk(CLK), .rst(RST), .inp_valid(INP_VALID), .mode(MODE), .cmd(CMD), .ce(CE), .opa(OPA), .opb(OPB), .cin(CIN), .err(ERR), .res(RES), .oflow(OFLOW), .cout(COUT), .g(G), .l(L), .e(E));

    mon_scr #(.WIDTH(`WIDTH), .CMD_WIDTH(`CMD_WIDTH)) mon (.CLK(CLK), .RST(RST), .RES_exp(RES_exp), .OFLOW_exp(OFLOW_exp), .COUT_exp(COUT_exp), .G_exp(G_exp), .L_exp(L_exp), .E_exp(E_exp), .ERR_exp(ERR_exp), .RES(RES), .OFLOW(OFLOW), .COUT(COUT), .G(G), .L(L), .E(E), .ERR(ERR));

endmodule
