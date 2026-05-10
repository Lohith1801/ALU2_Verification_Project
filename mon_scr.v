
module mon_scr#(parameter WIDTH = 8,parameter CMD_WIDTH = 4)
(   input CLK,RST,
    input [2*WIDTH-1:0] RES_exp,
    input OFLOW_exp, COUT_exp, G_exp, L_exp, E_exp, ERR_exp,
    input [2*WIDTH-1:0] RES,
    input OFLOW, COUT, G, L, E, ERR
);
    wire [2*WIDTH+6 -1 :0]EXP,ORG;
    assign EXP = {RES_exp, OFLOW_exp, COUT_exp, G_exp, L_exp, E_exp, ERR_exp};
    assign ORG = {RES,OFLOW, COUT, G, L, E, ERR};
    always@(posedge CLK or posedge RST) begin
        if(EXP === ORG) begin
            $display("PASS -  RES_exp = %b OFLOW_exp = %b , COUT_exp =%b , G_exp = %b, L_exp =%b , E_exp=%b, ERR_exp=%b",RES_exp, OFLOW_exp, COUT_exp, G_exp, L_exp, E_exp, ERR_exp);
            $display("RES = %b OFLOW = %b , COUT = %b , G = %b, L = %b , E = %b, ERR = %b",
         RES, OFLOW, COUT, G, L, E, ERR);
         
         end
         else begin
            $display("FAIL -  RES_exp = %b OFLOW_exp = %b , COUT_exp =%b , G_exp = %b, L_exp =%b , E_exp=%b, ERR_exp=%b",RES_exp, OFLOW_exp, COUT_exp, G_exp, L_exp, E_exp, ERR_exp);
            $display("RES = %b OFLOW = %b , COUT = %b , G = %b, L = %b , E = %b, ERR = %b",
         RES, OFLOW, COUT, G, L, E, ERR);
         
         end
         end
    
    
    
endmodule
