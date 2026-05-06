module test;
 

    parameter WIDTH = 8;
 

    reg CLK;
    reg RST;
    reg MODE;
    reg CIN;
    reg CE;
    reg [WIDTH-1:0] OPA;
    reg [WIDTH-1:0] OPB;
    reg [1:0] INP_VALID;
    reg [3:0] CMD;
 

    wire [2*WIDTH-1:0] RES;
    wire ERR, G, L, E, COUT, OFLOW;
 
 
    ALU2 #(WIDTH) uut (
        .CLK(CLK), 
        .RST(RST), 
        .MODE(MODE), 
        .CIN(CIN), 
        .CE(CE),
        .OPA(OPA), 
        .OPB(OPB), 
        .INP_VALID(INP_VALID), 
        .CMD(CMD),
        .RES(RES), 
        .ERR(ERR), 
        .G(G), 
        .L(L), 
        .E(E), 
        .COUT(COUT), 
        .OFLOW(OFLOW)
    );
 
    initial begin
      CLK = 0;
    forever #5 CLK = ~CLK;
    end
  
  initial begin
    RST = 1;
    
    #10 RST = 0;
    OPA = 8'd200;
    OPB = 8'd20;
    INP_VALID = 2'b11;
    MODE = 1;
    CMD = 4'd0;
    CIN = 0;
    CE = 1;
    
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd1;
    
    @(posedge CLK);
    OPA = 8'd10;
    OPB = 8'd5;
    CMD = 4'd2;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd2;
    CMD = 4'd3;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd4;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd5;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd6;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd7;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd8;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd9;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd10;
    
    @(posedge CLK);
    OPA = 8'd20;
    OPB = 8'd20;
    CMD = 4'd11;
    
    #200 $finish;
    
  end
  

  initial 
    $monitor("T=%0t | MODE=%0d CMD=%0d | A=%0d B=%0d CIN=%0d VALID=%b | RES=%0d COUT=%0d OF=%0d G=%0d L=%0d E=%0d ERR=%0d",$time, MODE, CMD, OPA, OPB, CIN, INP_VALID,RES, COUT, OFLOW, G, L, E, ERR);
  
endmodule
