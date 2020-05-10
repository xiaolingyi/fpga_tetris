module datapath(
	//输入信号
	input clk,
	input rst_n,
	
	input [3:0]action,
	input gen_new,
	input check_down,
	input check_move,
	input shift,
	input fix_block,
	input clr_row,
	input check_die,
	input game_over,
	input be_idle,
	//	输出信号
	output [ROW*COL-1:0]Background1,
	
	output reg gen_new_over,
	output reg check_down_over,
	output reg check_move_over,
	output reg shift_over,
	output reg fix_over,
	output reg clr_over,
	output reg check_die_over,
	
	output reg can_down,
	output reg can_move,
	output reg isdie,
	
	output [4:0]next_block,
	output [9:0]score_out
);
	reg [9:0]score;
	assign score_out=score;


//--------------------------------------------------//
//----------------------方块类型定义------------------//
//--------------------------------------------------//

parameter ROW = 10,
			COL = 8,
			Column=8,
			A_1=5'd0,
			B_1=5'd1,
			B_2=5'd2,
			B_3=5'd3,
			B_4=5'd4,
			C_1=5'd5,
			C_2=5'd6,
			C_3=5'd7,
			C_4=5'd8,
			D_1=5'd9,
			D_2=5'd10,
			E_1=5'd11,
			E_2=5'd12,
			E_3=5'd13,
			E_4=5'd14,
			F_1=5'd15,
			F_2=5'd16,
			G_1=5'd17,
			G_2=5'd18;
			
//--------------------------------------------------//
//--------------------背景矩阵10*8--------------------//
//--------------------------------------------------//
//--------------------------------------------------//
					
assign Background1[7:0]=Background[0]|active_background[0];
assign Background1[15:8]=Background[1]|active_background[1];
assign Background1[23:16]=Background[2]|active_background[2];
assign Background1[31:24]=Background[3]|active_background[3];
assign Background1[39:32]=Background[4]|active_background[4];
assign Background1[47:40]=Background[5]|active_background[5];
assign Background1[55:48]=Background[6]|active_background[6];
assign Background1[63:56]=Background[7]|active_background[7];
assign Background1[71:64]=Background[8]|active_background[8];
assign Background1[79:72]=Background[9]|active_background[9];


//--------------------------------------------------//
//----------------------新方块产生------------------//
//--------------------------------------------------//	
	
	reg [9:0] num;
	reg [3:0] seed;
	reg [3:0] r_num;
	initial 
	begin
	seed = 4'd8;
	num = seed;
	end
//每一个时钟周期都产生一个新的随机数
always @ (posedge clk ,negedge rst_n)
begin
if(!rst_n)
	num <= seed;
else
	begin
		num[0] <= num[8];
		num[1] <= num[0]; 
		num[2] <= num[1]; 
		num[3] <= num[2]^num[9]; 
		num[4] <= num[3]; 
		num[5] <= num[4]^num[9]; 
		num[6] <= num[5]^num[9]; 
		num[7] <= num[6]; 
		num[8] <= num[7]^num[9];
		num[9] <= num[8];
	end	
end
always @ (posedge clk,negedge rst_n)
begin
if(!rst_n)	
	new_block<=A_1;
else begin
	r_num<=num[3:0];
		case(r_num)
			0:new_block<=A_1;
			1:new_block<=B_1;
			2:new_block<=F_2;
			3:new_block<=B_3;
			4:new_block<=B_4;
			5:new_block<=C_1;
			6:new_block<=G_1;
			7:new_block<=C_3;
			8:new_block<=C_4;
			9:new_block<=F_1;
			10:new_block<=D_2;
			11:new_block<=E_1;
			12:new_block<=G_2;
			13:new_block<=E_3;
			14:new_block<=E_4;
			15:new_block<=F_1;
			//16:new_block<=F_2;
			//17:new_block<=G_1;
			//18:new_block<=G_2;
		endcase
		end
end

	reg [4:0] block;
	reg [4:0] new_block;
	reg [4:0]store_new_block;

//--------------------------------------------------//
//--------------------存储新方块---------------------//
//--------------------------------------------------//	
//-------------------------------------------------//

	assign next_block=next_block_r;
	reg [4:0] next_block_r;
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
	next_block_r<=A_1;
	else next_block_r<=store_new_block;
	end


//--------------------------------------------------//
//-----------活动方块的各个动作，左移/右移/旋转/下落----//
//--------------------------------------------------//	


	reg [4:0] R;
	reg [4:0] C;
	always@(posedge clk,negedge rst_n)	
	begin	
	if(!rst_n) begin	
		block<=A_1;
		R<=0;
		C<=0;
		end
	else if(gen_new)	
		begin 		
		block=store_new_block;
		store_new_block=new_block;
		R<=4'b0000;
		C<=3;
		gen_new_over=1;
		end	
	//else 
	else 
			begin
			gen_new_over=0;
			if(shift==1)
				begin
					if(action[3]==1)
						begin
						C<=C+1'b1;
						end
					else if(action[2]==1)
								begin
								C<=C-1'b1;
								end
					else  if(action[1]==1)
								case(block)
									A_1:block=A_1;
									B_1:block=B_2;
									B_2:block=B_3;
									B_3:block=B_4;
									B_4:block=B_1;
									C_1:block=C_2;
									C_2:block=C_3;
									C_3:block=C_4;
									C_4:block=C_1;
									D_1:block=D_2;
									D_2:block=D_1;
									E_1:block=E_2;
									E_2:block=E_3;
									E_3:block=E_4;
									E_4:block=E_1;
									F_1:block=F_2;
									F_2:block=F_1;
									G_1:block=G_2;
									G_2:block=G_1;
								endcase
					else if(action[0]==1)
								begin
									R<=R+1'b1;
								end
							else 	begin
									block=block;
									C<=C;
									R<=R;
									end
					shift_over=1;		
				end
			else 
					begin
						shift_over=0;
						block<=block;
						C<=C;
						R<=R;	
					end
		end
	end	

	

//--------------------------------------------------//
//-----------------判断能否左移/右移/旋转/下落----------//
//--------------------------------------------------//

	reg be_right;
	reg be_left;
	reg be_rotate;
	reg be_down;
	reg en_result;
	reg down_en;
	always@(posedge clk,negedge rst_n)		
	begin
	if(!rst_n)
		begin
			can_down=0;
			can_move=0;
		end
	else if(check_down|check_move)
	begin
		be_right=action[3];
		be_left=action[2];
		be_rotate=action[1];
		be_down=action[0];	
		case(block)
			A_1:case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+2]==0&&Background[R+1][C+2]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0100:if(1<=C) begin if(Background[R][C-1]==0&&Background[R+1][C-1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
						//旋转与否不相关
			4'b0010:en_result=1;
			4'b0001:if(R<=ROW-3)begin if(Background[R+2][C]==0&&Background[R+2][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end		
			endcase
		B_1:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R-1][C+1]==0&&Background[R][C+1]==0&&Background[R+1][C+2]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(1<=C) begin if(Background[R-1][C-1]==0&&Background[R][C-1]==0&&Background[R+1][C-1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(1<=C<=Column-1) begin if(Background[R][C-1]==0&&Background[R][C+1]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0001:if(R<=ROW-3)begin if(Background[R+2][C]==0&&Background[R+2][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		B_2:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R-1][C+3]==0&&Background[R][C+3]==0)
							en_result=1;else en_result=0; end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R-1][C]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R-1][C-1]==0&&Background[R-1][C]==0&&Background[R+1][C]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-2) begin if(Background[R+1][C-1]==0&&Background[R+1][C]==0&&Background[R+1][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
		//default:begin en_result=0;down_en=0;end			
			endcase
		B_3:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-2) begin if(Background[R-1][C+1]==0&&Background[R][C+1]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R-1][C-2]==0&&Background[R][C-1]==0&&Background[R+1][C-1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(C<=Column-2) begin if(Background[R][C-1]==0&&Background[R][C+1]==0&&Background[R+1][C-1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+2][C]==0&&Background[R][C-1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		B_4:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+2]==0&&Background[R+1][C]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-1]==0&&Background[R+1][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R+1][C]==0&&Background[R+1][C+1]==0&&Background[R-1][C]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+2][C-1]==0&&Background[R+1][C]==0&&Background[R+1][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		C_1:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-2) begin if(Background[R-1][C+1]==0&&Background[R][C+1]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C)begin  if(Background[R-1][C-1]==0&&Background[R][C-1]==0&&Background[R+1][C-2]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(C<=Column-2) begin  if(Background[R][C-1]==0&&Background[R][C+1]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end 
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+2][C-1]==0&&Background[R+2][C]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		C_2:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+2]==0&&Background[R+1][C+2]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R+1][C]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R+1][C]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+1][C-1]==0&&Background[R+1][C]==0&&Background[R+2][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		C_3:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+1]==0&&Background[R+1][C+1]==0&&Background[R-1][C+2]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(1<=C) begin if(Background[R-1][C-1]==0&&Background[R+1][C-1]==0&&Background[R][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(1<=C) begin if(Background[R-1][C-1]==0&&Background[R][C-1]==0&&Background[R][C+1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+2][C]==0&&Background[R][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		C_4:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R-1][C]==0&&Background[R][C+2]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R-1][C-2]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R-1][C-1]==0&&Background[R-1][C]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-2) begin if(Background[R+1][C-1]==0&&Background[R+1][C]==0&&Background[R+1][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		D_1:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-2) begin if(Background[R-1][C+1]==0&&Background[R][C+1]==0&&Background[R+1][C+1]==0&&Background[R+2][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(1<=C) begin if(Background[R-1][C-1]==0&&Background[R][C-1]==0&&Background[R+1][C-1]==0&&Background[R+2][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(1<=C&&C<=Column-3) begin if(Background[R][C-1]==0&&Background[R][C+1]==0&&Background[R][C+2]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0001:if(R<=ROW-4) begin if(Background[R+3][C]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		D_2:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-4) begin if(Background[R][C+3]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R-2][C]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R-1][C]==0&&Background[R+1][C]==0&&Background[R+2][C]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-2) begin if(Background[R+1][C-1]==0&&Background[R+1][C]==0&&Background[R+1][C+1]==0&&Background[R+1][C+2]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		E_1:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+2]==0&&Background[R-1][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R-1][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R-1][C]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-2) begin if(Background[R+1][C-1]==0&&Background[R+1][C]==0&&Background[R+1][C+1]==0)
							down_en=1;else down_en=0;end
						else down_en=0;	
			//default:begin en_result=0;down_en=0;end		
			endcase
		E_2:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-2) begin if(Background[R-1][C+1]==0&&Background[R][C+1]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R-1][C-1]==0&&Background[R][C-2]==0&&Background[R+1][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(C<=Column-1&&Background[R][C+1]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+1][C-1]==0&&Background[R+2][C]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end			
			endcase
		E_3:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+2]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R+1][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:
							en_result=1;
						
			4'b0001:if(R<=ROW-3) begin if(Background[R+1][C+1]==0&&Background[R+1][C-1]==0&&Background[R+2][C]==0)
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end					
			endcase
		E_4:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R-1][C+1]==0&&Background[R][C+2]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(1<=C) begin if(Background[R][C-1]==0&&Background[R][C-1]==0&&Background[R+1][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(1<=C) begin if(Background[R][C-1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+2][C]==0&&Background[R+1][C+1]==0)//止。。。。。。。
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end					
			endcase
		F_1:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-2) begin if(Background[R-1][C+1]==0&&Background[R][C+1]==0&&Background[R+1][C]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R-1][C-2]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(C<=Column-2) begin if(Background[R+1][C]==0&&Background[R+1][C+1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+2][C-1]==0&&Background[R+1][C]==0)//止。。。。。。。
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end					
			endcase
		F_2:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+1]==0&&Background[R+1][C+2]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R+1][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R+1][C-1]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+2][C]==0&&Background[R+1][C-1]==0&&Background[R+2][C+1]==0)//止。。。。。。。
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end					
			endcase
		G_1:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R][C+2]==0&&Background[R+1][C+2]==0&&Background[R-1][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(1<=C) begin if(Background[R][C-1]==0&&Background[R-1][C-1]==0&&Background[R+1][C]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(1<=C) begin if(Background[R][C-1]==0&&Background[R-1][C+1]==0)
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0001:if(R<=ROW-3) begin if(Background[R+1][C]==0&&Background[R+2][C+1]==0)//止。。。。。。。
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end					
			endcase
		G_2:
			case({be_right,be_left,be_rotate,be_down})
			4'b1000:if(C<=Column-3) begin if(Background[R-1][C+2]==0&&Background[R][C+1]==0)
							en_result=1;else en_result=0;end
							else en_result=0;
			4'b0100:if(2<=C) begin if(Background[R][C-2]==0&&Background[R-1][C-1]==0)//止。。。。。。。
							en_result=1;else en_result=0;end
						else en_result=0;
			4'b0010:if(Background[R][C+1]==0&&Background[R+1][C+1]==0)
							en_result=1;
						else en_result=0;
			4'b0001:if(R<=ROW-2) begin if(Background[R+1][C]==0&&Background[R+1][C-1]==0&&Background[R][C+1]==0)//止。。。。。。。
							down_en=1;else down_en=0;end
						else down_en=0;
			//default:begin en_result=0;down_en=0;end					
			endcase
		endcase
		can_down=down_en;
		can_move=en_result;
		if(check_down)
			check_down_over=1;
		else if(check_move)
			check_move_over=1;
		else begin
					check_down_over=0;
					check_move_over=0;
				end
	end
	else 	begin
		can_down=0;
		can_move=0;
		check_down_over=0;
		check_move_over=0;
			end
	end
	

//--------------------------------------------------//
//---------------------背景矩阵的产生------------------//
//--------------------------------------------------//

reg [COL-1:0]Background[ROW-1:0];
task clr_Background;
		for(i=0;i<=ROW-1'b1;i=i+1'b1)
		begin
				Background[i]=0;
		end
endtask
reg [4:0]i;
always@(posedge clk,negedge rst_n)
begin
if(!rst_n)
begin
	clr_Background;
end
else if(game_over==1||be_idle==1)
begin
		score=0;
		clr_Background;
end
else if(fix_block==1)//固定方块
	begin
			case(block)
				A_1:
				begin
					Background[R][C]=1;
					Background[R][C+1]=1;
					Background[R+1][C]=1;
					Background[R+1][C+1]=1;
				end
				B_1:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R+1][C]=1;
					Background[R+1][C+1]=1;				
				end
				B_2:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R][C+1]=1;
					Background[R-1][C+1]=1;
				end
				B_3:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R-1][C-1]=1;
					Background[R+1][C]=1;
				end
				B_4:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R][C+1]=1;
					Background[R+1][C-1]=1;
				end
				C_1:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R+1][C]=1;
					Background[R+1][C-1]=1;
				end
				C_2:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R][C+1]=1;
					Background[R+1][C+1]=1;
				end
				
				C_3:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R+1][C]=1;
					Background[R-1][C+1]=1;
				end
				C_4:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R][C+1]=1;
					Background[R-1][C-1]=1;
				end
				D_1:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R+1][C]=1;
					Background[R+2][C]=1;
				end
				D_2:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R][C+1]=1;
					Background[R][C+2]=1;
				end
				E_1:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R][C+1]=1;
					Background[R-1][C]=1;
				end
				E_2:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R+1][C]=1;
					Background[R][C-1]=1;
				end
				E_3:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R][C+1]=1;
					Background[R+1][C]=1;
				end
				E_4:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R+1][C]=1;
					Background[R][C+1]=1;
				end
				F_1:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R-1][C]=1;
					Background[R+1][C-1]=1;
				end
				F_2:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R+1][C]=1;
					Background[R+1][C+1]=1;
				end
				G_1:
				begin
					Background[R][C]=1;
					Background[R-1][C]=1;
					Background[R][C+1]=1;
					Background[R+1][C+1]=1;
				end
				G_2:
				begin
					Background[R][C]=1;
					Background[R][C-1]=1;
					Background[R-1][C]=1;
					Background[R-1][C+1]=1;
				end
			endcase
			fix_over=1;
		end
else 
	begin
		fix_over=0;
		if(clr_row==1) //清除满行
				begin
				case(row_full)
				4'b0000:begin end
				4'b0001:	begin
							score=score+1;
							for(i=ROW-1'b1;i>1;i=i-1'b1)
								begin
								if(i<=R-1)
									Background[i]=Background[i-1];
								end
							end
				4'b0010:	begin
							score=score+1;
							for(i=ROW-1'b1;i>1;i=i-1'b1)
								begin
								if(i<=R)
									Background[i]=Background[i-1];
								end
							end
				4'b0011:	begin
							score=score+2;
							for(i=ROW-1'b1;i>2;i=i-1'b1)
								begin
								if(i<=R)
									Background[i]=Background[i-2];
								end			
							end
				4'b0100:	begin
							score=score+1;
							for(i=ROW-1'b1;i>1;i=i-1'b1)
								begin
								if(i<=R+1)
									Background[i]=Background[i-1];
								end
							end
				4'b0101:	begin
							score=score+2;
							Background[R+1]=Background[R];
							for(i=ROW-1'b1;i>2;i=i-1'b1)
								begin
								if(i<=R)
									Background[i]=Background[i-2];
								end
							end
				4'b0110:	begin
							score=score+2;
							for(i=ROW-1'b1;i>2;i=i-1'b1)
								begin
								if(i<=R+1)
									Background[i]=Background[i-2];
								end
							end
				4'b0111:	begin
							score=score+3;
							for(i=ROW-1'b1;i>3;i=i-1'b1)
								begin
								if(i<=R+1)
									Background[i]=Background[i-3];
								end				
							end
				4'b1000:	begin
							score=score+1;
							for(i=ROW-1'b1;i>1;i=i-1'b1)
								begin
								if(i<=R+2)
									Background[i]=Background[i-1];
								end						
							end
				4'b1001:	begin
							score=score+2;
							Background[R+2]=Background[R+1];
							Background[R+1]=Background[R];
							for(i=ROW-1'b1;i>2;i=i-1'b1)
								begin
								if(i<=R)
									Background[i]=Background[i-2];
								end				
							end
				4'b1010:	begin
							score=score+2;
							Background[R+2]=Background[R+1];
							for(i=ROW-1'b1;i>2;i=i-1'b1)
								begin
								if(i<=R+1)
									Background[i]=Background[i-2];
								end			
							end
				4'b1011:	begin
							score=score+3;
							Background[R+2]=Background[R+1];
							for(i=ROW-1'b1;i>3;i=i-1'b1)
								begin
								if(i<=R+1)
									Background[i]=Background[i-3];
								end				
							end
				4'b1100:	begin
							score=score+2;
							for(i=ROW-1'b1;i>2;i=i-1'b1)
								begin
								if(i<=R+2)
									Background[i]=Background[i-2];
								end				
							end
				4'b1101:	begin
						score=score+3;
							Background[R+2]=Background[R];
							for(i=ROW-1'b1;i>3;i=i-1'b1)
								begin
								if(i<=R+1)
									Background[i]=Background[i-3];
								end				
							end
				4'b1110:	begin
							score=score+3;
							for(i=ROW-1'b1;i>3;i=i-1'b1)
								begin
								if(i<=R+2)
									Background[i]=Background[i-3];
								end					
							end
				4'b1111:	begin
							score=score+4;
							for(i=ROW-1'b1;i>4;i=i-1'b1)
								begin
								if(i<=R+2)
									Background[i]=Background[i-4];
								end				
							end
				endcase
				clr_over=1;
			end
			else 
				begin 
				clr_over=0;
				end
		end
end	



//--------------------------------------------------//
//--------------------记录相关行是否满行----------------//
//--------------------------------------------------//

	wire [3:0]row_full;
	assign row_full[3]=(R<=ROW-3)?(&Background[R+2]):0;
	assign row_full[2]=(R<=ROW-2)?(&Background[R+1]):0;
	assign 	row_full[1]=&Background[R];
	assign 	row_full[0]=&Background[R-1];

	

//--------------------------------------------------//
//-----------------------活动方块的产生-----------------//
//--------------------------------------------------//

	reg [COL-1:0]active_background[ROW-1:0];
	reg [3:0]j;
	
	task clr_active_background;
	for(j=0;j<ROW;j=j+1'b1)
				active_background[j]=0;
	endtask
	
	always@(posedge clk,negedge rst_n)
	begin
	if(!rst_n)
		clr_active_background;
	else if(be_idle==1)
		begin
			clr_active_background;
		end
	else 
		begin
			clr_active_background;
			if((game_over!=1))
			begin
				case(block)
					A_1:
						begin
						active_background[R][C]=1;
						active_background[R][C+1]=1;
						active_background[R+1][C]=1;
						active_background[R+1][C+1]=1;
						end
					B_1:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R+1][C]=1;
						active_background[R+1][C+1]=1;
						active_background[R+1][C+1]=1;
						end
					B_2:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R][C+1]=1;
						active_background[R-1][C+1]=1;
						end
					B_3:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R-1][C-1]=1;
						active_background[R+1][C]=1;
						end
					B_4:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R][C+1]=1;
						active_background[R+1][C-1]=1;
						end
					C_1:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R+1][C]=1;
						active_background[R+1][C-1]=1;
						end
					C_2:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R][C+1]=1;
						active_background[R+1][C+1]=1;
						end
					C_3:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R+1][C]=1;
						active_background[R-1][C+1]=1;
						end
					C_4:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R][C+1]=1;
						active_background[R-1][C-1]=1;
						end
					D_1:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R+1][C]=1;
						active_background[R+2][C]=1;
						end
					D_2:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R][C+1]=1;
						active_background[R][C+2]=1;
						end
					E_1:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R][C+1]=1;
						active_background[R-1][C]=1;
						end
					E_2:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R+1][C]=1;
						active_background[R][C-1]=1;
						end
					E_3:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R][C+1]=1;
						active_background[R+1][C]=1;
						end
					E_4:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R+1][C]=1;
						active_background[R][C+1]=1;
						end
					F_1:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R-1][C]=1;
						active_background[R+1][C-1]=1;
						end
					F_2:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R+1][C]=1;
						active_background[R+1][C+1]=1;
						end
					G_1:
						begin
						active_background[R][C]=1;
						active_background[R-1][C]=1;
						active_background[R][C+1]=1;
						active_background[R+1][C+1]=1;
						end
					G_2:
						begin
						active_background[R][C]=1;
						active_background[R][C-1]=1;
						active_background[R-1][C]=1;
						active_background[R-1][C+1]=1;
						end
				endcase
			end
		else 
			begin
				clr_active_background;
			end
		end
	end
	

//--------------------------------------------------//
//-------------------判断游戏是否结束-------------------//
//--------------------------------------------------//

	always@(posedge clk)
	begin
		if(check_die==1)
			begin
			if((|Background[0])!=0)
				isdie=1;
			else 
			begin isdie=0;end
			check_die_over=1;
			end
		else begin isdie=0;check_die_over=0;end
	end

	
endmodule