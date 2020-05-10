module top_check(
input clk,
input rst_n,
input start,

input down,
output gen_new,
output hold,
output shift,
output fix_block,
output clr_row,


output action_down,
output check_down,
output can_down,
output isdie,
output game_over,

output [ROW*COL-1:0]Background1
);
parameter ROW = 10,COL = 8;
assign action_down=action[0];
wire [3:0]action;

wire right;
wire left;
wire rotate;

assign right=0;
assign left=0;
assign rotate=0;

//wire gen_new;
//wire hold;
wire check_move;
//wire check_down;
//wire shift;
//wire fix_block;
//wire clr_row;
wire check_die;
//wire game_over;
wire be_idle;
wire can_move;
//wire can_down;
wire clr_over;
//wire isdie;

wire gen_new_over;
wire check_down_over;
wire check_move_over;
wire shift_over;
wire check_die_over;
wire fix_over;

wire native_down;
control_2section check_control_2section(
		.clk(clk),.rst_n(rst_n),.start(start),
		
		.right(right),.left(left),.down(rotate),.rotate(down),
		
		.gen_new_over(gen_new_over),
		.check_down_over(check_down_over),
		.check_move_over(check_move_over),
		.shift_over(shift_over),
		.check_die_over(check_die_over),
		.fix_over(fix_over),
		
		.can_move(can_move),
		.can_down(can_down),
		.clr_over(clr_over),
		.isdie(isdie),
		
		.action(action),
		.gen_new(gen_new),
		.hold(hold),
		
		.check_move(check_move),
		.check_down(check_down),
		.shift(shift),
		.fix_block(fix_block),
		.clr_row(clr_row),
		.check_die(check_die),
		.game_over(game_over),
		
		.be_idle(be_idle),
		.native_down(native_down)
);

datapath check_datapath(
		.clk(clk),.rst_n(rst_n),
		.action(action),
		.be_idle(be_idle),
		.gen_new(gen_new),
		.check_move(check_move),
		.check_down(check_down),
		.shift(shift),
		.fix_block(fix_block),
		.clr_row(clr_row),
		.check_die(check_die),
		.game_over(game_over),

		.Background1(Background1),
		
		.gen_new_over(gen_new_over),
		.check_down_over(check_down_over),
		.check_move_over(check_move_over),
		.shift_over(shift_over),
		.check_die_over(check_die_over),
		.fix_over(fix_over),
		.can_move(can_move),
		.can_down(can_down),
		.clr_over(clr_over),
		.isdie(isdie)
);
endmodule