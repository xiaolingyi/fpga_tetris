module top(
	//输入信号
	input clk,
	input rst_n,
	input start,
	input pause,
	input grade,
	input right,
	input left,
	input rotate,
	input down,
	//输出信号
	output lcd_dclk,
	output lcd_vsync,
	output lcd_hsync,
	output [7:0]lcd_b,
	output [7:0]lcd_r,
	output [7:0]lcd_g,
	output lcd_de,
	
	output high,
	output beep

);
	assign high=1;
	
	parameter ROW = 10,COL = 8;
	
//--------------------------------------------------//
//------------------分频模块，50M分至1K---------------//
//--------------------------------------------------//	
	wire clk_1k;
	pll_1k pll_1k(.clk_in(clk),.clk_out(clk_1k));

//--------------------------------------------------//
//------------------按键扫描模块----------------------//
//--------------------------------------------------//	
	wire key_start;
	wire key_right;
	wire key_left;
	wire key_rotate;
	wire key_down;
	wire key_pause;
	wire key_grade;
	key_scanner key_start_scanner(.clk(clk_1k),.rst_n(rst_n),.k(start),.k_flag(key_start));
	key_scanner key_pause_scanner(.clk(clk_1k),.rst_n(rst_n),.k(pause),.k_flag(key_pause));
	key_scanner key_grade_scanner(.clk(clk_1k),.rst_n(rst_n),.k(grade),.k_flag(key_grade));
	key_scanner key_right_scanner(.clk(clk_1k),.rst_n(rst_n),.k(right),.k_flag(key_right));
	key_scanner key_left_scanner(.clk(clk_1k),.rst_n(rst_n),.k(left),.k_flag(key_left));
	key_scanner key_rotate_scanner(.clk(clk_1k),.rst_n(rst_n),.k(rotate),.k_flag(key_rotate));
	key_scanner key_down_scanner(.clk(clk_1k),.rst_n(rst_n),.k(down),.k_flag(key_down));
	
//--------------------------------------------------//
//--------------------控制模块-----------------------//
//--------------------------------------------------//	
	
	//连线定义
	wire [3:0]action;
	wire gen_new;
	wire hold;
	wire check_move;
	wire check_down;
	wire shift;
	wire fix_block;
	wire clr_row;
	wire check_die;
	wire game_over;
	wire be_idle;
	wire can_move;
	wire can_down;
	wire clr_over;
	wire isdie;

	wire gen_new_over;
	wire check_down_over;
	wire check_move_over;
	wire shift_over;
	wire check_die_over;
	wire fix_over;

	wire [9:0]score_out;
	
control_2section control_2section(.clk(clk_1k),.rst_n(rst_n),.start(key_start),.pause(key_pause),.grade(key_grade),
		
		.right(key_right),.left(key_left),.down(key_down),.rotate(key_rotate),
		
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
		
		.be_idle(be_idle)
		
);
//--------------------------------------------------//
//--------------------数据通路模块--------------------//
//--------------------------------------------------//

	wire [3:0]next_block;
	wire [ROW*COL-1:0]Background1;
	datapath datapath(
			.clk(clk_1k),.rst_n(rst_n),
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
			.isdie(isdie),
			.next_block(next_block),
			.score_out(score_out)
			
	);
	//
//--------------------------------------------------//
//--------------------显示模块-----------------------//
//--------------------------------------------------//
	sync_module sync_module(
			.clk_50M(clk),
			.rstn(rst_n),
			.Background1(Background1),
			.new_block(next_block),
			.score(score_out),
			.lcd_dclk(lcd_dclk),
			.lcd_vsync(lcd_vsync),
			.lcd_hsync(lcd_hsync),
			.lcd_b(lcd_b),
			.lcd_r(lcd_r),
			.lcd_g(lcd_g),
			.lcd_de(lcd_de)
	);
//--------------------------------------------------//
//--------------------音乐模块-----------------------//
//--------------------------------------------------//
	//
	assign beep=~game_over;
//wire beep_music;
//assign beep=~game_over|beep_music;
/*
	music_module sos_module(
	.CLK(clk), 
	.RSTn(~hold), 
	.Pin_in(gen_new), 
	.Pin_Out(beep_music) 
	);
*/

endmodule