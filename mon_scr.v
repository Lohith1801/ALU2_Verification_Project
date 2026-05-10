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

            if(EXP === ORG) begin
                $display("PASS");
                $display("EXP = %b", EXP);
                $display("ORG = %b", ORG);
            end

            else begin
                $display("FAIL");
                $display("EXP = %b", EXP);
                $display("ORG = %b", ORG);
            end

        end

    end

endmodule
