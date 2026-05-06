module ALU2 #(parameter WIDTH = 8)(CLK,RST,INP_VALID,MODE,CMD,CE,OPA,OPB,CIN,RES,OFLOW,COUT,G,L,E,ERR);
	
	//input ports
	input CLK, RST,MODE,CE;
	input [1:0]INP_VALID
	input [3:0]CMD;
	input [WIDTH-1:0]OPA, OPB;
	input CIN;

	//counter and temporary variables
	reg [1:0]count;
	reg [WIDTH-1:0]temp_a, temp_b, temp;
	reg signed [WIDTH-1:0]signed_a, signed_b;
	reg temp_OFLOW, temp_G, temp_L, temp_E, temp_ERR, temp_COUT;
	wire [WIDTH -1 :0]sum;

        //output ports
	output reg [WIDTH*2 -1:0]RES;
	output reg OFLOW, COUT, G, L, E, ERR;
	sum = $signed(OPA) + $signed(OPB);
	always@(posedge CLK) begin
		if(MODE == 1) begin
			if(CMD == 4'd9) begin
				if(count != 0) begin
					count =0;
					count = count +1;
				end
				else begin
					if(count == 2'd3)
						count =0;
					else
						count = count + 1;
				end
			end
			else if(CMD == 4'd10) begin
                                if(count != 0) begin
                                        count =0;
                                        count = count +1;
                                end
                                else begin
                                        if(count == 2'd3)
                                                count =0;
                                        else
                                                count = count + 1;
                                end
                        end
					
					
			
		end
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
					RES <= WIDTH{0};
                        		OFLOW <=0;
                        		COUT <=0;
                        		G <=0;
                        		L<=0;
                        		E<=0;
                        		ERR <=0;
                        		count <= 0;
					
					case(CMD)
						4'd0: begin // Addition
							case(INP_VALID)
								2'b11: begin
									
									{temp_COUT,temp} = OPA + OPB;
									RES <= temp;
									COUT <= temp_COUT; 
									ERR <= 0;
									end
								default : begin
										RES <= WIDTH{0};
										ERR <= 1;
									end
							endcase
						
						4'd1: begin //Subtraction
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
						4'd2: begin //Addition with CIN
							case(INP_VALID)
                                                                2'b11: begin
                                                                        {temp_COUT,temp} = OPA + OPB + CIN;
                                                                        COUT <= temp_COUT;
									RES <= temp;
									ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
						4'd3: begin // Subtraction with CIN
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

						4'd4: begin //Increment_A
							
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
						4'd5: begin //Decrement_A
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

						4'd6: begin //Increment_B
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
						4'd7: begin //Decrement_B
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
						4'd8: begin //CMP
                                                        case(INP_VALID)
								2'b11: begin
									{G,E,L} = {(OPA>OPB),(OPA==OPB),(OPA<OPB)};					
									end
								default:begin
									{G,E,L} = 3'b000;
									ERR =1;
									end
							endcase
						4'd9: begin //Multiplication with incremented inputs
							
							if(INP_VALIF == 2'b11) begin
								temp_a = OPA;
								temp_b = OPB;
							case(count)
								2'd1: begin
									temp_a = temp_a +1;
                                                                        temp_b = temp_b +1;
									end
								2'd2: begin
									RES <= temp_a * temp_b;
									
									end
								2'd3: begin
									
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
							temp_a <= OPA;
                                                        temp_b <= OPB;
							case(count)
                                                                2'd1: begin
                                                                        temp = temp_a << 1;
                                                                        end
                                                                2'd2: begin
                                                                         RES <= temp * temp_b;
                                                                        end
                                                                2'd3: begin
                                                                       
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
								RES <= signed_a + signed_b;	
								OFLOW <= (signed_a[WIDTH-1]==signed_b[WIDTH-1]) && (sum[WIDTH] != signed_a[WIDTH-1]);
								L <= signed_a<signed_b;
                                                                E <= signed_a == signed_b;
                                                                G <= signed_a>signed_b;
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
                                                                RES <= signed_a + signed_b;
                                                                OFLOW <= (signed_a[WIDTH-1]==signed_b[WIDTH-1]) && (sum[WIDTH] != signed_a[WIDTH-1]);
								L <= signed_a<signed_b;
								E <= signed_a == signed_b;
								G <= signed_a>signed_b;
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
                                                4'd0: begin//AND
                                                        case(INP_VALID)
                                                                2'b11: begin

                                                                        RES <= OPA & OPB;
                                                                   
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase

                                                4'd1: begin//NAND
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= ~(OPA & OPB);
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
                                                4'd2: begin//OR
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= (OPA | OPB);
                                                                        
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
                                                4'd3: begin//NOR
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= ~(OPA | OPB);
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase

                                                4'd4: begin//XOR
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= (OPA ^ OPB);
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
						4'd5: begin//XNOR
                                                        case(INP_VALID)
                                                                2'b11: begin
                                                                        RES <= ~(OPA ^ OPB);
                                                                        ERR <= 0;
                                                                        end
                                                                default : begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        endcase
                                                4'd6: begin //NOT_A
                                                        if(INP_VALID==2'b01 || INP_VALID == 2'b11)begin
                                                                        RES <= ~(OPA);
                                                                        ERR <= 0;
                                                                        end
                                                                else begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        end
                                                4'd7: begin//NOT_B
                                                        if(INP_VALID==2'b10 || INP_VALID == 2'b11)begin
                                                                        RES <= ~(OPB);
                                                                        ERR <= 0;
                                                                        end
                                                                else begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        end
						4'd8: begin//shftR1_A
                                                        if(INP_VALID==2'b01 || INP_VALID == 2'b11)begin
                                                                      
									  RES <= OPA >>1;
                                                                        ERR <= 0;
                                                                        end
                                                                else begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        end
						4'd8: begin//shftL1_A
                                                        if(INP_VALID==2'b01 || INP_VALID == 2'b11)begin
                                                                      
                                                                          RES <= OPA <<1;
                                                                        ERR <= 0;
                                                                        end
                                                                else begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        end
						4'd10: begin//ShftR1_B
                                                        if(INP_VALID==2'b10 || INP_VALID == 2'b11)begin
                                                                          RES <= OPB >>1;
                                                                        ERR <= 0;
                                                                        end
                                                                else begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        end
						4'd11: begin//ShftL1_B
                                                        if(INP_VALID==2'b10 || INP_VALID == 2'b11)begin
                                                                          RES <= OPB <<1;
                                                                        ERR <= 0;
                                                                        end
                                                                else begin
                                                                                RES <= WIDTH{0};
                                                                                ERR <= 1;
                                                                        end
                                                        end
						12: case(INP_VALID)
        						3: begin
           						 if (|(OPB[(2*WIDTH)-1 : WIDTH])) begin
                						ERR <= 1'b1;
            						end
            						else begin
                						ERR <= 1'b0;
                						RES[WIDTH-1:0] <= (OPA << (OPB % WIDTH)) | (OPA >> (WIDTH - (OPB % WIDTH)));
                						RES[(2*WIDTH)-1 : WIDTH] <= 0;
            							end
        						end
        						default: begin
            							RES <= 0;	
            							ERR <= 1;
        						end
    							endcase

						13: case(INP_VALID)
        						3: begin
            						if (|(OPB[(2*WIDTH)-1 : WIDTH])) begin
                						ERR <= 1'b1;
            						end
            						else begin
                						ERR <= 1'b0;
                						RES[WIDTH-1:0] <= (OPA >> (OPB % WIDTH)) | (OPA << (WIDTH - (OPB % WIDTH)));
                						RES[(2*WIDTH)-1 : WIDTH] <= 0;
            						end
        						end
						endcase
						default:begin
                                                         RES<= WIDTH{0};
                                                         ERR <= 1;
                                                        end

                                        endcase
                                end
			end
		end
endmodule
