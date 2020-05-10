module control_2section(
	//输入信号
	input clk,
	input rst_n,
	input start,
	input pause,
	input grade,
	input right,
	input left,
	input down,
	input rotate,
	input gen_new_over,
	input check_down_over,
	input check_move_over,
	input check_die_over,
	input shift_over,
	input fix_over,

	input can_move,
	input can_down,
	input clr_over,
	input isdie,
	//输出信号
	output [3:0]action,
	output reg gen_new,
	output reg hold,
	output reg check_move,
	output reg check_down,
	output reg shift,
	output reg fix_block,
	output reg clr_row,
	output reg check_die,
	output reg game_over,
	output reg be_idle
);
	
//--------------------------------------------------//
//------------------状态编码，采用独热码---------------//
//--------------------------------------------------//	
	//
	parameter s_idle=10'b0000000001,
				s_gen_new=10'b0000000010,
				s_hold=10'b0000000100,
				s_check_move=10'b0000001000,
				s_check_down=10'b0000010000,
				s_shift=10'b0000100000,
				s_fix_block=10'b0001000000,
				s_clr_row=10'b0010000000,
				s_check_die=10'b0100000000,
				s_game_over=10'b1000000000;
			
	reg [9:0]next_state;
	reg [9:0]state;

//--------------------------------------------------//
//--------------------暂停功能的实现------------------//
//--------------------------------------------------//	
	
	reg pause_cnt;
	initial
	begin
	pause_cnt=0;
	end
	always@(posedge clk,negedge rst_n)
	begin
	if(~rst_n) pause_cnt=0;
	else if(pause==1)
		pause_cnt=pause_cnt+1'b1;
	else pause_cnt=pause_cnt;
	end

//--------------------------------------------------//
//--------------------分等级的实现--------------------//
//--------------------------------------------------//
	
	reg grade_cnt;
	initial
	begin
	grade_cnt=0;
	end
	always@(posedge clk,negedge rst_n)
	begin
	if(~rst_n) grade_cnt=0;
	else if(grade==1)
		grade_cnt=grade_cnt+1'b1;
	else grade_cnt=grade_cnt;
	end
	
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
	begin
	cnt_down1<=0;
	native_down_reg_1<=0;
	cnt_down2<=0;
	native_down_reg_2<=0;
	end
	else 	if(grade_cnt==1)
			begin 		
				begin
					
					if(hold==1&&cnt_down1!=go_down1&&pause_cnt==0)
							begin
								cnt_down1<=cnt_down1+1'b1;
							end
					else if(cnt_down1==go_down1)//
							begin
								cnt_down1<=0;
							end
					else cnt_down1<=cnt_down1;
				end
				
					if(cnt_down1==go_down1)
					begin
						native_down_reg_1<=1;
					end
					else native_down_reg_1<=0;
			end
	else 
		
			begin 
			
			if(hold==1&&cnt_down2!=go_down2&&pause_cnt==0)
					begin
						cnt_down2<=cnt_down2+1'b1;
					end
			else if(cnt_down2==go_down2)//
					begin
						cnt_down2<=0;
					end
			else cnt_down2<=cnt_down2;
			
			if(cnt_down2==go_down2)
				begin
				native_down_reg_2<=1;
				end
			else native_down_reg_2<=0;
				
			end
	end
	
//--------------------------------------------------//
//-----按键输入信号延时，以保证控制模块完成一系列动作-------//
//--------------------------------------------------//	
	//
	reg right_reg;
	reg left_reg;
	reg rotate_reg;
	reg down_reg;
	reg start_reg;
	
	reg right_reg_2;
	reg left_reg_2;
	reg rotate_reg_2;
	reg down_reg_2;
	
	
	reg right_reg_3;
	reg left_reg_3;
	reg rotate_reg_3;
	reg down_reg_3;
	always@(posedge clk,negedge rst_n)
	begin 
	if(!rst_n)
	begin
		start_reg<=0;
		right_reg<=0;
		left_reg<=0;
		rotate_reg<=0;
		down_reg<=0;
	end
	else
	begin
		start_reg<=start;
		right_reg<=right;
		left_reg<=left;
		rotate_reg<=rotate;
		down_reg<=down;
	end
	end
	always@(posedge clk,negedge rst_n)
	begin 
	if(!rst_n)
	begin
		right_reg_2<=0;
		left_reg_2<=0;
		rotate_reg_2<=0;
		down_reg_2<=0;
	end
	else
	begin
		right_reg_2<=right_reg;
		left_reg_2<=left_reg;
		rotate_reg_2<=rotate_reg;
		down_reg_2<=down_reg;
	end
	end
	always@(posedge clk,negedge rst_n)
	begin 
	if(!rst_n)
	begin
		right_reg_3<=0;
		left_reg_3<=0;
		rotate_reg_3<=0;
		down_reg_3<=0;
	end
	else
	begin
		right_reg_3<=right_reg_2;
		left_reg_3<=left_reg_2;
		rotate_reg_3<=rotate_reg_2;
		down_reg_3<=down_reg_2;
	end
	end
	
//--------------------------------------------------//
//--------------------状态更新-----------------------//
//--------------------------------------------------//
	
	//
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
		state<=s_idle;
	else state<=next_state;
	end

	always@(*)
	begin
	if(!rst_n)
		next_state=s_idle;
	else 
	begin
		next_state=s_idle;
		be_idle=0;
		gen_new=0;
		hold=0;
		check_down=0;
		check_move=0;
		check_die=0;
		shift=0;
		fix_block=0;
		clr_row=0;
		game_over=0;
		case(state)
		s_idle:
			begin
			be_idle=1;
			if(start==1&&start_reg==0)
			begin
				next_state=s_gen_new;
			end
			else 
			begin 
				next_state=s_idle;
			end
			end
		s_gen_new:
			begin
			gen_new=1;
			if(gen_new_over==1)
				next_state=s_hold;
			else next_state=s_gen_new;
			end
		s_hold:
		begin
			hold=1;
//			if((down==1&&down_reg==0)||(cnt_down1==go_down1&&grade_cnt==0)||(cnt_down2==go_down2&&grade_cnt==1))
			if((down==1&&down_reg==0)||(cnt_down1==go_down1)||(cnt_down2==go_down2))
			begin
				next_state=s_check_down;
			end
			else if((right==1)||(left==1)||(rotate==1&&rotate_reg==0))
			begin
				next_state=s_check_move;
			end	
			else next_state=s_hold;
		end
		s_check_down:
			begin
			check_down=1;
			if(check_down_over==0)
				begin
					next_state=s_check_down;
				end
			else if(can_down==1)
				begin
					next_state=s_shift;
				end
			else 
				begin next_state=s_fix_block;end
			end
		s_check_move:
			begin
			check_move=1;
			if(check_move_over==0)
			begin
				next_state=s_check_move;
			end
			else if(can_move==1)
				begin
					next_state=s_shift;
				end
			else begin next_state=s_hold; end
			end
		s_shift:
			begin
			shift=1;
			if(shift_over==1)
				begin
				next_state=s_hold;
				end
			else next_state=s_shift;
			end
		s_fix_block:
			begin
			fix_block=1;
			if(fix_over==0)
			begin
				next_state=s_fix_block;
			end
			else begin next_state=s_clr_row;end
			end
		s_clr_row:
			begin
			clr_row=1;
			if(clr_over==1)
				begin
				next_state=s_check_die;
				end
			else begin next_state=s_clr_row; end
			end
		s_check_die:
			begin
			check_die=1;
			if(check_die_over==0)
				begin
				next_state=s_check_die;
				end
			else if(isdie==1)
				begin
				next_state=s_game_over;
				end
			else begin next_state=s_gen_new;end
			end
		s_game_over:
			begin
			game_over=1;
			next_state=s_idle;
			end
		default:begin next_state=s_idle;end
		endcase
	end
	end

	
//--------------------------------------------------//
//----------------自然下落信号的产生与延时--------------//
//--------------------------------------------------//	
	//
	reg native_down;
	reg [9:0]cnt_down1;
	reg [9:0]cnt_down2;
	parameter go_down1=10'd1000;
	parameter go_down2=10'd500;

	
	reg native_down_reg2;
	reg native_down_reg_1;
	reg native_down_reg_2;

	
	always@(posedge clk)
		begin
		if(!rst_n)
			native_down_reg2<=0;
		else native_down_reg2<=native_down_reg_1|native_down_reg_2;//native_down delay one clock ,native_down_reg ;
	end
	
	always@(posedge clk,negedge rst_n)
		begin
			if(!rst_n)
				native_down<=0;
			else native_down<=native_down_reg2;//native_down delay one clock ,native_down_reg ;
	end

	
//--------------------------------------------------//
//--将右移/左移/旋转/下落的动作信息打包传给datapath模块----//
//--------------------------------------------------//	
	//
	assign action={right_reg_3|right_reg_2|right_reg|right,left_reg_3|left_reg_2|left_reg|left,rotate_reg_3|rotate_reg_2|rotate_reg|rotate,down_reg_3|down_reg_2|down_reg|native_down|native_down_reg_1|native_down_reg_2};
endmodule
