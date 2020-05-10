module control(
input clk,
input rst_n,
input start,
input right,
input left,
input down,
input rotate,

input can_move,
input can_down,
input clr_over,
input isdie,

output reg [3:0]action,
output reg gen_new,
output reg hold,
output reg check_move,
output reg check_down,
output reg shift,
output reg fix_block,
output reg clr_row,
output reg check_die,
output reg game_over,

output reg native_down
);

parameter s_idle=4'd0,
			s_gen_new=4'd1,
			s_hold=4'd2,
			s_check_move=4'd3,
			s_check_down=4'd4,
			s_shift=4'd5,
			s_fix_block=4'd6,
			s_clr_row=4'd7,
			s_check_die=4'd8,
			s_game_over=4'd9;
reg [3:0]next_state;
reg [3:0]state;

//reg hold;
 
reg right_reg;
reg left_reg;
reg rotate_reg;
reg down_reg;
reg right_reg_2;
reg left_reg_2;
reg rotate_reg_2;
reg down_reg_2;
reg start_reg;
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
		next_state=s_hold;
		end
	s_hold:
	begin
		hold=1;
		//if((down==1&&down_reg==0)||cnt_down==go_down)
		if((down==1)||cnt_down==go_down)
		begin
			next_state=s_check_down;
		end
		else if((right==1)||(left==1)||(rotate==1))
		begin
			next_state=s_check_move;
		end
		else next_state=s_hold;
	end
	s_check_down:
		begin
		check_down=1;
		if(can_down==1)
		begin
			next_state=s_shift;
		end
		else 
		begin next_state=s_fix_block;end
		end
	s_check_move:
		begin
		check_move=1;
		if(can_move==1)
			begin
			next_state=s_shift;
			end
		else begin next_state=s_hold; end
		end
	s_shift:
		begin
		shift=1;
		next_state=s_hold;
		end
	s_fix_block:
		begin
		fix_block=1;
		next_state=s_clr_row;
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
		if(isdie==1)
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

//reg native_down;
reg [9:0]cnt_down;
parameter go_down=10'd1000;
always@(posedge clk,negedge rst_n)
begin
if(!rst_n)
	cnt_down<=0;
else if(hold==1&&cnt_down!=go_down)
		begin
			cnt_down<=cnt_down+1;
		end
else if(check_down==1)//
		begin
			cnt_down<=0;
		end
else cnt_down<=cnt_down;
end

reg native_down_reg;
always@(posedge clk,negedge rst_n)
begin
if(!rst_n)
begin
	native_down_reg<=0;
end
else if(cnt_down==go_down)
begin
	native_down_reg<=1;
end
else native_down_reg<=0;
end

always@(posedge clk)
begin
if(!rst_n)
	native_down<=0;
else native_down<=native_down_reg;//native_down delay one clock ,native_down_reg ;
//cnt_down==go_down,这一时钟周期，结束时，cnt_down保持不变，转到check_down,
//由于状态机对所有输入敏感，所有在一个周期之内，next_state可变化，若can_down为1,下一个周期便shift==1，此时cnt_down==0了，但此时正好native_down延迟了一个周期，还是1.
end
//需要使得在check_move/check_down以及shift状态都保持action特定位的高电平。
always@(posedge clk)
begin
	action={right_reg_2|right_reg,left_reg_2|left_reg,rotate_reg_2|rotate_reg,down_reg_2|down_reg|native_down|native_down_reg};
end
endmodule
