
module Driver #(parameter WIDTH = 8, parameter CMD_WIDTH = 4)(input CLK,  
    output reg MODE, CE,
    output reg [1:0] INP_VALID,
    output reg [CMD_WIDTH-1:0] CMD,
    output reg [WIDTH-1:0] OPA, OPB,
    output reg CIN
              
);
 integer i;             
 task basic_arithmatic_operation;
    begin
            for(i=0;i<16;i=i+1) begin
            @(posedge CLK) begin
                CMD <= i;           
                INP_VALID <= 2'b11;
                OPA <= $urandom_range(0,127);
                OPB <= $urandom_range(0,127);
                CIN <= $urandom_range(0,1);  
                MODE<= 1;
            end
            end
            end
                
    endtask
   task basic_logical_operation; 
        begin
            for(i=0;i<16;i=i+1) begin
            @(posedge CLK) begin
                CMD <= i;           
                INP_VALID <= 2'b11;
                OPA <= $urandom_range(0,127);
                OPB <= $urandom_range(0,127);
                CIN <= $urandom_range(0,1);  
                MODE<= 0;
            end
            end
            end
                
    endtask
    
    basic_arithmatic_operation();
    basic_logical_operation();
    
endmodule
