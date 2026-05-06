module ALU2 #(parameter WIDTH = 8)(
    //input ports
    input CLK, RST, MODE, CE,
    input [1:0] INP_VALID,
    input [3:0] CMD,
    input [WIDTH-1:0] OPA, OPB,
    input CIN,
    
    //output ports
    output reg [2*WIDTH-1:0] RES,
    output reg OFLOW, COUT, G, L, E, ERR
);
    //intermediate or temporary memories
    reg [1:0] count;
    reg [WIDTH-1:0] temp_a, temp_b;
    reg signed [WIDTH-1:0] signed_a, signed_b;
    
    //signed addition wiring
    wire [WIDTH:0] sum_ext;
    assign sum_ext = $signed(OPA) + $signed(OPB);

    //counter logic for Arithmatic CMD =9 and CMD=10
    always @(posedge CLK or posedge RST) begin
        if (RST)
            count <= 0;
        else if (MODE && (CMD == 4'd9 || CMD == 4'd10))
            count <= count + 1;
        else
            count <= 0;
    end

    //ALU logic
    always @(posedge CLK or posedge RST) begin
        if (RST) begin //RST logic
            RES   <= 0;
            OFLOW <= 0;
            COUT  <= 0;
            G <= 0; 
            L <= 0; 
            E <= 0;
            ERR <= 0;
        end
        else if (CE) begin //Clock enable logic
            
            // initializing default values
            RES   <= 0;
            OFLOW <= 0;
            COUT  <= 0;
            G <= 0; 
            L <= 0; 
            E <= 0;
            ERR <= 0;

            if (MODE) begin //ARITMATIC OPERATIONS
                case (CMD)

                    4'd0: begin//Addition
                        if (INP_VALID == 2'b11)
                            {COUT, RES[WIDTH-1:0]} <= OPA + OPB;
                        else 
                            ERR <= 1;
                    end

                    4'd1: begin//subtraction
                        if (INP_VALID == 2'b11)
                            RES[WIDTH-1:0] <= OPA - OPB;
                        else 
                            ERR <= 1;
                    end

                    4'd2: begin//Addition with CIN
                        if (INP_VALID == 2'b11)
                            {COUT, RES[WIDTH-1:0]} <= OPA + OPB + CIN;
                        else 
                            ERR <= 1;
                    end

                    4'd3: begin//Subtraction with CIN
                        if (INP_VALID == 2'b11)
                            RES[WIDTH-1:0] <= OPA - OPB - CIN;
                        else 
                            ERR <= 1;
                    end

                    4'd4: begin//increment A
                        if (INP_VALID[0])
                            RES[WIDTH-1:0] <= OPA + 1;
                        else 
                            ERR <= 1;
                    end

                    4'd5: begin//decrement A
                        if (INP_VALID[0])
                            RES[WIDTH-1:0] <= OPA - 1;
                        else 
                            ERR <= 1;
                    end

                    4'd6: begin// Increment B
                        if (INP_VALID[1])
                            RES[WIDTH-1:0] <= OPB + 1;
                        else 
                            ERR <= 1;
                    end

                    4'd7: begin//Decrement B
                        if (INP_VALID[1])
                            RES[WIDTH-1:0] <= OPB - 1;
                        else 
                            ERR <= 1;
                    end

                    4'd8: begin//CMP
                        if (INP_VALID == 2'b11) begin
                            G <= (OPA > OPB);
                            E <= (OPA == OPB);
                            L <= (OPA < OPB);
                        end 
                            else ERR <= 1;
                    end

                    4'd9: begin// Incremented Multiplication
                        if (INP_VALID == 2'b11) begin
                            if (count == 2'd1) begin
                                temp_a <= OPA + 1;
                                temp_b <= OPB + 1;
                            end
                            else if (count == 2'd2)
                                RES <= temp_a * temp_b;
                        end 
                            else ERR <= 1;
                    end

                    4'd10: begin//Shifted multiplication
                        if (INP_VALID == 2'b11) begin
                            if (count == 2'd1)
                                temp_a <= OPA << 1;
                            else if (count == 2'd2)
                                RES <= temp_a * OPB;
                        end 
                        else
                             ERR <= 1;
                    end

                    4'd11: begin//Signed addition
                        signed_a = OPA;
                        signed_b = OPB;
                        if (INP_VALID == 2'b11) begin
                            RES <= signed_a + signed_b;
                            OFLOW <= (signed_a[WIDTH-1] == signed_b[WIDTH-1]) &&
                                     (sum_ext[WIDTH] != signed_a[WIDTH-1]);
                            G <= signed_a > signed_b;
                            E <= signed_a == signed_b;
                            L <= signed_a < signed_b;
                        end 
                        else 
                            ERR <= 1;
                    end

                    4'd12: begin//signed subtraction
                        signed_a = OPA;
                        signed_b = OPB;
                        if (INP_VALID == 2'b11) begin
                            RES <= signed_a - signed_b;
                            OFLOW <= (signed_a[WIDTH-1] != signed_b[WIDTH-1]) &&
                                     (sum_ext[WIDTH] != signed_a[WIDTH-1]);
                            G <= signed_a > signed_b;
                            E <= signed_a == signed_b;
                            L <= signed_a < signed_b;
                        end 
                        else 
                            ERR <= 1;
                    end

                    default: ERR <= 1;

                endcase
            end

            else begin // LOGICAL OPERATIONN
                case (CMD)

                     4'd0: begin //AND
                         if (INP_VALID==2'b11) 
                            RES <= OPA & OPB; 
                         else 
                            ERR<=1;
                        end

                    4'd1: begin//NAND
                          if (INP_VALID==2'b11) 
                            RES <= ~(OPA & OPB); 
                          else 
                            ERR<=1;
                        end

                    4'd2: begin//OR
                            if (INP_VALID==2'b11) 
                                RES <= OPA | OPB; 
                            else 
                                ERR<=1;
                    end

                    4'd3: begin//NOR
                            if (INP_VALID==2'b11) 
                                RES <= ~(OPA | OPB); 
                            else 
                                ERR<=1;
                    end

                    4'd4: begin//XOR
                            if (INP_VALID==2'b11) 
                                   RES <= OPA ^ OPB; 
                            else 
                                    ERR<=1;
                    end

                    4'd5: begin//XNOR
                            if (INP_VALID==2'b11) 
                                    RES <= ~(OPA ^ OPB); 
                            else 
                                    ERR<=1;
                    end

                    4'd6: begin//NOT A
                        if (INP_VALID[0]) 
                            RES <= ~OPA; 
                        else 
                            ERR<=1;
                    end

                    4'd7: begin//NOT B
                        if (INP_VALID[1]) 
                                RES <= ~OPB; 
                        else 
                                ERR<=1;
                    end

                    4'd8: begin//SHFTR1_A
                        if (INP_VALID[0]) 
                                RES <= OPA >> 1; 
                        else 
                                ERR<=1;
                    end

                    4'd9: begin//SHFTL1_A
                        if (INP_VALID[0]) 
                                RES <= OPA << 1; 
                        else 
                            ERR<=1;
                    end

                    4'd10: begin//SHFTR1_B
                         if (INP_VALID[1]) 
                            RES <= OPB >> 1; 
                         else 
                              ERR<=1;
                    end

                    4'd11: begin//SHFTL1_B
                        if (INP_VALID[1]) 
                            RES <= OPB << 1; 
                        else ERR<=1;
                    end

                    4'd12: begin//ROtate left
                        if (INP_VALID==2'b11)
                            RES[WIDTH-1:0] <= (OPA << (OPB % WIDTH)) | (OPA >> (WIDTH - (OPB % WIDTH)));
                        else 
                            ERR<=1;
                    end

                    4'd13: begin//rotate right
                        if (INP_VALID==2'b11)
                         RES[WIDTH-1:0] <= (OPA >> (OPB % WIDTH)) | (OPA << (WIDTH - (OPB % WIDTH)));
                        else 
                            ERR<=1;
                     end



                    default: ERR <= 1;

                endcase
            end
        end
    end

endmodule
