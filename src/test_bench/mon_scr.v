module mon_scr #(parameter WIDTH = 8, parameter CMD_WIDTH = 4)
(
    input CLK,
    input RST,

    input [2*WIDTH-1:0] RES_exp,
    input OFLOW_exp,
    input COUT_exp,
    input G_exp,
    input L_exp,
    input E_exp,
    input ERR_exp,

    input [CMD_WIDTH-1:0] CMD,
    input MODE,
    input CE,
    input CIN,
    input [WIDTH-1:0] OPA,
    input [WIDTH-1:0] OPB,
    input [1:0] INP_VALID,

    input [2*WIDTH-1:0] RES,
    input OFLOW,
    input COUT,
    input G,
    input L,
    input E,
    input ERR
);

    wire [2*WIDTH+5:0] EXP;
    wire [2*WIDTH+5:0] ORG;

    assign EXP = {RES_exp, OFLOW_exp, COUT_exp, G_exp, L_exp, E_exp, ERR_exp};
    assign ORG = {RES, OFLOW, COUT, G, L, E, ERR};

    always @(posedge CLK) begin

        if(!RST) begin

            $display("\n================================================");

            $display("TIME = %0t", $time);

            $display("INPUTS :");
            $display("MODE=%0d CE=%0d CMD=%0d CIN=%0d VALID=%b",
                      MODE, CE, CMD, CIN, INP_VALID);

            $display("OPA=%0d OPB=%0d", OPA, OPB);

            $display("--------------------------------");

            $display("REFERENCE MODEL OUTPUTS :");
            $display("RES_EXP=%0d", RES_exp);
            $display("OFLOW_EXP=%0b", OFLOW_exp);
            $display("COUT_EXP=%0b", COUT_exp);
            $display("G_EXP=%0b", G_exp);
            $display("L_EXP=%0b", L_exp);
            $display("E_EXP=%0b", E_exp);
            $display("ERR_EXP=%0b", ERR_exp);

            $display("--------------------------------");

            $display("DUT OUTPUTS :");
            $display("RES=%0d", RES);
            $display("OFLOW=%0b", OFLOW);
            $display("COUT=%0b", COUT);
            $display("G=%0b", G);
            $display("L=%0b", L);
            $display("E=%0b", E);
            $display("ERR=%0b", ERR);

            $display("--------------------------------");

            if(EXP === ORG)
                $display("STATUS : PASS");
            else
                $display("STATUS : FAIL");

            $display("================================================");

        end

    end

endmodule
