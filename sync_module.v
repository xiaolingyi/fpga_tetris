module sync_module(
	clk_50M,rstn,
	Background1,lcd_dclk,lcd_vsync,lcd_hsync,lcd_b,lcd_r,lcd_g,lcd_de,
	score,
	new_block
);
	input clk_50M;
	input [ROW*COL-1:0]Background1;
	input [9:0]score;
	input [4:0]new_block;
	output lcd_dclk;
	input rstn;
	output lcd_hsync;
	output lcd_vsync;
	output [7:0] lcd_r;
	output [7:0] lcd_g;
	output [7:0] lcd_b;
	output lcd_de;

parameter 
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
			
	wire [COL-1:0]Background[ROW-1:0];
	parameter ROW=10,COL=8;
	integer i;
	
//--------------------背景矩阵10*8--------------------//

	assign Background[0]=Background1[7:0];
	assign Background[1]=Background1[15:8];
	assign Background[2]=Background1[23:16];
	assign Background[3]=Background1[31:24];
	assign Background[4]=Background1[39:32];
	assign Background[5]=Background1[47:40];
	assign Background[6]=Background1[55:48];
	assign Background[7]=Background1[63:56];
	assign Background[8]=Background1[71:64];
	assign Background[9]=Background1[79:72];

	
//------------------显示下一个方块类型模块--------------//

	reg [3:0]next_block[3:0];
	wire R;
	wire C;
	assign R=1;
	assign C=1;
	always @(posedge lcd_clk)
	begin
	if(!rstn)
		for(i=0;i<4;i=i+1)
			next_block[i]=0;
	else begin
			for(i=0;i<4;i=i+1)
			next_block[i]=0;
					case(new_block)
						A_1:
						begin
						next_block[R][C]=1;
						next_block[R][C+1]=1;
						next_block[R+1][C]=1;
						next_block[R+1][C+1]=1;
						end
						B_1:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R+1][C]=1;
						next_block[R+1][C+1]=1;
						end
						B_2:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R][C+1]=1;
						next_block[R-1][C+1]=1;
						end
						B_3:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R-1][C-1]=1;
						next_block[R+1][C]=1;
						end
						B_4:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R][C+1]=1;
						next_block[R+1][C-1]=1;
						end
						C_1:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R+1][C]=1;
						next_block[R+1][C-1]=1;
						end
						C_2:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R][C+1]=1;
						next_block[R+1][C+1]=1;
						end
						C_3:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R+1][C]=1;
						next_block[R-1][C+1]=1;
						end
						C_4:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R][C+1]=1;
						next_block[R-1][C-1]=1;
						end
						D_1:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R+1][C]=1;
						next_block[R+2][C]=1;
						end
						D_2:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R][C+1]=1;
						next_block[R][C+2]=1;
						end
						E_1:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R][C+1]=1;
						next_block[R-1][C]=1;
						end
						E_2:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R+1][C]=1;
						next_block[R][C-1]=1;
						end
						E_3:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R][C+1]=1;
						next_block[R+1][C]=1;
						end
						E_4:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R+1][C]=1;
						next_block[R][C+1]=1;
						end
						F_1:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R-1][C]=1;
						next_block[R+1][C-1]=1;
						end
						F_2:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R+1][C]=1;
						next_block[R+1][C+1]=1;
						end
						G_1:
						begin
						next_block[R][C]=1;
						next_block[R-1][C]=1;
						next_block[R][C+1]=1;
						next_block[R+1][C+1]=1;
						end
						G_2:
						begin
						next_block[R][C]=1;
						next_block[R][C-1]=1;
						next_block[R-1][C]=1;
						next_block[R-1][C+1]=1;
						end
	endcase
	end
	end

		parameter grid_width=27;
	//-----------------------------------------------------------// 
	// 水平扫描参数的设定480*272 60Hz LCD 
	//-----------------------------------------------------------// 
		parameter LinePeriod =525; 
		//行周期数
		parameter H_SyncPulse=41; 
		//行同步脉冲（Sync a）
		parameter H_BackPorch=2; 
		//显示后沿（Back porch b）
		parameter H_ActivePix=480;
		 //显示时序段（Display interval c） p
		parameter H_FrontPorch=2; 
		 
		parameter Hde_start=43;
		parameter Hde_end=523;
	 
	//-----------------------------------------------------------// 
	// 垂直扫描参数的设定480*272 60Hz LCD 
	//-----------------------------------------------------------// 
		parameter FramePeriod =286; 
		//列周期数
		parameter V_SyncPulse=10; 
		 //列同步脉冲（Sync o） 
		parameter V_BackPorch=2; 
		 //显示后沿（Back porch p） 
		parameter V_ActivePix=272; 
		 //显示时序段（Display interval q） 
		parameter V_FrontPorch=2; 
		parameter Vde_start=12;
		parameter Vde_end=284;
	 
		wire lcd_clk;
		reg[10 : 0] x_cnt;
		reg[9 : 0] y_cnt;
		reg[7 : 0] lcd_r_reg;
		reg[7 : 0] lcd_g_reg;
		reg[7 : 0] lcd_b_reg;
		reg hsync_r; 
		reg vsync_r;
		reg hsync_de; 
		reg vsync_de;
		assign lcd_dclk=~lcd_clk;
		assign lcd_hsync = hsync_r; 
		assign lcd_vsync = vsync_r;
		assign lcd_de = hsync_de & vsync_de; 
		assign lcd_r_s = (hsync_de & vsync_de)?lcd_r_reg:8'b00000000;
		assign lcd_g_s = (hsync_de & vsync_de)?lcd_g_reg:8'b00000000;
		assign lcd_b_s = (hsync_de & vsync_de)?lcd_b_reg:8'b00000000;
		
//---------------------------------------------------------------- //
////
// 水平扫描计数 
//---------------------------------------------------------------- //
	always @ (posedge lcd_clk) 
	begin
	if(~rstn) x_cnt <= 1; 
	else if(x_cnt == LinePeriod) x_cnt <= 1; 
	else x_cnt <= x_cnt+ 1'b1;
	end

//----------------------------------------------------------------//
////
// 水平扫描信号hsync产生 
//---------------------------------------------------------------- //
	always@(posedge lcd_clk) 
	begin 
	if(~rstn) hsync_r <= 1'b1; 
	else if(x_cnt == 1) hsync_r <= 1'b0; 
	
	else if(x_cnt == H_SyncPulse) hsync_r <= 1'b1;//产生hsync信号
			
	if(~rstn) hsync_de <= 1'b0; 
	else if(x_cnt == Hde_start) hsync_de <= 1'b1; //产生hsync_de信号 
	else if(x_cnt == Hde_end) hsync_de <= 1'b0;	
	end

//----------------------------------------------------------------// 
////
// 垂直扫描计数 
//----------------------------------------------------------------// 
	always @ (posedge lcd_clk) 
	if(~rstn) y_cnt <= 1; 
	else if(y_cnt == FramePeriod) y_cnt <= 1; 
	else if(x_cnt == LinePeriod) y_cnt <= y_cnt+1'b1; 
//---------------------------------------------------------------- //
///
/// 垂直扫描信号vsync产生 
//----------------------------------------------------------------// 
	always @ (posedge lcd_clk) 
	begin if(~rstn) vsync_r <= 1'b1; 
	else if(y_cnt == 1) vsync_r <= 1'b0; 
	 
	else if(y_cnt == V_SyncPulse) vsync_r <= 1'b1;//产生vsync信号
	if(~rstn) vsync_de <= 1'b0; 
	else if(y_cnt == Vde_start) vsync_de <= 1'b1; //产生vsync_de信号 
	else if(y_cnt == Vde_end) vsync_de <= 1'b0;
	end
	
	//--------------------------------------------------//
	//--------------------显示背景矩阵--------------------//
	//--------------------------------------------------//
	
	reg grid;
	
	always@(posedge lcd_clk)
	begin
	if(x_cnt<=Hde_start+grid_width*0&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*0<=y_cnt&&y_cnt<Vde_start+grid_width*1)
	  grid<=Background[0][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*1<=y_cnt&&y_cnt<Vde_start+grid_width*2)
	  grid<=Background[1][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*2<=y_cnt&&y_cnt<Vde_start+grid_width*3)
	  grid<=Background[2][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*3<=y_cnt&&y_cnt<Vde_start+grid_width*4)
	  grid<=Background[3][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*4<=y_cnt&&y_cnt<Vde_start+grid_width*5)
	  grid<=Background[4][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*5<=y_cnt&&y_cnt<Vde_start+grid_width*6)
	  grid<=Background[5][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*6<=y_cnt&&y_cnt<Vde_start+grid_width*7)
	  grid<=Background[6][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*7<=y_cnt&&y_cnt<Vde_start+grid_width*8)
	  grid<=Background[7][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*8<=y_cnt&&y_cnt<Vde_start+grid_width*9)
	  grid<=Background[8][7];
	else if(x_cnt==Hde_start+grid_width*0&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][0];
	else if(x_cnt==Hde_start+grid_width*1&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][1];
	else if(x_cnt==Hde_start+grid_width*2&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][2];
	else if(x_cnt==Hde_start+grid_width*3&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][3];
	else if(x_cnt==Hde_start+grid_width*4&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][4];
	else if(x_cnt==Hde_start+grid_width*5&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][5];
	else if(x_cnt==Hde_start+grid_width*6&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][6];
	else if(x_cnt==Hde_start+grid_width*7&&Vde_start+grid_width*9<=y_cnt&&y_cnt<Vde_start+grid_width*10)
	  grid<=Background[9][7];
	else next_block_grid;
	end
	
	//--------------------------------------------------//
	//--------------------显示下一个方块------------------//
	//--------------------------------------------------//
	
	parameter x_bais=350,y_bais=185;
	task next_block_grid;
if(x_cnt>=x_bais+grid_width*0&&x_cnt<x_bais+grid_width*1&&y_bais+grid_width*0<=y_cnt&&y_cnt<y_bais+grid_width*1)
  grid<=next_block[0][0];
else if(x_cnt>=x_bais+grid_width*1&&x_cnt<x_bais+grid_width*2&&y_bais+grid_width*0<=y_cnt&&y_cnt<y_bais+grid_width*1)
  grid<=next_block[0][1];
else if(x_cnt>=x_bais+grid_width*2&&x_cnt<x_bais+grid_width*3&&y_bais+grid_width*0<=y_cnt&&y_cnt<y_bais+grid_width*1)
  grid<=next_block[0][2];
else if(x_cnt>=x_bais+grid_width*3&&x_cnt<x_bais+grid_width*4&&y_bais+grid_width*0<=y_cnt&&y_cnt<y_bais+grid_width*1)
  grid<=next_block[0][3];
else if(x_cnt>=x_bais+grid_width*0&&x_cnt<x_bais+grid_width*1&&y_bais+grid_width*1<=y_cnt&&y_cnt<y_bais+grid_width*2)
  grid<=next_block[1][0];
else if(x_cnt>=x_bais+grid_width*1&&x_cnt<x_bais+grid_width*2&&y_bais+grid_width*1<=y_cnt&&y_cnt<y_bais+grid_width*2)
  grid<=next_block[1][1];
else if(x_cnt>=x_bais+grid_width*2&&x_cnt<x_bais+grid_width*3&&y_bais+grid_width*1<=y_cnt&&y_cnt<y_bais+grid_width*2)
  grid<=next_block[1][2];
else if(x_cnt>=x_bais+grid_width*3&&x_cnt<x_bais+grid_width*4&&y_bais+grid_width*1<=y_cnt&&y_cnt<y_bais+grid_width*2)
  grid<=next_block[1][3];
else if(x_cnt>=x_bais+grid_width*0&&x_cnt<x_bais+grid_width*1&&y_bais+grid_width*2<=y_cnt&&y_cnt<y_bais+grid_width*3)
  grid<=next_block[2][0];
else if(x_cnt>=x_bais+grid_width*1&&x_cnt<x_bais+grid_width*2&&y_bais+grid_width*2<=y_cnt&&y_cnt<y_bais+grid_width*3)
  grid<=next_block[2][1];
else if(x_cnt>=x_bais+grid_width*2&&x_cnt<x_bais+grid_width*3&&y_bais+grid_width*2<=y_cnt&&y_cnt<y_bais+grid_width*3)
  grid<=next_block[2][2];
else if(x_cnt>=x_bais+grid_width*3&&x_cnt<x_bais+grid_width*4&&y_bais+grid_width*2<=y_cnt&&y_cnt<y_bais+grid_width*3)
  grid<=next_block[2][3];
else if(x_cnt>=x_bais+grid_width*0&&x_cnt<x_bais+grid_width*1&&y_bais+grid_width*3<=y_cnt&&y_cnt<y_bais+grid_width*4)
  grid<=next_block[3][0];
else if(x_cnt>=x_bais+grid_width*1&&x_cnt<x_bais+grid_width*2&&y_bais+grid_width*3<=y_cnt&&y_cnt<y_bais+grid_width*4)
  grid<=next_block[3][1];
else if(x_cnt>=x_bais+grid_width*2&&x_cnt<x_bais+grid_width*3&&y_bais+grid_width*3<=y_cnt&&y_cnt<y_bais+grid_width*4)
  grid<=next_block[3][2];
else if(x_cnt>=x_bais+grid_width*3&&x_cnt<x_bais+grid_width*4&&y_bais+grid_width*3<=y_cnt&&y_cnt<y_bais+grid_width*4)
  grid<=next_block[3][3];
	else if(x_cnt>x_bais+grid_width*4||y_cnt>=y_bais+grid_width*4||(x_cnt>Hde_start+grid_width*8&&y_cnt<Vde_start+grid_width*10))
		grid<=0;
	endtask
	
	//--------------------------------------------------//
	//--------------------红黄蓝三色输出显示---------------//
	//--------------------------------------------------//
	
	always@(posedge lcd_clk)
	begin
	if(grid)
		begin
		lcd_r_reg<=8'b1111111;
		lcd_b_reg<=8'b0000000;
		lcd_g_reg<=8'b0000000;
		end
	else if(square)
	begin
		lcd_r_reg<=8'b0000000;
		lcd_b_reg<=8'b0000000;
		lcd_g_reg<=8'b1111111;
	end 
	else begin
		lcd_r_reg<=8'b0000000;
		lcd_b_reg<=8'b0000000;
		lcd_g_reg<=8'b0000000;
	end
	end
	
	//--------------------------------------------------//
	//--------------------显示游戏区域方框-----------------//
	//--------------------------------------------------//	
	
		reg square;
		always@(posedge lcd_clk)
		begin
		if(x_cnt==Hde_start+grid_width*(COL)&&y_cnt<=Vde_start+grid_width*(ROW)&&0<=y_cnt)
			square<=1;
		else if(x_cnt<=Hde_start+grid_width*COL&&x_cnt>=0&&y_cnt==Vde_start+grid_width*ROW)
			square<=1;
		else square<=0;
		end

	//--------------------------------------------------//
	//--------------------字符显示位置定义-----------------//
	//--------------------------------------------------//
	
	parameter WITH=16,HIGHT=21;
	parameter WITH_SCORE=24,HIGHT_SCORE=35;
	parameter pos_x=Hde_start+280;
	parameter pos_y=Vde_start+10;
	parameter Pos_X2 = Hde_start+320; 
	parameter Pos_Y2 = Vde_start+10; 
	parameter Pos_X3 = Hde_start+360; 
	parameter Pos_Y3 = Vde_start+10; 
	parameter Pos_X4 = Hde_start+400; 
	parameter Pos_Y4 = Vde_start+10; 
	parameter Pos_X5 = Hde_start+440; 
	parameter Pos_Y5 = Vde_start+10;
	 
	parameter Pos_X6 = Hde_start+300; 
	parameter Pos_Y6 = Vde_start+120; 
	parameter Pos_X7 = Hde_start+340; 
	parameter Pos_Y7 = Vde_start+120; 
	parameter Pos_X8 = Hde_start+380; 
	parameter Pos_Y8 = Vde_start+120; 
	parameter Pos_X9 = Hde_start+420; 
	parameter Pos_Y9 = Vde_start+120; 
	
	parameter score0_x=Hde_start+300;
	parameter score0_y=Vde_start+60;
	parameter score1_x=Hde_start+340;
	parameter score1_y=Vde_start+60;
	parameter score2_x=Hde_start+380;
	parameter score2_y=Vde_start+60;
	parameter score3_x=Hde_start+420;
	parameter score3_y=Vde_start+60;
	
	//--------------------------------------------------//
	//--------------------各位分数大小--------------------//
	//--------------------------------------------------//	
	
	wire [4:0]score0;
	wire [4:0]score1;
	wire [4:0]score2;
	wire [4:0]score3;
	assign score0=score/100;
	assign score1=(score/10)%10;
	assign score2=(score)%10;
	assign score3=0;
	
//---------------------------------------------------------------- //
////// ROM读地址产生模块 
//---------------------------------------------------------------- //
	reg[4:0] x1_count; 
	reg[4:0] x2_count;
	reg[4:0] x3_count; 
	reg[4:0] x4_count;
	reg[4:0] x5_count; 
	reg[4:0] x6_count; 
	reg[4:0] x7_count;
	reg[4:0] x8_count; 
	reg[4:0] x9_count;
	reg[4:0] s0_count; 
	reg[4:0] s1_count;
	reg[4:0] s2_count; 
	reg[4:0] s3_count;
	reg[10:0] word1_rom_addra; 
	reg[10:0] word2_rom_addra; 
	reg[10:0] word3_rom_addra; 
	reg[10:0] word4_rom_addra; 
	reg[10:0] word5_rom_addra;
	reg[10:0] word6_rom_addra; 
	reg[10:0] word7_rom_addra; 
	reg[10:0] word8_rom_addra; 
	reg[10:0] word9_rom_addra;
	reg[10:0] score0_rom_addra; 
	reg[10:0] score1_rom_addra; 
	reg[10:0] score2_rom_addra; 
	reg[10:0] score3_rom_addra;

	//--------------------------------------------------//
	//--------------------各字符显示区域划分---------------//
	//--------------------------------------------------//
	
	wire x_word1;
	wire y_word1; 
	wire x_word2; 
	wire y_word2; 
	wire x_word3; 
	wire y_word3; 
	wire x_word4;
	wire y_word4; 
	wire x_word5; 
	wire y_word5;
	wire x_word6; 
	wire y_word6; 
	wire x_word7; 
	wire y_word7; 
	wire x_word8;
	wire y_word8; 
	wire x_word9; 
	wire y_word9;
	wire x_score0; 
	wire y_score0;
	wire x_score1; 
	wire y_score1; 
	wire x_score2; 
	wire y_score2; 
	wire x_score3;
	wire y_score3; 

	wire pre_x_word1; 
	wire pre_x_word2; 
	wire pre_x_word3;
	wire pre_x_word4; 
	wire pre_x_word5; 
	wire pre_x_word6; 
	wire pre_x_word7;
	wire pre_x_word8; 
	wire pre_x_word9;
	wire pre_x_score0; 
	wire pre_x_score1;
	wire pre_x_score2; 
	wire pre_x_score3;
	
	assign x_word1=(x_cnt >= pos_x && x_cnt < pos_x + WITH) ? 1'b1 : 1'b0; 
	assign y_word1=(y_cnt >= pos_y && y_cnt < pos_y + HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word1=(x_cnt >= pos_x - 2 && x_cnt < pos_x + WITH-2) ? 1'b1 : 1'b0;
	
	assign x_word2=(x_cnt >= Pos_X2 && x_cnt < Pos_X2 + WITH) ? 1'b1 : 1'b0; 
	assign y_word2=(y_cnt >= Pos_Y2 && y_cnt < Pos_Y2 + HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word2=(x_cnt >= Pos_X2 - 2 && x_cnt < Pos_X2 + WITH-2) ? 1'b1 : 1'b0; 
	
	assign x_word3=(x_cnt >= Pos_X3 && x_cnt < Pos_X3 + WITH) ? 1'b1 : 1'b0; 
	assign y_word3=(y_cnt >= Pos_Y3 && y_cnt < Pos_Y3 + HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word3=(x_cnt >= Pos_X3 - 2 && x_cnt < Pos_X3 +WITH-2) ? 1'b1 : 1'b0;
	
	assign x_word4=(x_cnt >= Pos_X4 && x_cnt < Pos_X4 +WITH ) ? 1'b1 : 1'b0; 
	assign y_word4=(y_cnt >= Pos_Y4 && y_cnt < Pos_Y4 +  HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word4=(x_cnt >= Pos_X4 - 2 && x_cnt < Pos_X4 + WITH-2) ? 1'b1 : 1'b0; 
	
	assign x_word5=(x_cnt >= Pos_X5 && x_cnt < Pos_X5 +WITH ) ? 1'b1 : 1'b0; 
	assign y_word5=(y_cnt >= Pos_Y5 && y_cnt < Pos_Y5 +  HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word5=(x_cnt >= Pos_X5 - 2 && x_cnt < Pos_X5 + WITH-2) ? 1'b1 : 1'b0; 
	
	assign x_word6=(x_cnt >= Pos_X6 && x_cnt < Pos_X6 + WITH) ? 1'b1 : 1'b0; 
	assign y_word6=(y_cnt >= Pos_Y6 && y_cnt < Pos_Y6 + HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word6=(x_cnt >= Pos_X6 - 2 && x_cnt < Pos_X6 + WITH-2) ? 1'b1 : 1'b0; 
	
	assign x_word7=(x_cnt >= Pos_X7 && x_cnt < Pos_X7 + WITH) ? 1'b1 : 1'b0; 
	assign y_word7=(y_cnt >= Pos_Y7 && y_cnt < Pos_Y7 + HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word7=(x_cnt >= Pos_X7 - 2 && x_cnt < Pos_X7 +WITH-2) ? 1'b1 : 1'b0;
	
	assign x_word8=(x_cnt >= Pos_X8 && x_cnt < Pos_X8 +WITH ) ? 1'b1 : 1'b0; 
	assign y_word8=(y_cnt >= Pos_Y8 && y_cnt < Pos_Y8 +  HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word8=(x_cnt >= Pos_X8 - 2 && x_cnt < Pos_X8 + WITH-2) ? 1'b1 : 1'b0; 
	
	assign x_word9=(x_cnt >= Pos_X9 && x_cnt < Pos_X9 +WITH ) ? 1'b1 : 1'b0; 
	assign y_word9=(y_cnt >= Pos_Y9 && y_cnt < Pos_Y9 +  HIGHT) ? 1'b1 : 1'b0; 
	assign pre_x_word9=(x_cnt >= Pos_X9 - 2 && x_cnt < Pos_X9 + WITH-2) ? 1'b1 : 1'b0; 
	
	assign x_score0=(x_cnt >= score0_x && x_cnt < score0_x + WITH_SCORE) ? 1'b1 : 1'b0; 
	assign y_score0=(y_cnt >= score0_y && y_cnt < score0_y + HIGHT_SCORE) ? 1'b1 : 1'b0; 
	assign pre_x_score0=(x_cnt >= score0_x - 2 && x_cnt < score0_x + WITH_SCORE-2) ? 1'b1 : 1'b0; 
	
	assign x_score1=(x_cnt >= score1_x && x_cnt < score1_x + WITH_SCORE) ? 1'b1 : 1'b0; 
	assign y_score1=(y_cnt >= score1_y && y_cnt < score1_y + HIGHT_SCORE) ? 1'b1 : 1'b0; 
	assign pre_x_score1=(x_cnt >= score1_x - 2 && x_cnt < score1_x +WITH_SCORE-2) ? 1'b1 : 1'b0;
	
	assign x_score2=(x_cnt >= score2_x && x_cnt < score2_x +WITH_SCORE ) ? 1'b1 : 1'b0; 
	assign y_score2=(y_cnt >= score2_y && y_cnt < score2_y +  HIGHT_SCORE) ? 1'b1 : 1'b0; 
	assign pre_x_score2=(x_cnt >= score2_x - 2 && x_cnt < score2_x + WITH_SCORE-2) ? 1'b1 : 1'b0; 
	
	assign x_score3=(x_cnt >= score3_x && x_cnt < score3_x +WITH_SCORE ) ? 1'b1 : 1'b0; 
	assign y_score3=(y_cnt >= score3_y && y_cnt < score3_y +  HIGHT_SCORE) ? 1'b1 : 1'b0; 
	assign pre_x_score3=(x_cnt >= score3_x - 2 && x_cnt < score3_x + WITH_SCORE-2) ? 1'b1 : 1'b0; 

	//--------------------------------------------------//
	//--------------------0-9rom地址划分-----------------//
	//--------------------------------------------------//
	
	parameter 	digital_addr0=0,
					digital_addr1=1*105,
					digital_addr2=2*105,
					digital_addr3=3*105,
					digital_addr4=4*105,
					digital_addr5=5*105,
					digital_addr6=6*105,
					digital_addr7=7*105,
					digital_addr8=8*105,
					digital_addr9=9*105;
					
	//--------------------------------------------------//
	//------------------各个字符字节地址产生模块------------//
	//--------------------------------------------------//					
						
	always @(posedge lcd_clk) 
	begin 
		if (~rstn) 
		begin 
			x1_count<=0; 
			x2_count<=0;
			x3_count<=0; 
			x4_count<=0;
			x5_count<=0; 
			x6_count<=0;
			x7_count<=0; 
			x8_count<=0;
			x9_count<=0;
			
			s0_count<=0; 
			s1_count<=0;
			s2_count<=0; 
			s3_count<=0;
			
			word1_rom_addra<=0; 
			word2_rom_addra<=0; 
			word3_rom_addra<=0; 
			word4_rom_addra<=0; 
			word5_rom_addra<=0;
			word6_rom_addra<=0; 
			word7_rom_addra<=0; 
			word8_rom_addra<=0; 
			word9_rom_addra<=0;
			
			case(score0)
			 0:score0_rom_addra<=digital_addr0; 
			 1:score0_rom_addra<=digital_addr1;
			 2:score0_rom_addra<=digital_addr2;
			 3:score0_rom_addra<=digital_addr3; 
			 4:score0_rom_addra<=digital_addr4;
			 5:score0_rom_addra<=digital_addr5;
			 6:score0_rom_addra<=digital_addr6; 
			 7:score0_rom_addra<=digital_addr7;
			 8:score0_rom_addra<=digital_addr8;
			 9:score0_rom_addra<=digital_addr9;
			 endcase
			 
			case(score1)
			 0: score1_rom_addra<=digital_addr0; 
			 1:score1_rom_addra<=digital_addr1;
			 2:score1_rom_addra<=digital_addr2;
			 3: score1_rom_addra<=digital_addr3; 
			 4:score1_rom_addra<=digital_addr4;
			 5:score1_rom_addra<=digital_addr5;
			 6: score1_rom_addra<=digital_addr6; 
			 7:score1_rom_addra<=digital_addr7;
			 8:score1_rom_addra<=digital_addr8;
			 9:score1_rom_addra<=digital_addr9;
			 endcase
			 
			case(score2)
			 0: score2_rom_addra<=0*105; 
			 1:score2_rom_addra<=1*105;
			 2:score2_rom_addra<=2*105;
			 3: score2_rom_addra<=3*105; 
			 4:score2_rom_addra<=4*105;
			 5:score2_rom_addra<=5*105;
			 6: score2_rom_addra<=6*105; 
			 7:score2_rom_addra<=7*105;
			 8:score2_rom_addra<=8*105;
			 9:score2_rom_addra<=9*105;
			 endcase
			 
			case(score3)
			 0: score3_rom_addra<=0*105; 
			 1:score3_rom_addra<=1*105;
			 2:score3_rom_addra<=2*105;
			 3: score3_rom_addra<=3*105; 
			 4:score3_rom_addra<=4*105;
			 5:score3_rom_addra<=5*105;
			 6: score3_rom_addra<=6*105; 
			 7:score3_rom_addra<=7*105;
			 8:score3_rom_addra<=8*105;
			 9:score3_rom_addra<=9*105;
			 endcase
			 
		 end 
	 else 
		 begin 
		 if (vsync_r==1'b0) 
		 begin 
			 word1_rom_addra<=0; 
			 word2_rom_addra<=0; 
			 word3_rom_addra<=0; 
			 word4_rom_addra<=0; 
			 word5_rom_addra<=0;
			 word6_rom_addra<=0; 
			 word7_rom_addra<=0; 
			 word8_rom_addra<=0; 
			 word9_rom_addra<=0;
			 
			case(score0)
			 0: score0_rom_addra<=digital_addr0; 
			 1:score0_rom_addra<=digital_addr1;
			 2:score0_rom_addra<=digital_addr2;
			 3: score0_rom_addra<=digital_addr3; 
			 4:score0_rom_addra<=digital_addr4;
			 5:score0_rom_addra<=digital_addr5;
			 6: score0_rom_addra<=digital_addr6; 
			 7:score0_rom_addra<=digital_addr7;
			 8:score0_rom_addra<=digital_addr8;
			 9:score0_rom_addra<=digital_addr9;
			 endcase
			 
			case(score1)
			 0: score1_rom_addra<=digital_addr0; 
			 1:score1_rom_addra<=digital_addr1;
			 2:score1_rom_addra<=digital_addr2;
			 3: score1_rom_addra<=digital_addr3; 
			 4:score1_rom_addra<=digital_addr4;
			 5:score1_rom_addra<=digital_addr5;
			 6: score1_rom_addra<=digital_addr6; 
			 7:score1_rom_addra<=digital_addr7;
			 8:score1_rom_addra<=digital_addr8;
			 9:score1_rom_addra<=digital_addr9;
			 endcase
			 
			case(score2)
			 0: score2_rom_addra<=0*105; 
			 1:score2_rom_addra<=1*105;
			 2:score2_rom_addra<=2*105;
			 3: score2_rom_addra<=3*105; 
			 4:score2_rom_addra<=4*105;
			 5:score2_rom_addra<=5*105;
			 6: score2_rom_addra<=6*105; 
			 7:score2_rom_addra<=7*105;
			 8:score2_rom_addra<=8*105;
			 9:score2_rom_addra<=9*105;
			 endcase
			 
			case(score3)
			 0: score3_rom_addra<=0*105; 
			 1:score3_rom_addra<=1*105;
			 2:score3_rom_addra<=2*105;
			 3: score3_rom_addra<=3*105; 
			 4:score3_rom_addra<=4*105;
			 5:score3_rom_addra<=5*105;
			 6: score3_rom_addra<=6*105; 
			 7:score3_rom_addra<=7*105;
			 8:score3_rom_addra<=8*105;
			 9:score3_rom_addra<=9*105;
			 endcase
			 
			x1_count<=0; 
			x2_count<=0;
			x3_count<=0; 
			x4_count<=0;
			x5_count<=0; 
			x6_count<=0;
			x7_count<=0; 
			x8_count<=0;
			x9_count<=0; 
			s0_count<=0; 
			s1_count<=0;
			s2_count<=0; 
			s3_count<=0;
		 end 
		 else 
			 if((y_word1==1'b1) && (pre_x_word1==1'b1)) begin 
			 //读第一个字体，提前2个时钟产生地址 
				 if (x1_count==7) begin 
				 //ROM里的每个字节显示8个像数，8个时钟ROM地址加1 
				 word1_rom_addra<=word1_rom_addra+1'b1; 
				 //ROM地址加1 
				 x1_count<=0; 
				 end 
			 else 
				 begin 
				 x1_count<=x1_count+1'b1; 
				 word1_rom_addra<=word1_rom_addra; 
				 end 
			 end 
		 else if((y_word2==1'b1) && (pre_x_word2==1'b1)) begin 
			 if (x2_count==7) begin 
			 word2_rom_addra<=word2_rom_addra+1'b1; 
			 x2_count<=0; 
			 end 
			else begin x2_count<=x2_count+1'b1;
				 word2_rom_addra<=word2_rom_addra;
				 end
			 end 
		 else if((y_word3==1'b1) && (pre_x_word3==1'b1)) begin 
			 if (x3_count==7) begin 
			 word3_rom_addra<=word3_rom_addra+1'b1; 
			 x3_count<=0; 
			 end 
			else begin x3_count<=x3_count+1'b1;
				 word3_rom_addra<=word3_rom_addra;
				 end
			 end 
		 else if((y_word4==1'b1) && (pre_x_word4==1'b1)) begin  
			 if (x4_count==7) begin 
			 word4_rom_addra<=word4_rom_addra+1'b1; 
			 x4_count<=0; 
			 end 
			else begin x4_count<=x4_count+1'b1;
				 word4_rom_addra<=word4_rom_addra;
				 end
			 end 
		 else if((y_word5==1'b1) && (pre_x_word5==1'b1)) begin 
			 if (x5_count==7) begin 
			 word5_rom_addra<=word5_rom_addra+1'b1; 
			 x5_count<=0; 
			 end 
			else begin x5_count<=x5_count+1'b1;
				 word5_rom_addra<=word5_rom_addra;
				 end
			 end 
		else if((y_word6==1'b1) && (pre_x_word6==1'b1)) begin  
			 if (x6_count==7) begin 
			 word6_rom_addra<=word6_rom_addra+1'b1; 
			 x6_count<=0; 
			 end 
			else begin x6_count<=x6_count+1'b1;
				 word6_rom_addra<=word6_rom_addra;
				 end
			 end 
		else if((y_word7==1'b1) && (pre_x_word7==1'b1)) begin 
			 if (x7_count==7) begin 
			 word7_rom_addra<=word7_rom_addra+1'b1; 
			 x7_count<=0; 
			 end 
			else begin x7_count<=x7_count+1'b1;
				 word7_rom_addra<=word7_rom_addra;
				 end
			 end 
		else if((y_word8==1'b1) && (pre_x_word8==1'b1)) begin 
			 if (x8_count==7) begin 
			 word8_rom_addra<=word8_rom_addra+1'b1; 
			 x8_count<=0; 
			 end 
			else begin x8_count<=x8_count+1'b1;
				 word8_rom_addra<=word8_rom_addra;
				 end
			 end
		else if((y_word9==1'b1) && (pre_x_word9==1'b1)) begin 
			 if (x9_count==7) begin 
			 word9_rom_addra<=word9_rom_addra+1'b1; 
			 x9_count<=0; 
			 end 
			else begin x9_count<=x9_count+1'b1;
				 word9_rom_addra<=word9_rom_addra;
				 end
			 end 
		else if((y_score0==1'b1) && (pre_x_score0==1'b1)) begin  
			 if (s0_count==7) begin 
			 score0_rom_addra<=score0_rom_addra+1'b1; 
			 s0_count<=0; 
			 end 
			else begin s0_count<=s0_count+1'b1;
				 score0_rom_addra<=score0_rom_addra;
				 end
			 end 
		else if((y_score1==1'b1) && (pre_x_score1==1'b1)) begin 
			 if (s1_count==7) begin 
			 score1_rom_addra<=score1_rom_addra+1'b1; 
			 s1_count<=0; 
			 end 
			else begin s1_count<=s1_count+1'b1;
				 score1_rom_addra<=score1_rom_addra;
				 end
			 end 
		else if((y_score2==1'b1) && (pre_x_score2==1'b1)) begin 
			 if (s2_count==7) begin 
			 score2_rom_addra<=score2_rom_addra+1'b1; 
			 s2_count<=0; 
			 end 
			else begin s2_count<=s2_count+1'b1;
				 score2_rom_addra<=score2_rom_addra;
				 end
			 end
		else if((y_score3==1'b1) && (pre_x_score3==1'b1)) begin 
			 if (s3_count==7) begin 
			 score3_rom_addra<=score3_rom_addra+1'b1; 
			 s3_count<=0; 
			 end 
			else begin s3_count<=s3_count+1'b1;
				 score3_rom_addra<=score3_rom_addra;
				 end
			 end  
	 else 
			 begin 
				x1_count<=0; 
				x2_count<=0;
				x3_count<=0; 
				x4_count<=0;
				x5_count<=0;
				x6_count<=0;
				x7_count<=0; 
				x8_count<=0;
				x9_count<=0; 
				s0_count<=0; 
				s1_count<=0;
				s2_count<=0; 
				s3_count<=0;	
				
			 word1_rom_addra<=word1_rom_addra; 
			 word2_rom_addra<=word2_rom_addra; 
			 word3_rom_addra<=word3_rom_addra; 
			 word4_rom_addra<=word4_rom_addra; 
			 word5_rom_addra<=word5_rom_addra; 
			 word6_rom_addra<=word6_rom_addra; 
			 word7_rom_addra<=word7_rom_addra; 
			 word8_rom_addra<=word8_rom_addra; 
			 word9_rom_addra<=word9_rom_addra; 
			 
			score0_rom_addra<=score0_rom_addra; 
			score1_rom_addra<=score1_rom_addra; 
			score2_rom_addra<=score2_rom_addra; 
			score3_rom_addra<=score3_rom_addra;
			 end 
	 end 
	end

	//--------------------------------------------------//
	//------------------各个字符字节内位地址产生模块---------//
	//--------------------------------------------------//	

	 reg [4:0] x1_bit_count; 
	 reg [4:0] x2_bit_count; 
	 reg [4:0] x3_bit_count; 
	 reg [4:0] x4_bit_count; 
	 reg [4:0] x5_bit_count; 
	 reg [4:0] x6_bit_count; 
	 reg [4:0] x7_bit_count; 
	 reg [4:0] x8_bit_count; 
	 reg [4:0] x9_bit_count;
	 reg [4:0] s0_bit_count;
	 reg [4:0] s1_bit_count;
	 reg [4:0] s2_bit_count;
	 reg [4:0] s3_bit_count;
	 always @(posedge lcd_clk) 
	 begin 
	 if (~rstn) 
	 begin x1_bit_count<=7; x2_bit_count<=7;x3_bit_count<=7; x4_bit_count<=7;x5_bit_count<=7;
	 x6_bit_count<=7;x7_bit_count<=7; x8_bit_count<=7;x9_bit_count<=7;s0_bit_count<=7;s1_bit_count<=7;s2_bit_count<=7;s3_bit_count<=7;
	 end 
	 else 
	 begin 
		 if (vsync_r==1'b0) begin
		 x1_bit_count<=7; x2_bit_count<=7; x3_bit_count<=7; x4_bit_count<=7;x5_bit_count<=7;
		 end 
	 else if((y_word1==1'b1) && (x_word1==1'b1))
		 begin 
		 if (x1_bit_count==0) x1_bit_count<=7; 
		 else x1_bit_count<=x1_bit_count-1'b1; 
		 end 
	 else if((y_word2==1'b1) && (x_word2==1'b1)) begin 
		 if (x2_bit_count==0) 
		 x2_bit_count<=7; 
		 else x2_bit_count<=x2_bit_count-1'b1; 
		 end 
	 else if((y_word3==1'b1) && (x_word3==1'b1)) begin 
		 if (x3_bit_count==0) 
		 x3_bit_count<=7; 
		 else x3_bit_count<=x3_bit_count-1'b1; 
		 end 
	 else if((y_word4==1'b1) && (x_word4==1'b1)) begin 
		 if (x4_bit_count==0) 
		 x4_bit_count<=7; 
		 else x4_bit_count<=x4_bit_count-1'b1; 
		 end 
	 else if((y_word5==1'b1) && (x_word5==1'b1)) begin 
		 if (x5_bit_count==0) 
		 x5_bit_count<=7; 
		 else x5_bit_count<=x5_bit_count-1'b1; 
		 end 
	 else if((y_word6==1'b1) && (x_word6==1'b1)) begin 
		 if (x6_bit_count==0) 
		 x6_bit_count<=7; 
		 else x6_bit_count<=x6_bit_count-1'b1; 
		 end
	 else if((y_word7==1'b1) && (x_word7==1'b1)) begin 
		 if (x7_bit_count==0) 
		 x7_bit_count<=7; 
		 else x7_bit_count<=x7_bit_count-1'b1; 
		 end
	 else if((y_word8==1'b1) && (x_word8==1'b1)) begin 
		 if (x8_bit_count==0) 
		 x8_bit_count<=7; 
		 else x8_bit_count<=x8_bit_count-1'b1; 
		 end
	 else if((y_word9==1'b1) && (x_word9==1'b1)) begin 
		 if (x9_bit_count==0) 
		 x9_bit_count<=7; 
		 else x9_bit_count<=x9_bit_count-1'b1; 
		 end
	 else if((y_score0==1'b1) && (x_score0==1'b1)) begin 
		 if (s0_bit_count==0) 
		 s0_bit_count<=7; 
		 else s0_bit_count<=s0_bit_count-1'b1; 
		 end
	 else if((y_score1==1'b1) && (x_score1==1'b1)) begin 
		 if (s1_bit_count==0) 
		 s1_bit_count<=7; 
		 else s1_bit_count<=s1_bit_count-1'b1; 
		 end
	 else if((y_score2==1'b1) && (x_score2==1'b1)) begin 
		 if (s2_bit_count==0) 
		 s2_bit_count<=7; 
		 else s2_bit_count<=s2_bit_count-1'b1; 
		 end
	 else if((y_score3==1'b1) && (x_score3==1'b1)) begin 
		 if (s3_bit_count==0) 
		 s3_bit_count<=7; 
		 else s3_bit_count<=s3_bit_count-1'b1; 
		 end
	 else begin x1_bit_count<=7; x2_bit_count<=7; x3_bit_count<=7; x4_bit_count<=7;x5_bit_count<=7;
	  x6_bit_count<=7;x7_bit_count<=7; x8_bit_count<=7;x9_bit_count<=7;s0_bit_count<=7;s1_bit_count<=7;s2_bit_count<=7;s3_bit_count<=7;
	 end 
	 end
	 end 
 
	//--------------------------------------------------//
	//------------------LCD字符输出模块-------------------//
	//--------------------------------------------------//
	
	 reg [7:0] lcd_r_w; 
	 wire [7:0] lcd_r_word1; 
	 wire [7:0] lcd_r_word2; 
	 wire [7:0] lcd_r_word3; 
	 wire [7:0] lcd_r_word4; 
	 wire [7:0] lcd_r_word5; 
	 wire [7:0] lcd_r_word6; 
	 wire [7:0] lcd_r_word7; 
	 wire [7:0] lcd_r_word8; 
	 wire [7:0] lcd_r_word9;
	 wire [7:0] lcd_r_score0;
	 wire [7:0] lcd_r_score1;
	 wire [7:0] lcd_r_score2;
	 wire [7:0] lcd_r_score3;
	 
	 assign lcd_r_word1 = {8{rom_data1[x1_bit_count]}}; 
	 assign lcd_r_word2 = {8{rom_data2[x2_bit_count]}}; 
	 assign lcd_r_word3 = {8{rom_data3[x3_bit_count]}}; 
	 assign lcd_r_word4 = {8{rom_data4[x4_bit_count]}}; 
	 assign lcd_r_word5 = {8{rom_data5[x5_bit_count]}}; 
	 assign lcd_r_word6 = {8{rom_data6[x6_bit_count]}};   
	 assign lcd_r_word7 = {8{rom_data7[x7_bit_count]}}; 
	 assign lcd_r_word8 = {8{rom_data8[x8_bit_count]}}; 
	 assign lcd_r_word9 = {8{rom_data9[x9_bit_count]}}; 
	 assign lcd_r_score0 = {8{s_rom_data0[s0_bit_count]}}; 
	 assign lcd_r_score1 = {8{s_rom_data1[s1_bit_count]}}; 
	 assign lcd_r_score2 = {8{s_rom_data2[s2_bit_count]}}; 
	 assign lcd_r_score3 = {8{s_rom_data3[s3_bit_count]}}; 
 
	always@(posedge lcd_clk)
	begin
		case({x_word1&y_word1,x_word2&y_word2,x_word3&y_word3,x_word4&y_word4,x_word5&y_word5,x_word6&y_word6,x_word7&y_word7,x_word8&y_word8,x_word9&y_word9,x_score0&y_score0,x_score1&y_score1,x_score2&y_score2,x_score3&y_score3})
		13'b1000000000000:lcd_r_w = lcd_r_word1 ;
		13'b0100000000000:lcd_r_w = lcd_r_word2 ;
		13'b0010000000000:lcd_r_w = lcd_r_word3 ;
		13'b0001000000000:lcd_r_w = lcd_r_word4 ;
		13'b0000100000000:lcd_r_w = lcd_r_word5 ;
		13'b0000010000000:lcd_r_w = lcd_r_word6 ;
		13'b0000001000000:lcd_r_w = lcd_r_word7 ;
		13'b0000000100000:lcd_r_w = lcd_r_word8 ;
		13'b0000000010000:lcd_r_w = lcd_r_word9 ;
		13'b0000000001000:lcd_r_w = lcd_r_score0 ;
		13'b0000000000100:lcd_r_w = lcd_r_score1 ;
		13'b0000000000010:lcd_r_w = lcd_r_score2 ;
		13'b0000000000001:lcd_r_w = lcd_r_score3 ;	
		default:lcd_r_w=8'b00000000;
		endcase
	end
 
 	//--------------------------------------------------//
	//------------------ROM实例化模块---------------------//
	//--------------------------------------------------//

	reg [10:0] rom_addra; 
	wire [7:0] rom_data1; 
	wire [7:0] rom_data2; 
	wire [7:0] rom_data3; 
	wire [7:0] rom_data4; 
	wire [7:0] rom_data5; 
	wire [7:0] rom_data6; 
	wire [7:0] rom_data7; 
	wire [7:0] rom_data8; 
	wire [7:0] rom_data9; 
	wire [7:0] s_rom_data0; 
	wire [7:0] s_rom_data1;
	wire [7:0] s_rom_data2;
	wire [7:0] s_rom_data3;
	rom_s rom_s(
	.clock(lcd_clk), // input clka 
	 
	 .address(word1_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data1) // output [7 : 0] douta
	);
	rom_c rom_c(
	.clock(lcd_clk), // input clka 
	 
	 .address(word2_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data2) // output [7 : 0] douta
	);
	rom_o rom_o(
	.clock(lcd_clk), // input clka 
	 
	 .address(word3_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data3) // output [7 : 0] douta
	);
	rom_r rom_r(
	.clock(lcd_clk), // input clka 
	 
	 .address(word4_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data4) // output [7 : 0] douta
	);
	rom_e rom_e1(
	.clock(lcd_clk), // input clka 
	 
	 .address(word5_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data5) // output [7 : 0] douta
	);
	rom_n rom_n(
	.clock(lcd_clk), // input clka 
	 
	 .address(word6_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data6) // output [7 : 0] douta
	);
	rom_e rom_e2(
	.clock(lcd_clk), // input clka 
	 
	 .address(word7_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data7) // output [7 : 0] douta
	);
	rom_x rom_x(
	.clock(lcd_clk), // input clka 
	 
	 .address(word8_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data8) // output [7 : 0] douta
	);
	rom_t rom_t(
	.clock(lcd_clk), // input clka 
	 
	 .address(word9_rom_addra), // input [10 : 0] addra 
	 
	 .q(rom_data9) // output [7 : 0] douta
	);
	
	 rom_digital rom_digital_0 ( .clock(lcd_clk), // input clka 
	 
	 .address(score0_rom_addra), // input [10 : 0] addra 
	 
	 .q(s_rom_data0) // output [7 : 0] douta
	 
	 );
	  rom_digital rom_digital_1 ( .clock(lcd_clk), // input clka 
	 
	 .address(score1_rom_addra), // input [10 : 0] addra 
	 
	 .q(s_rom_data1) // output [7 : 0] douta
	 
	 );
	  rom_digital rom_digital_2 ( .clock(lcd_clk), // input clka 
	 
	 .address(score2_rom_addra), // input [10 : 0] addra 
	 
	 .q(s_rom_data2) // output [7 : 0] douta
	 
	 );
	  rom_digital rom_digital_3 ( .clock(lcd_clk), // input clka 
	 
	 .address(score3_rom_addra), // input [10 : 0] addra 
	 
	 .q(s_rom_data3) // output [7 : 0] douta
	 
	 );

	//--------------------------------------------------//
	//----------------LCD背景矩阵与字符输出整合模块---------//
	//--------------------------------------------------//
	
	 
	assign lcd_r_c = (((y_word1==1'b1) && (x_word1==1'b1))||((y_word2==1'b1) && (x_word2==1'b1))|((y_word3==1'b1) && (x_word3==1'b1))| ((y_word4==1'b1) && (x_word4==1'b1))| ((y_word5==1'b1) && (x_word5==1'b1))| ((y_word6==1'b1) && (x_word6==1'b1))|((y_word7==1'b1) && (x_word7==1'b1))| ((y_word8==1'b1) && (x_word8==1'b1))| ((y_word9==1'b1) && (x_word9==1'b1))| ((y_score0==1'b1) && (x_score0==1'b1))| ((y_score1==1'b1) && (x_score1==1'b1))| ((y_score2==1'b1) && (x_score2==1'b1))| ((y_score3==1'b1) && (x_score3==1'b1))) ? lcd_r_w:8'b00000000;
	assign lcd_g_c = (((y_word1==1'b1) && (x_word1==1'b1))||((y_word2==1'b1) && (x_word2==1'b1))|((y_word3==1'b1) && (x_word3==1'b1))| ((y_word4==1'b1) && (x_word4==1'b1))| ((y_word5==1'b1) && (x_word5==1'b1))| ((y_word6==1'b1) && (x_word6==1'b1))|((y_word7==1'b1) && (x_word7==1'b1))| ((y_word8==1'b1) && (x_word8==1'b1))| ((y_word9==1'b1) && (x_word9==1'b1))| ((y_score0==1'b1) && (x_score0==1'b1))| ((y_score1==1'b1) && (x_score1==1'b1))| ((y_score2==1'b1) && (x_score2==1'b1))| ((y_score3==1'b1) && (x_score3==1'b1))) ? lcd_r_w:8'b00000000;
	assign lcd_b_c = 8'b00000000;
	
	wire[7:0] lcd_b_s;
	wire [7:0]lcd_b_c;
	wire [7:0]lcd_g_c;
	wire [7:0]lcd_g_s;
	wire [7:0]lcd_r_s;
	wire [7:0]lcd_r_c;
	
	assign lcd_b=lcd_b_c|lcd_b_s;
	assign lcd_g=lcd_g_c|lcd_g_s;
	assign lcd_r=lcd_r_c|lcd_r_s;

	//--------------------------------------------------//
	//------------------LCD分频模块----------------------//
	//--------------------------------------------------//
	
	
	pll_9M pll(.inclk0(clk_50M), .c0(lcd_clk));

endmodule