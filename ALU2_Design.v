module ALU2 #(parameter WIDTH = 8)(CLK,RST,INP_VALID,MODE,CMD,CE,OPA,OPB,CIN,RES,OFLOW,COUT,G,L,E,ERR);

	input CLK, RST, INP_VALID,MODE,CE;
	input [3:0]CMD;
	input [WIDTH-1:0]OPA, OPB;
	input CIN;
	
	output [WIDTH*2 -1:0]RES;
	output OFLOW, COUT, G, L, E, ERR;

	always@(posedge CLK or posedge RST) begin
		if(RST) begin
			RES <= WIDTH{0};
			OFLOW <=0;
			COUT <=0;
			G <=0;
			L<=0;
			E<=0;
			ERR <=0;
		end
		
		else begin
			if(~CE) begin
				RES <= RES;
				OFLOW <= OFLOW;
				COUT <= COUT;
				G <=0;
				L<=0;
				E <=0;
				ERR <=0;
			end
			
			else begin
				if(MODE) begin
					case(CMD)
						4'd0: begin
							case(INP_VALID)
								2'b11: begin
									RES <= OPA + OPB;
									ERR <= 0;
									end
								default : begin
										RES <= WIDTH{0};
										ERR <= 1;
									end
							endcase
						
						4'd1: begin
							case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= OPA - OPB;
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
						4'd2: begin
							case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= OPA + OPB + CIN;
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
						4'd3: begin
							case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= OPA - OPB - CIN;
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase

						4'd4: begin
							if(INP_VALID[1] == 1) begin
								RES <= OPA +1;
								ERR <=0;
							else
							else begin
								 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end
						4'd5: begin
                                                        if(INP_VALID[1] == 1) begin
                                                                RES <= OPA -1;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end	

						4'd6: begin
                                                        if(INP_VALID[0] == 1) begin
                                                                RES <= OPB +1;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end
						4'd7: begin
                                                        if(INP_VALID[0] == 1) begin
                                                                RES <= OPB -1;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end
						4'd8: begin
                                                        case(INP_VALID)
								2'b11: begin
									G = (OPA>OPB);										       E = OPA== OPB;	
									L = OPA<OPB;
									end
								default:
									{G,E,L} = 3'b000;
							endcase
							

