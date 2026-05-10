module ref_mod #(
    parameter WIDTH = 8,
    parameter CMD_WIDTH = 4
)(
    input CLK, RST, MODE, CE,
    input [1:0] INP_VALID,
    input [CMD_WIDTH-1:0] CMD,
    input [WIDTH-1:0] OPA, OPB,
    input CIN,

    output reg [2*WIDTH-1:0] RES_exp,
    output reg OFLOW_exp, COUT_exp, G_exp, L_exp, E_exp, ERR_exp
);

    reg [CMD_WIDTH-1:0] CMD_w;
    reg [1:0] INP_VALID_w;
    reg [WIDTH-1:0] OPA_w, OPB_w;
    reg CIN_w;

    reg [1:0] count;
    reg [WIDTH-1:0] temp_a, temp_b;

    integer i;
    reg [WIDTH-1:0] temp;

    reg signed [WIDTH-1:0] signed_a, signed_b;

    wire signed [WIDTH:0] sum_ext;
    wire signed [WIDTH:0] diff_ext;

    assign sum_ext  = signed_a + signed_b;
    assign diff_ext = signed_a - signed_b;

    always @(posedge CLK or posedge RST) begin

        if(RST) begin
            CMD_w <= 0;
            INP_VALID_w <= 0;
            OPA_w <= 0;
            OPB_w <= 0;
            CIN_w <= 0;

            RES_exp <= 0;
            OFLOW_exp <= 0;
            COUT_exp <= 0;
            G_exp <= 0;
            L_exp <= 0;
            E_exp <= 0;
            ERR_exp <= 0;

            count <= 0;
            temp_a <= 0;
            temp_b <= 0;
        end

        else if(CE) begin

            CMD_w <= CMD;
            INP_VALID_w <= INP_VALID;
            OPA_w <= OPA;
            OPB_w <= OPB;
            CIN_w <= CIN;

            RES_exp <= 0;
            OFLOW_exp <= 0;
            COUT_exp <= 0;
            G_exp <= 0;
            L_exp <= 0;
            E_exp <= 0;
            ERR_exp <= 0;

            signed_a = OPA_w;
            signed_b = OPB_w;

            if(MODE && (CMD_w == 4'd9 || CMD_w == 4'd10)) begin
                if(count < 2)
                    count <= count + 1;
                else
                    count <= 1;
            end
            else begin
                count <= 0;
            end

            if(MODE) begin

                case(CMD_w)

                    4'd0: begin
                        if(INP_VALID_w == 2'b11)
                            {COUT_exp, RES_exp[WIDTH-1:0]} <= OPA_w + OPB_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd1: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp[WIDTH-1:0] <= OPA_w - OPB_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd2: begin
                        if(INP_VALID_w == 2'b11)
                            {COUT_exp, RES_exp[WIDTH-1:0]} <= OPA_w + OPB_w + CIN_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd3: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp[WIDTH-1:0] <= OPA_w - OPB_w - CIN_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd4: begin
                        if(INP_VALID_w[0])
                            RES_exp[WIDTH-1:0] <= OPA_w + 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd5: begin
                        if(INP_VALID_w[0])
                            RES_exp[WIDTH-1:0] <= OPA_w - 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd6: begin
                        if(INP_VALID_w[1])
                            RES_exp[WIDTH-1:0] <= OPB_w + 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd7: begin
                        if(INP_VALID_w[1])
                            RES_exp[WIDTH-1:0] <= OPB_w - 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd8: begin
                        if(INP_VALID_w == 2'b11) begin
                            G_exp <= (OPA_w > OPB_w);
                            E_exp <= (OPA_w == OPB_w);
                            L_exp <= (OPA_w < OPB_w);
                        end
                        else
                            ERR_exp <= 1;
                    end

                    4'd9: begin
                        if(INP_VALID_w == 2'b11) begin

                            if(count == 2'd1) begin
                                temp_a <= OPA_w + 1;
                                temp_b <= OPB_w + 1;
                                RES_exp <= 'bx;
                            end

                            else if(count == 2'd2) begin
                                RES_exp <= temp_a * temp_b;
                            end
                        end
                        else
                            ERR_exp <= 1;
                    end

                    4'd10: begin
                        if(INP_VALID_w == 2'b11) begin

                            if(count == 2'd1) begin
                                temp_a <= OPA_w << 1;
                                RES_exp <= 'bx;
                            end

                            else if(count == 2'd2) begin
                                RES_exp <= temp_a * OPB_w;
                            end
                        end
                        else
                            ERR_exp <= 1;
                    end

                    4'd11: begin
                        if(INP_VALID_w == 2'b11) begin

                            {COUT_exp, RES_exp[WIDTH-1:0]} <= signed_a + signed_b;

                            OFLOW_exp <=
                                (signed_a[WIDTH-1] == signed_b[WIDTH-1]) &&
                                (sum_ext[WIDTH] != signed_a[WIDTH-1]);

                            G_exp <= (signed_a > signed_b);
                            E_exp <= (signed_a == signed_b);
                            L_exp <= (signed_a < signed_b);
                        end
                        else
                            ERR_exp <= 1;
                    end

                    4'd12: begin
                        if(INP_VALID_w == 2'b11) begin

                            {COUT_exp, RES_exp[WIDTH-1:0]} <= signed_a - signed_b;

                            OFLOW_exp <=
                                (signed_a[WIDTH-1] != signed_b[WIDTH-1]) &&
                                (diff_ext[WIDTH] != signed_a[WIDTH-1]);

                            G_exp <= (signed_a > signed_b);
                            E_exp <= (signed_a == signed_b);
                            L_exp <= (signed_a < signed_b);
                        end
                        else
                            ERR_exp <= 1;
                    end

                    default: begin
                        ERR_exp <= 1;
                    end

                endcase
            end

            else begin

                case(CMD_w)

                    4'd0: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp <= OPA_w & OPB_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd1: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp <= ~(OPA_w & OPB_w);
                        else
                            ERR_exp <= 1;
                    end

                    4'd2: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp <= OPA_w | OPB_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd3: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp <= ~(OPA_w | OPB_w);
                        else
                            ERR_exp <= 1;
                    end

                    4'd4: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp <= OPA_w ^ OPB_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd5: begin
                        if(INP_VALID_w == 2'b11)
                            RES_exp <= ~(OPA_w ^ OPB_w);
                        else
                            ERR_exp <= 1;
                    end

                    4'd6: begin
                        if(INP_VALID_w[0])
                            RES_exp <= ~OPA_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd7: begin
                        if(INP_VALID_w[1])
                            RES_exp <= ~OPB_w;
                        else
                            ERR_exp <= 1;
                    end

                    4'd8: begin
                        if(INP_VALID_w[0])
                            RES_exp <= OPA_w >> 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd9: begin
                        if(INP_VALID_w[0])
                            RES_exp <= OPA_w << 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd10: begin
                        if(INP_VALID_w[1])
                            RES_exp <= OPB_w >> 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd11: begin
                        if(INP_VALID_w[1])
                            RES_exp <= OPB_w << 1;
                        else
                            ERR_exp <= 1;
                    end

                    4'd12: begin
                        if(INP_VALID_w == 2'b11) begin

                            temp = OPA_w;

                            for(i=0; i<OPB_w[$clog2(WIDTH)-1:0]; i=i+1)
                                temp = {temp[WIDTH-2:0], temp[WIDTH-1]};

                            RES_exp <= temp;
                        end
                        else
                            ERR_exp <= 1;
                    end

                    4'd13: begin
                        if(INP_VALID_w == 2'b11) begin

                            temp = OPA_w;

                            for(i=0; i<OPB_w[$clog2(WIDTH)-1:0]; i=i+1)
                                temp = {temp[0], temp[WIDTH-1:1]};

                            RES_exp <= temp;
                        end
                        else
                            ERR_exp <= 1;
                    end

                    default: begin
                        ERR_exp <= 1;
                    end

                endcase
            end
        end
    end

endmodule
