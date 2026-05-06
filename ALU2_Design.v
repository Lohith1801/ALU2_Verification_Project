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
    reg [WIDTH-1:0]OPA_w,OPB_w;
    reg [WIDTH-1:0] temp_a, temp_b;
    reg signed [WIDTH-1:0] signed_a, signed_b;
    
    //signed addition wiring
    wire [WIDTH:0] sum_ext;
    assign sum_ext = $signed(OPA_w) + $signed(OPB_w);

    //counter logic for Arithmatic CMD =9 and CMD=10
    always @(posedge CLK) begin
      if (MODE && (CMD == 4'd9 || CMD == 4'd10)) begin
          if(count <2) 
            count <= count + 1;
          else
            count <= 1;
      end
      else
           count <=0;
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
            OPA_w <= OPA;
            OPB_w <= OPB;

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
                            {COUT, RES[WIDTH-1:0]} <= OPA_w + OPB_w;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd1: begin//subtraction
                        if (INP_VALID == 2'b11)
                            RES[WIDTH-1:0] <= OPA_w - OPB_w;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd2: begin//Addition with CIN
                        if (INP_VALID == 2'b11)
                            {COUT, RES[WIDTH-1:0]} <= OPA_w + OPB_w + CIN;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd3: begin//Subtraction with CIN
                        if (INP_VALID == 2'b11)
                            RES[WIDTH-1:0] <= OPA_w - OPB_w - CIN;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd4: begin//increment A
                        if (INP_VALID[0])
                            RES[WIDTH-1:0] <= OPA_w + 1;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd5: begin//decrement A
                        if (INP_VALID[0])
                            RES[WIDTH-1:0] <= OPA_w - 1;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd6: begin// Increment B
                        if (INP_VALID[1])
                            RES[WIDTH-1:0] <= OPB_w + 1;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd7: begin//Decrement B
                        if (INP_VALID[1])
                            RES[WIDTH-1:0] <= OPB_w - 1;
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd8: begin//CMP
                        if (INP_VALID == 2'b11) begin
                            G <= (OPA_w > OPB_w);
                            E <= (OPA_w == OPB_w);
                            L <= (OPA_w < OPB_w);
                        end 
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd9: begin// Incremented Multiplication
                        if (INP_VALID == 2'b11) begin
                          if (count == 2'd1) begin
                                temp_a <= OPA_w + 1;
                                temp_b <= OPB_w + 1;
                                RES <= 'bx;
                          end
                          else if (count == 2'd2) begin
                                RES <= temp_a * temp_b;
                          end
                          else
                                RES <= RES;
                        end
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd10: begin//Shifted multiplication
                        if (INP_VALID == 2'b11) begin
                          if (count == 2'd1) begin
                                temp_a <= OPA_w << 1;
                                RES <= 'bx;
                          end
                          else if (count == 2'd2) begin
                                RES <= temp_a * OPB_w;
                          end
                          else
                                RES <= RES;
                        end
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd11: begin//Signed addition
                      signed_a = $signed(OPA_w);
                      signed_b = $signed(OPB_w);
                        if (INP_VALID == 2'b11) begin
                            RES <= signed_a + signed_b;
                            OFLOW <= (signed_a[WIDTH-1] == signed_b[WIDTH-1]) &&
                                     (sum_ext[WIDTH] != signed_a[WIDTH-1]);
                            G <= signed_a > signed_b;
                            E <= signed_a == signed_b;
                            L <= signed_a < signed_b;
                        end 
                        else begin ERR <= 1; RES <= 0; end
                    end

                    4'd12: begin//signed subtraction
                        signed_a = OPA_w;
                        signed_b = OPB_w;
                        if (INP_VALID == 2'b11) begin
                            RES <= signed_a - signed_b;
                            OFLOW <= (signed_a[WIDTH-1] != signed_b[WIDTH-1]) &&
                                     (sum_ext[WIDTH] != signed_a[WIDTH-1]);
                            G <= signed_a > signed_b;
                            E <= signed_a == signed_b;
                            L <= signed_a < signed_b;
                        end 
                        else begin ERR <= 1; RES <= 0; end
                    end

                    default: begin ERR <= 1; RES <= 0; end

                endcase
            end

            else begin // LOGICAL OPERATIONN
                case (CMD)

                     4'd0: begin //AND
                         if (INP_VALID==2'b11) 
                            RES <= OPA_w & OPB_w; 
                         else begin ERR<=1; RES <= 0; end
                        end

                    4'd1: begin//NAND
                          if (INP_VALID==2'b11) 
                            RES <= ~(OPA_w & OPB_w); 
                          else begin ERR<=1; RES <= 0; end
                        end

                    4'd2: begin//OR
                            if (INP_VALID==2'b11) 
                                RES <= OPA_w | OPB_w; 
                            else begin ERR<=1; RES <= 0; end
                    end

                    4'd3: begin//NOR
                            if (INP_VALID==2'b11) 
                                RES <= ~(OPA_w | OPB_w); 
                            else begin ERR<=1; RES <= 0; end
                    end

                    4'd4: begin//XOR
                            if (INP_VALID==2'b11) 
                                   RES <= OPA_w ^ OPB_w; 
                            else begin ERR<=1; RES <= 0; end
                    end

                    4'd5: begin//XNOR
                            if (INP_VALID==2'b11) 
                                    RES <= ~(OPA_w ^ OPB_w); 
                            else begin ERR<=1; RES <= 0; end
                    end

                    4'd6: begin//NOT A
                        if (INP_VALID[0]) 
                            RES <= ~OPA_w; 
                        else begin ERR<=1; RES <= 0; end
                    end

                    4'd7: begin//NOT B
                        if (INP_VALID[1]) 
                                RES <= ~OPB_w; 
                        else begin ERR<=1; RES <= 0; end
                    end

                    4'd8: begin//SHFTR1_A
                        if (INP_VALID[0]) 
                                RES <= OPA_w >> 1; 
                        else begin ERR<=1; RES <= 0; end
                    end

                    4'd9: begin//SHFTL1_A
                        if (INP_VALID[0]) 
                                RES <= OPA_w << 1; 
                        else begin ERR<=1; RES <= 0; end
                    end

                    4'd10: begin//SHFTR1_B
                         if (INP_VALID[1]) 
                            RES <= OPB_w >> 1; 
                         else begin ERR<=1; RES <= 0; end
                    end

                    4'd11: begin//SHFTL1_B
                        if (INP_VALID[1]) 
                            RES <= OPB_w << 1; 
                        else begin ERR<=1; RES <= 0; end
                    end

                    4'd12: begin//ROtate left
                        if (INP_VALID==2'b11)
                            RES[WIDTH-1:0] <= (OPA_w << (OPB_w % WIDTH)) | (OPA_w >> (WIDTH - (OPB_w % WIDTH)));
                        else begin ERR<=1; RES <= 0; end
                    end

                    4'd13: begin//rotate right
                        if (INP_VALID==2'b11)
                         RES[WIDTH-1:0] <= (OPA_w >> (OPB_w % WIDTH)) | (OPA_w << (WIDTH - (OPB_w % WIDTH)));
                        else begin ERR<=1; RES <= 0; end
                     end

                    default: begin ERR <= 1; RES <= 0; end

                endcase
            end
        end
        else begin
            RES <= 0;
        end
    end

endmodule
