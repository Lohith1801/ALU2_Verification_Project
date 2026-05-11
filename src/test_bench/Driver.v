module Driver #(parameter WIDTH = 8, CMD_WIDTH ) (
input CLK,
output reg MODE,
output reg CE,
output reg [1:0] INP_VALID,
output reg [CMD_WIDTH-1:0] CMD,
output reg [WIDTH-1:0] OPA,
output reg [WIDTH-1:0] OPB,
output reg CIN
);

integer i;

task basic_arithmatic_operation;
begin
    for(i=0;i<13;i=i+1) begin
        @(negedge CLK);
        CMD <= i;
        INP_VALID <= $urandom_range(0,3);
        OPA <= $urandom;
        OPB <= $urandom;
        CIN <= $urandom_range(0,1);
        MODE <= 1'b1;
        CE <= $urandom_range(0,1);
    end
end
endtask

task basic_logical_operation;
begin
    for(i=0;i<14;i=i+1) begin
        @(negedge CLK);
        CMD <= i;
        INP_VALID <= $urandom_range(0,3);
        OPA <= $urandom;
        OPB <= $urandom;
        CIN <= $urandom_range(0,1);
        MODE <= 0;
        CE <= $urandom_range(0,1);
    end
end
endtask

task add_corner_cases;
begin
    @(negedge CLK);
    MODE <= 1; CMD <= 0; CE <= 1; INP_VALID <= 2'b11; OPA <= 8'hFF; OPB <= 8'h01; CIN <= 0;
    @(negedge CLK); OPA <= 8'h7F; OPB <= 8'h01;
    @(negedge CLK); OPA <= 8'h80; OPB <= 8'h80;
    @(negedge CLK); OPA <= 0; OPB <= 0;
end
endtask

task sub_corner_cases;
begin
    @(negedge CLK);
    MODE <= 1; CMD <= 1; CE <= 1; INP_VALID <= 2'b11; OPA <= 8'h00; OPB <= 8'h01;
    @(negedge CLK); OPA <= 8'h80; OPB <= 8'h01;
    @(negedge CLK); OPA <= 8'h7F; OPB <= 8'hFF;
end
endtask

task test_mid_op_changes;
    input [3:0] target_cmd;
begin
    @(negedge CLK);
    MODE <= 1; CMD <= target_cmd; CE <= 1; INP_VALID <= 2'b11;
    OPA <= $urandom; OPB <= $urandom;
    @(negedge CLK);
    OPA <= $urandom; 
    @(negedge CLK);
    CMD <= $urandom_range(0, 5); 
    @(negedge CLK);
end
endtask

task random_ce_stalling;
begin
    repeat(100) begin
        @(negedge CLK);
        CE <= ($urandom_range(0,9) < 8); 
        MODE <= $urandom;
        CMD  <= $urandom_range(0, 15);
        OPA  <= $urandom;
        OPB  <= $urandom;
        INP_VALID <= $urandom_range(0,3);
    end
end
endtask

task walking_bit_test;
    integer b;
begin
    @(negedge CLK);
    MODE <= 1; CMD <= 0; CE <= 1; INP_VALID <= 2'b11;
    for(b=0; b<WIDTH; b=b+1) begin
        @(negedge CLK);
        OPA <= (1 << b);
        OPB <= ~(1 << b);
    end
end
endtask

task explicit_invalid_cmds;
begin
    @(negedge CLK);
    CE <= 1; MODE <= 1;
    CMD <= 4'd14; INP_VALID <= 2'b11;
    @(negedge CLK);
    CMD <= 4'd15;
    @(negedge CLK);
    CMD <= 0; INP_VALID <= 2'b01; 
    @(negedge CLK);
    INP_VALID <= 2'b10;
    @(negedge CLK);
    MODE <= 0; CMD <= 4'd14; INP_VALID <= 2'b11;
end
endtask

task signed_overflow_tests;
begin
    @(negedge CLK);
    CMD <= 11; MODE <= 1; CE <= 1; INP_VALID <= 2'b11;
    OPA <= 8'h7F; OPB <= 8'h01;
    @(negedge CLK);
    OPA <= 8'h80; OPB <= 8'hFF;
    @(negedge CLK);
    CMD <= 12;
    OPA <= 8'h7F; OPB <= 8'hFF;
    @(negedge CLK);
    OPA <= 8'h80; OPB <= 8'h01;
end
endtask

task signed_add_overflow_pos;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 11;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd127;
    OPB <= 8'd1;
end
endtask

task signed_add_overflow_neg;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 11;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'h80;
    OPB <= 8'hFF;
end
endtask

task signed_sub_overflow_pos;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 12;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd127;
    OPB <= 8'hFF;
end
endtask

task signed_sub_overflow_neg;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 12;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'h80;
    OPB <= 8'd1;
end
endtask

task greater_case;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 8;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd50;
    OPB <= 8'd10;
end
endtask

task less_case;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 8;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd10;
    OPB <= 8'd50;
end
endtask

task equal_case;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 8;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd25;
    OPB <= 8'd25;
end
endtask

task invalid_case_00;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 0;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b00;

    OPA <= 8'd10;
    OPB <= 8'd20;
end
endtask

task invalid_case_01;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 0;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b01;

    OPA <= 8'd10;
    OPB <= 8'd20;
end
endtask

task invalid_case_10;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 0;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b10;

    OPA <= 8'd10;
    OPB <= 8'd20;
end
elu_paramndtask

task rotate_left_zero;
begin
    @(negedge CLK);
    MODE <= 0;
    CMD <= 12;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'b10101010;
    OPB <= 0;
end
endtask

task rotate_left_nonzero;
begin
    @(negedge CLK);
    MODE <= 0;
    CMD <= 12;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'b10101010;
    OPB <= 3;
end
endtask

task rotate_left_error;
begin
    @(negedge CLK);
    MODE <= 0;
    CMD <= 12;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'b10101010;
    OPB <= 8'hF0;
end
endtask

task rotate_right_zero;
begin
    @(negedge CLK);
    MODE <= 0;
    CMD <= 13;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'b11001100;
    OPB <= 0;
end
endtask

task rotate_right_nonzero;
begin
    @(negedge CLK);
    MODE <= 0;
    CMD <= 13;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'b11001100;
    OPB <= 2;
end
endtask

task rotate_right_error;
begin
    @(negedge CLK);
    MODE <= 0;
    CMD <= 13;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'b11001100;
    OPB <= 8'hF8;
end
endtask

task ce_low_case;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 5;
    CE <= 0;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd20;
    OPB <= 8'd10;
end
endtask

task mode_zero_case;
begin
    @(negedge CLK);
    MODE <= 0;
    CMD <= 4;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'hAA;
    OPB <= 8'h55;
end
endtask

task mode_one_case;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 4;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b01;

    OPA <= 8'd99;
    OPB <= 0;
end
endtask

task inc_mul_full;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 9;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd15;
    OPB <= 8'd12;

    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
end
endtask

task shift_mul_full;
begin
    @(negedge CLK);
    MODE <= 1;
    CMD <= 10;
    CE <= 1;
    CIN <= 0;
    INP_VALID <= 2'b11;

    OPA <= 8'd8;
    OPB <= 8'd7;

    @(negedge CLK);
    @(negedge CLK);
    @(negedge CLK);
end
endtask
task fec_bit7;
    begin
        @(negedge CLK);
        MODE <= 1; CMD <= 11; CE <= 1; INP_VALID <= 2'b11;
        OPA <= 8'h80; OPB <= 8'h80;
        @(negedge CLK);
        OPA <= 8'h7F; OPB <= 8'h7F;
        @(negedge CLK);
        OPA <= 8'h80; OPB <= 8'h01;
        @(negedge CLK);
        OPA <= 8'h7F; OPB <= 8'hFF;
        @(negedge CLK);
        OPA <= 8'h00; OPB <= 8'h80;
        @(negedge CLK);
        OPA <= 8'h40; OPB <= 8'h40;
    end
    endtask
task out_of_range_CMD;
	begin
		@(negedge CLK);
		MODE <= $urandom_range(0,1);
		CMD <= $urandom_range(13,15);
		OPA <= 8'h80; OPB <= 8'h01;
		CE <= $urandom_range(0,1);
		CIN <= $urandom_range(0,1);
		INP_VALID <= 2'b11;
	end
endtask
task branch_cov;
    begin
        @(negedge CLK);
        MODE <= 1'b0;
        CE <= 1'b1;
        INP_VALID <= 2'b11;
        CMD <= 4'd0;
        
        @(negedge CLK);
        CMD <= 4'd15;
        
        @(negedge CLK);
        INP_VALID <= 2'b01;
        
        @(negedge CLK);
        INP_VALID <= 2'b10;
        
        @(negedge CLK);
        MODE <= 1'b1;
        CMD <= 4'd0;
        CE <= 1'b1;
    end
    endtask
task invalid_cmd_arith;
beginalu_param
    @(negedge CLK);
    MODE <= 1;
    CE <= 1;
    CMD <= 15;
    INP_VALID <= 2'b11;
    OPA <= 8'h12;
    OPB <= 8'h34;
end
endtask


task invalid_cmd_logic;
begin
    @(negedge CLK);
    MODE <= 0;
    CE <= 1;
    CMD <= 15;
    INP_VALID <= 2'b11;
    OPA <= 8'h12;
    OPB <= 8'h34;
end
endtask


task ce_low_test;
begin
    @(negedge CLK);
    MODE <= 1;
    CE <= 0;
    CMD <= 0;
    INP_VALID <= 2'b11;
    OPA <= 8'h55;
    OPB <= 8'hAA;
end
endtask


task inp_valid_00;
begin
    @(negedge CLK);
    MODE <= 1;
    CE <= 1;
    CMD <= 0;
    INP_VALID <= 2'b00;
    OPA <= 8'h55;
    OPB <= 8'hAA;
end
endtask


task inp_valid_01;
begin
    @(negedge CLK);
    MODE <= 1;
    CE <= 1;
    CMD <= 4;
    INP_VALID <= 2'b01;
    OPA <= 8'h55;
    OPB <= 8'hAA;
end
endtask


task inp_valid_10;
begin
    @(negedge CLK);
    MODE <= 1;
    CE <= 1;
    CMD <= 6;
    INP_VALID <= 2'b10;
    OPA <= 8'h55;
    OPB <= 8'hAA;
end
endtask


task rotate_zero;
begin
    @(negedge CLK);
    MODE <= 0;
    CE <= 1;
    CMD <= 12;
    INP_VALID <= 2'b11;
    OPA <= 8'b10101010;
    OPB <= 0;
end
endtask


task rotate_full;
begin
    @(negedge CLK);
    MODE <= 0;
    CE <= 1;
    CMD <= 12;
    INP_VALID <= 2'b11;
    OPA <= 8'b10101010;
    OPB <= 8;
end
endtask
initial begin
    MODE = 0; CE = 0; INP_VALID = 0; CMD = 0; OPA = 0; OPB = 0; CIN = 0;
    #30;

    repeat(150) begin
		branch_cov();
        basic_arithmatic_operation();
        basic_logical_operation();
        add_corner_cases();
        sub_corner_cases();
        walking_bit_test();
        explicit_invalid_cmds();
        signed_overflow_tests();
        test_mid_op_changes(9);
        test_mid_op_changes(10);
        random_ce_stalling();
	fec_bit7();
	out_of_range_CMD();
	signed_add_overflow_pos();
    signed_add_overflow_neg();

    less_case();
    greater_case();
    equal_case();


	repeat(20) invalid_cmd_arith();
repeat(20) invalid_cmd_logic();

repeat(20) ce_low_test();

repeat(20) inp_valid_00();
repeat(20) inp_valid_01();
repeat(20) inp_valid_10();

repeat(20) rotate_zero();
repeat(20) rotate_full();
    end

    @(negedge CLK);
    CE <= 0;
    #100;
    $finish;
end



endmodule
