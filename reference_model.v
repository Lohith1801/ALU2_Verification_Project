`define WIDTH 8
`define CMD_WIDTH 4

module ref_mod(

    input CLK, RST, MODE, CE,
    input [1:0] INP_VALID,
    input [`CMD_WIDTH-1:0] CMD,
    input [`WIDTH-1:0] OPA, OPB,
    input CIN,

    output reg [2*`WIDTH-1:0] RES,
    output reg OFLOW, COUT, G, L, E, ERR
);

    integer i;
    reg [`WIDTH-1:0] temp;

    wire signed [`WIDTH-1:0] signed_a, signed_b;
    wire signed [`WIDTH:0] sum_ext;

    assign signed_a = $signed(OPA);
    assign signed_b = $signed(OPB);
    assign sum_ext  = signed_a + signed_b;

    always @(posedge CLK or posedge RST) begin

        if(RST) begin
            RES = 0;
            OFLOW = 0;
            COUT = 0;
            G = 0;
            L = 0;
            E = 0;
            ERR = 0;
        end

        else begin

            if(CE) begin

                RES = 0;
                OFLOW = 0;
                COUT = 0;
                G = 0;
                L = 0;
                E = 0;
                ERR = 0;

                if(MODE) begin

                    case(CMD[3:0])

                        4'd0: begin
                            @(posedge CLK);
                            {COUT,RES[`WIDTH-1:0]} = (INP_VALID == 2'b11) ? (OPA+OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd1: begin
                            @(posedge CLK);
                            RES[`WIDTH-1:0] = (INP_VALID == 2'b11) ? (OPA-OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd2: begin
                            @(posedge CLK);
                            {COUT,RES[`WIDTH-1:0]} = (INP_VALID == 2'b11) ? (OPA+OPB+CIN) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd3: begin
                            @(posedge CLK);
                            RES[`WIDTH-1:0] = (INP_VALID == 2'b11) ? (OPA-OPB-CIN) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd4: begin
                            @(posedge CLK);
                            RES[`WIDTH-1:0] = (INP_VALID[0] == 1'b1) ? (OPA+1) : 0;
                            ERR = (INP_VALID[0] == 1'b1) ? 0 : 1;
                        end

                        4'd5: begin
                            @(posedge CLK);
                            RES[`WIDTH-1:0] = (INP_VALID[0] == 1'b1) ? (OPA-1) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd6: begin
                            @(posedge CLK);
                            RES[`WIDTH-1:0] = (INP_VALID[1] == 1'b1) ? (OPB+1) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd7: begin
                            @(posedge CLK);
                            RES[`WIDTH-1:0] = (INP_VALID[1] == 1'b1) ? (OPB-1) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd8: begin
                            @(posedge CLK);
                            G = (INP_VALID == 2'b11) ? (OPA > OPB) : 0;
                            E = (INP_VALID == 2'b11) ? (OPA == OPB) : 0;
                            G = (INP_VALID == 2'b11) ? (OPA < OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd9: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? (RES) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;

                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? {(2*`WIDTH){1'bx}} : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;

                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? ((OPA+1)*(OPB+1)) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd10: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? (RES) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;

                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? {(2*`WIDTH){1'bx}} : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;

                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? ((OPA>>1)*(OPB)) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd11: begin
                            @(posedge CLK);
                            {COUT,RES[`WIDTH-1:0]} = (INP_VALID == 2'b11) ? (signed_a+signed_b) : 0;

                            OFLOW = (INP_VALID == 2'b11) ?
                                     ((signed_a[`WIDTH-1] == signed_b[`WIDTH-1]) &&
                                     (sum_ext[`WIDTH] != signed_a[`WIDTH-1])) : 0;

                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd12: begin
                            @(posedge CLK);
                            {COUT,RES[`WIDTH-1:0]} = (INP_VALID == 2'b11) ? (signed_a-signed_b) : 0;

                            OFLOW = (INP_VALID == 2'b11) ?
                                     ((signed_a[`WIDTH-1] != signed_b[`WIDTH-1]) &&
                                     (sum_ext[`WIDTH] != signed_a[`WIDTH-1])) : 0;

                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        default: begin
                            RES = 0;
                            ERR = 1;
                        end

                    endcase
                end

                else begin

                    case(CMD)

                        4'd0: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? (OPA&OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd1: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? ~(OPA&OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd2: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? (OPA|OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd3: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? ~(OPA|OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd4: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? (OPA^OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd5: begin
                            @(posedge CLK);
                            RES = (INP_VALID == 2'b11) ? ~(OPA^OPB) : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd6: begin
                            @(posedge CLK);
                            RES = (INP_VALID[0] == 1'b1) ? (~OPA) : 0;
                            ERR = (INP_VALID[0] == 1'b1) ? 0 : 1;
                        end

                        4'd7: begin
                            @(posedge CLK);
                            RES = (INP_VALID[1] == 1'b1) ? (~OPB) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd8: begin
                            @(posedge CLK);
                            RES = (INP_VALID[0] == 1'b1) ? (OPA>>1) : 0;
                            ERR = (INP_VALID[0] == 1'b1) ? 0 : 1;
                        end

                        4'd9: begin
                            @(posedge CLK);
                            RES = (INP_VALID[0] == 1'b1) ? (OPA<<1) : 0;
                            ERR = (INP_VALID[0] == 1'b1) ? 0 : 1;
                        end

                        4'd10: begin
                            @(posedge CLK);
                            RES = (INP_VALID[1] == 1'b1) ? (OPB>>1) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd11: begin
                            @(posedge CLK);
                            RES = (INP_VALID[1] == 1'b1) ? (OPB<<1) : 0;
                            ERR = (INP_VALID[1] == 1'b1) ? 0 : 1;
                        end

                        4'd12: begin
                            @(posedge CLK);

                            for(i=0; i<=OPB[$clog2(`WIDTH)-1:0]; i=i+1) begin
                                temp = {OPA[`WIDTH-2:0],OPA[`WIDTH-1]};
                            end

                            RES = (INP_VALID == 2'b11) ? temp : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        4'd13: begin
                            @(posedge CLK);

                            for(i=0; i<OPB[$clog2(`WIDTH)-1:0]; i=i+1) begin
                                temp = {OPA[0],OPA[`WIDTH-1:1]};
                            end

                            RES = (INP_VALID == 2'b11) ? temp : 0;
                            ERR = (INP_VALID == 2'b11) ? 0 : 1;
                        end

                        default: begin
                            RES = 0;
                            ERR = 1;
                        end

                    endcase
                end
            end
        end
    end

endmodule 
