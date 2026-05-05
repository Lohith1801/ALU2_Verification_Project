module ALU2 #(parameter WIDTH = 8)(CLK,RST,INP_VALID,MODE,CMD,CE,OPA,OPB,CIN,RES,OFLOW,COUT,G,L,E,ERR);
	
	//input ports
	input CLK, RST, INP_VALID,MODE,CE;
	input [3:0]CMD;
	input [WIDTH-1:0]OPA, OPB;
	input CIN;

	//counter and temporary variables
	reg [1:0]count;
	reg [WIDTH-1:0]temp_a, temp_b, temp;
	reg signed [WIDTH-1:0]signed_a, signed_b;
        //output ports
	output reg [WIDTH*2 -1:0]RES;
	output reg OFLOW, COUT, G, L, E, ERR;
	always@(posedge CLK) begin
		if(MODE == 1 && (CMD == 4'd9 || CMD == 4'd10)) begin
			count = count + 1;
		end
		else 
			count =0;

	end

	always@(posedge CLK or posedge RST) begin
		if(RST) begin
			RES <= WIDTH{0};
			OFLOW <=0;
			COUT <=0;
			G <=0;
			L<=0;
			E<=0;
			ERR <=0;
			count <= 0;
		end
		
		else begin
			if(~CE) begin
				RES <= RES;
				OFLOW <= OFLOW;
				COUT <= COUT;
				G <=G;
				L<=L;
				E <=E;
				ERR <=ERR;
			end
			
			else begin
				if(MODE) begin  //ARITHMATIC OPERATION
					RES = WIDTH{0};
                        		OFLOW =0;
                        		COUT =0;
                        		G =0;
                        		L=0;
                        		E=0;
                        		ERR =0;
                        		count = 0;
					cout
					case(CMD)
						4'd0: begin
							{G,E,L}= 3'b000;
							case(INP_VALID)
								2'b11: begin
									
									RES = OPA + OPB;
									COUT = RES[WIDTH]; 
									ERR <= 0;
									end
								default : begin
										RES <= WIDTH{0};
										ERR <= 1;
									end
							endcase
						
						4'd1: begin
							{G,E,L}= 3'b000;
							case(INP_VALID)
                                                                2'b11: begin
                                                                        RES = OPA - OPB;
                                                                        ERR = 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
						4'd2: begin
							{G,E,L}= 3'b000;
							case(INP_VALID)
                                                                2'b11: begin
                                                                        RES = OPA + OPB + CIN;
                                                                        COUT = RES[WIDTH];
									ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
						4'd3: begin
							{G,E,L}= 3'b000;
							case(INP_VALID)
                                                                2'b11: begin
                                                                        RES = OPA - OPB - CIN;
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase

						4'd4: begin
							
							{G,E,L}= 3'b000;
							if(INP_VALID[0] == 1) begin
								temp = OPA +1;
								RES <= temp;
								ERR <=0;
							else
							else begin
								 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end
						4'd5: begin
							{G,E,L}= 3'b000;
                                                        if(INP_VALID[0] == 1) begin
                                                               	temp = OPA -1;
								RES <= temp;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end	

						4'd6: begin
							{G,E,L}= 3'b000;
                                                        if(INP_VALID[1] == 1) begin
                                                                temp = OPB +1;
								RES <= temp;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end
						4'd7: begin
							{G,E,L}= 3'bzzz;
                                                        if(INP_VALID[1] == 1) begin
                                                               
								temp = OPB -1;
								RES <= temp;
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
									{G,E,L} = {(OPA>OPB),(OPA==OPB),(OPA<OPB)};					
									end
								default:
									{G,E,L} = 3'b000;
									ERR =1;
							endcase
						4'd9: begin
							
							if(INP_VALIF == 2'b11) begin

							case(count)
								2'd1: begin
									temp_a <= OPA;
									temp_b <= OPB;
									end
								2'd2: begin
									temp_a++;
									temp_b++;
									end
								2'd3: begin
									RES <= temp_a * temp_b;
									count <= 0;
								end
								default: count <= 0;
							endcase
							end
							
							else begin
								RES <= WIDTH{0};
								ERR <= 1;
							end	
					

						4'd10: begin
							if(INP_VALID == 2'b11) begin
							case(count)
                                                                2'd1: begin
                                                                        temp_a <= OPA;
                                                                        temp_b <= OPB;
                                                                        end
                                                                2'd2: begin
                                                                        temp = temp_a << 1;
                                                                        end
                                                                2'd3: begin
                                                                        RES <= temp * temp_b;
                                                                        count <= 0;
                                                                	end
								default : count <=0;
                                                        endcase
							end
							else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end
								
                                                4'd11: begin
							COUT = 0;
							signed_a = OPA;
							signed_b = OPB;
							if(INP_VALID == 2'b11) begin
								RES = signed_a + signed_b;	
								OFLOW = (signed_a[WIDTH-1]==signed_b[WIDTH-1]) && (RES[WIDTH] != signed_a[WIDTH-1]);
							end
							else begin
								RES <= WIDTH{0};
								ERR <= 1;
							end
							end
						4'd12: begin
                                                        COUT = 0;
                                                        signed_a = OPA;
                                                        signed_b = OPB;
                                                        if(INP_VALID == 2'b11) begin
                                                                RES = signed_a + signed_b;
                                                                OFLOW = (signed_a[WIDTH-1]==signed_b[WIDTH-1]) && (RES[WIDTH] != signed_a[WIDTH-1]);
								L = RES[WIDTH] ^ OFLOW;
								E = signed_a == signed_b;
								G = ~(L&E);
                                                        end
                                                        else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end
                                                        end
						4'd13: begin
                                                        COUT = 0;
                                                        signed_a = OPA;
                                                        signed_b = OPB;
                                                        if(INP_VALID == 2'b11) begin
                                                                RES = signed_a - signed_b;
                                                                OFLOW = (signed_a[WIDTH-1]!=signed_b[WIDTH-1]) && (RES[WIDTH] != signed_a[WIDTH-1]);
                                                                L = RES[WIDTH] ^ OFLOW;
                                                                E = signed_a == signed_b;
                                                                G = ~(L&E);
                                                        end
                                                        else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end
                                                        end
						default:begin
							 RES<= WIDTH{0};
							 ERR <= 1;
							end
				
					endcase
				end
				
				else begin // LOGICAL OPERATION
					 case(CMD)
                                                4'd0: begin
                                                        case(INP_VALID)
                                                                2'b11: begin

                                                                        RES = OPA & OPB;
                                                                   
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase

                                                4'd1: begin
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= OPA | OPB;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
                                                4'd2: begin
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= ~(OPA | OPB);
                                                                        
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
                                                4'd3: begin
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        {COUT,RES} <= OPA - OPB - CIN;
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase

                                                4'd4: begin

                                                        if(INP_VALID[0] == 1) begin
                                                                temp = OPA +1;
                                                                RES <= temp;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end
                                                4'd5: begin
                                                        if(INP_VALID[0] == 1) begin
                                                                temp = OPA -1;
                                                                RES <= temp;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end

                                                4'd6: begin
                                                        if(INP_VALID[1] == 1) begin
                                                                temp = OPB +1;
                                                                RES <= temp;
                                                                ERR <=0;
                                                        else
                                                        else begin
                                                                 RES <= WIDTH{0};
                                                                 ERR <= 1;
                                                        end
                                                      end
                                                4'd7: begin
                                                        if(INP_VALID[1] == 1) begin

                                                                temp = OPB -1;
                                                                RES <= temp;
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
                                                                        {G,E,L} = {(OPA>OPB),(OPA==OPB),(OPA<OPB)};
                                                                        end
                                                                default:
                                                                        {G,E,L} = 3'b000;
                                                                        ERR =1;
                                                        endcase
                                                4'd9: begin

                                                        if(INP_VALIF == 2'b11) begin

                                                        case(count)
                                                                2'd1: begin
                                                                        temp_a <= OPA;
                                                                        temp_b <= OPB;
                                                                        end
                                                                2'd2: begin
                                                                        temp_a++;
                                                                        temp_b++;
                                                                        end
                                                                2'd3: begin
                                                                        RES <= temp_a * temp_b;
                                                                        count <= 0;
                                                                end
                                                                default: count <= 0;
                                                        endcase
                                                        end

                                                        else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end


                                                4'd10: begin
                                                        if(INP_VALID == 2'b11) begin
                                                        case(count)
                                                                2'd1: begin
                                                                        temp_a <= OPA;
                                                                        temp_b <= OPB;
                                                                        end
                                                                2'd2: begin
                                                                        temp = temp_a << 1;
                                                                        end
                                                                2'd3: begin
                                                                        RES <= temp * temp_b;
                                                                        count <= 0;
                                                                        end
                                                                default : count <=0;
                                                        endcase
                                                        end
                                                        else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end

                                                4'd11: begin
                                                        COUT = 0;
                                                        signed_a = OPA;
                                                        signed_b = OPB;
                                                        if(INP_VALID == 2'b11) begin
                                                                RES = signed_a + signed_b;
                                                                OFLOW = (signed_a[WIDTH-1]==signed_b[WIDTH-1]) && (RES[WIDTH] != signed_a[WIDTH-1]);
                                                        end
                                                        else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end
                                                        end
                                                4'd12: begin
                                                        COUT = 0;
                                                        signed_a = OPA;
                                                        signed_b = OPB;
                                                        if(INP_VALID == 2'b11) begin
                                                                RES = signed_a + signed_b;
                                                                OFLOW = (signed_a[WIDTH-1]==signed_b[WIDTH-1]) && (RES[WIDTH] != signed_a[WIDTH-1]);
                                                                L = RES[WIDTH] ^ OFLOW;
                                                                E = signed_a == signed_b;
                                                                G = ~(L&E);
                                                        end
                                                        else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end
                                                        end
                                                4'd13: begin
                                                        COUT = 0;
                                                        signed_a = OPA;
                                                        signed_b = OPB;
                                                        if(INP_VALID == 2'b11) begin
                                                                RES = signed_a - signed_b;
                                                                OFLOW = (signed_a[WIDTH-1]!=signed_b[WIDTH-1]) && (RES[WIDTH] != signed_a[WIDTH-1]);
                                                                L = RES[WIDTH] ^ OFLOW;
                                                                E = signed_a == signed_b;
                                                                G = ~(L&E);
                                                        end
                                                        else begin
                                                                RES <= WIDTH{0};
                                                                ERR <= 1;
                                                        end
                                                        end
                                                default:begin
                                                         RES<= WIDTH{0};
                                                         ERR <= 1;
                                                        end

                                        endcase
                                end
