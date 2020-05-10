module state_task( //此模块对各状态机下需要完成的操作进行处理
    input clk1k,
    input rst_n,
	 input [3:0] keys,
	 input [3:0] ran_num, //共19种方块形状,由于有一些重复，此处只产生0-15随机数
	 input init,
	 input gene,
	 input hold,
    input move,
    input down,
    input refresh,
    input judge,
	 input clk1_over,

    output reg down_able,
	 output    change_able,
	 output reg row_succ,
	 output reg over,

    output     [53:0] M_OUT,//12列*17行
    output reg [4:0] n,      //行
    output reg [3:0] m,      //列
    output reg [4:0] block //方块类型
	 //output reg [4:0] new_block//产生的新方块
    );

    reg [5:0] R[8:0];//12列*17行(m*n) 其中只显示12列*16行 6*8
    reg [4:0] block_next; //下一个方块
    reg [3:0] REMOVE_2_S;
    reg [3:0] REMOVE_FINISH;//4行是否都处理完的标志
    reg [4:0] REMOVE_2_C;
    reg       sign;//行消除标志位
	 reg  fix_over;//移动方块落到底层后变为背景矩阵 完成的标志
	 reg [4:0] new_block;//产生的新方块

    reg up_able;//能翻转信号
    reg right_able;//能左移信号
    reg left_able;//能左移信号

    parameter ROW = 8;//行数
    parameter COL = 6;//列数
    
    parameter  A_0 = 5'b00000, //高三位作为A-G 7种类型，低2位作为旋转类型
               B_0 = 5'b00100,  B_1 = 5'b00101,
					C_0 = 5'b01000,  C_1 = 5'b01001,   C_2 = 5'b01010,  C_3 = 5'b01011,
               D_0 = 5'b01100,  D_1 = 5'b01101,   D_2 = 5'b01110,  D_3 = 5'b01111,
					E_0 = 5'b10000,  E_1 = 5'b10001,
					F_0 = 5'b10100,  F_1 = 5'b10101,
					G_0 = 5'b11000,  G_1 = 5'b11001,   G_2 = 5'b11010,  G_3 = 5'b11011;

    
	 assign change_able = up_able | left_able | right_able;//能旋转、左移、右移信号


    // change_able signnal
    always @ (*)
    begin
        begin
        //   if (!rst_n)
        up_able=0;
        left_able=0;
        right_able=0;
        end
        if (move)
        begin
            if (keys[2])  //rotate
            begin
                case (block)
                A_0: up_able=0;
                B_0: if (n<= ROW-2)  //前面有不显示的1行
                        begin if (!((R[n-1][m])|(R[n+1][m])|(R[n+2][m]))) up_able=1; else up_able=0;end
					 B_1: if ((m>=1)&(m<=COL-3))
                        begin if (!((R[n][m-1])|(R[n][m+1])|(R[n][m+2]))) up_able=1; else up_able=0;end
					 C_0: if (m>=1)
                        begin if (!((R[n][m-1])|(R[n][m+1])|(R[n-1][m+1]))) up_able=1; else up_able=0;end
                C_1: if (n<= ROW-1)
                        begin if (!((R[n-1][m])|(R[n+1][m])|(R[n-1][m-1]))) up_able=1; else up_able=0;end
					 C_2: if (m<=COL-2)
                        begin if (!((R[n][m-1])|(R[n][m+1])|(R[n+1][m-1]))) up_able=1; else up_able=0;end
                C_3: if (!((R[n-1][m])|(R[n+1][m])|(R[n+1][m+1]))) up_able=1; else up_able=0;
					 D_0: if (m<=COL-2)
                        begin if (!((R[n][m-1])|(R[n][m+1])|(R[n+1][m+1]))) up_able=1; else up_able=0;end
                D_1: if (!((R[n-1][m])|(R[n+1][m])|(R[n-1][m+1]))) up_able=1; else up_able=0;
					 D_2: if (m>=1)
                        begin if (!((R[n][m-1])|(R[n][m+1])|(R[n-1][m-1]))) up_able=1; else up_able=0;end
                D_3: if (n<= ROW-1)
                        begin if (!((R[n-1][m])|(R[n+1][m])|(R[n-1][m-1]))) up_able=1; else up_able=0;end
					 E_0: if (n<= ROW-1)
                        begin if (!((R[n][m+1])|(R[n+1][m+1]))) up_able=1; else up_able=0;end
                E_1: if (m>=1)
                        begin if (!((R[n-1][m+1])|(R[n][m-1]))) up_able=1; else up_able=0;end
					 F_0: if (!((R[n+1][m-1])|(R[n-1][m]))) up_able=1; else up_able=0;
                F_1: if (!((R[n+1][m])|(R[n+1][m+1]))) up_able=1; else up_able=0;
					 G_0: if (n<= ROW-1)
                        begin if (!(R[n+1][m])) up_able=1; else up_able=0;end
                G_1: if (m<=COL-2)
                        begin if (!(R[n][m+1])) up_able=1; else up_able=0;end
					 G_2: if (!(R[n-1][m])) up_able=1; else up_able=0;
                G_3: if (m>=1)
                        begin if (!(R[n][m-1])) up_able=1; else up_able=0;end
                default up_able=0;
                endcase 
            end
            else if (keys[1])  //left
            begin
                case (block)
                A_0: if (m>=1) if (!((R[n+1][m-1])|(R[n][m-1]))) left_able=1; else left_able=0;
                B_0: if (m>=2) if (!(R[n][m-2])) left_able=1; else left_able=0;
					 B_1: if (m>=1) if (!((R[n-1][m-1])|(R[n][m-1])|(R[n+1][m-1])|(R[n+2][m-1]))) left_able=1; else left_able=0;
					 C_0: if (m>=1) if (!((R[n-1][m-1])|(R[n][m-1])|(R[n+1][m-1]))) left_able=1; else left_able=0;
                C_1: if (m>=2) if (!(R[n][m-2])) left_able=1; else left_able=0;
					 C_2: if (m>=2) if (!((R[n-1][m-2])|(R[n][m-1])|(R[n+1][m-1]))) left_able=1; else left_able=0;
                C_3: if (m>=2) if (!((R[n][m-2])|(R[n+1][m-2]))) left_able=1; else left_able=0;
					 D_0: if (m>=2) if (!((R[n+1][m-2])|(R[n][m-1])|(R[n-1][m-1]))) left_able=1; else left_able=0;
                D_1: if (m>=2) if (!(R[n][m-2])) left_able=1; else left_able=0;
					 D_2: if (m>=1) if (!((R[n-1][m-1])|(R[n][m-1])|(R[n+1][m-1]))) left_able=1; else left_able=0;
                D_3: if (m>=2) if (!((R[n][m-2])|(R[n-1][m-2]))) left_able=1; else left_able=0;
					 E_0: if (m>=2) if (!((R[n][m-2])|(R[n-1][m-1]))) left_able=1; else left_able=0;
                E_1: if (m>=1) if (!((R[n][m-1])|(R[n-1][m-1]))) left_able=1; else left_able=0;
					 F_0: if (m>=2) if (!((R[n][m-2])|(R[n+1][m-1]))) left_able=1; else left_able=0;
                F_1: if (m>=2) if (!((R[n][m-2])|(R[n+1][m-2]))) left_able=1; else left_able=0;
					 G_0: if (m>=2) if (!((R[n][m-2])|(R[n-1][m-1]))) left_able=1; else left_able=0;
                G_1: if (m>=2) if (!((R[n][m-2])|(R[n+1][m-1])|(R[n-1][m-1]))) left_able=1; else left_able=0;
					 G_2: if (m>=2) if (!((R[n][m-2])|(R[n+1][m-1]))) left_able=1; else left_able=0;
                G_3: if (m>=1) if (!((R[n][m-1])|(R[n+1][m-1])|(R[n-1][m-1]))) left_able=1; else left_able=0;
                default left_able=0;
                endcase
            end
            else if (keys[0])  //right
            begin 
                case (block)
                A_0: if (m<=COL-3) if (!((R[n+1][m+2])|(R[n][m+2]))) right_able=1; else   right_able=0;
					 B_0: if (m<=COL-4) if (!(R[n][m+3])) right_able=1; else right_able=0;
                B_1: if (m<=COL-2) if (!((R[n-1][m+1])|(R[n][m+1])|(R[n+1][m+1])|(R[n+2][m+1]))) right_able=1; else right_able=0;               
					 C_0: if (m<=COL-3) if (!((R[n-1][m+1])|(R[n][m+1])|(R[n+1][m+2]))) right_able=1; else right_able=0;
                C_1: if (m<=COL-3) if (!((R[n-1][m+2])|(R[n][m+2])))right_able=1; else right_able=0;
					 C_2: if (m<=COL-2) if (!((R[n-1][m+1])|(R[n][m+1])|(R[n+1][m+1]))) right_able=1; else right_able=0;
                C_3: if (m<=COL-3) if (!(R[n][m+2])) right_able=1; else right_able=0;
					 D_0: if (m<=COL-2) if (!((R[n-1][m+1])|(R[n][m+1])|(R[n+1][m+1]))) right_able=1; else right_able=0;
                D_1: if (m<=COL-3) if (!((R[n][m+2])|(R[n+1][m+2]))) right_able=1; else right_able=0;
					 D_2: if (m<=COL-3) if (!((R[n-1][m+2])|(R[n][m+1])|(R[n+1][m+1]))) right_able=1; else right_able=0;
                D_3: if (m<=COL-3) if (!(R[n][m+2])) right_able=1; else right_able=0;
					 E_0: if (m<=COL-3) if (!((R[n][m+1])|(R[n-1][m+2]))) right_able=1; else right_able=0;
                E_1: if (m<=COL-3) if (!((R[n][m+2])|(R[n+1][m+2])|(R[n-1][m]))) right_able=1; else right_able=0;
					 F_0: if (m<=COL-3) if (!((R[n][m+1])|(R[n+1][m+2]))) right_able=1; else right_able=0;
                F_1: if (m<=COL-2) if (!((R[n-1][m+1])|(R[n][m+1])|(R[n+1][m]))) right_able=1; else right_able=0;
					 G_0: if (m<=COL-3) if (!((R[n-1][m+1])|(R[n][m+2]))) right_able=1; else right_able=0;
                G_1: if (m<=COL-2) if (!((R[n-1][m+1])|(R[n][m+1])|(R[n+1][m+1]))) right_able=1; else right_able=0;
					 G_2: if (m<=COL-3) if (!((R[n-1][m+2])|(R[n+1][m+1]))) right_able=1; else right_able=0;
                G_3: if (m<=COL-3) if (!((R[n-1][m+1])|(R[n][m+2])|(R[n+1][m+1]))) right_able=1; else right_able=0;
                default right_able=0;
                endcase
            end
        end
        else
        begin
            right_able = 0;
            left_able = 0;
            up_able = 0;
        end
    end
	 	 
	 
    // M_OUT  
    assign M_OUT = {R[8],R[7],R[6],R[5],R[4],R[3],R[2],R[1],R[0]};

	 
    // R the picture
    integer i,j;//这儿用到了integer
    always @ (posedge clk1k or negedge rst_n)
    begin
        if (!rst_n)
            begin
                for (i = 0; i < ROW+1; i = i + 1) R[i] <= 0;
                REMOVE_FINISH<=0;
					 fix_over = 0;//移动方块落到底层后变为背景矩阵 完成的标志
            end
				
		  else if (judge == 1 && row_succ == 0 && fix_over == 0) //方块已经落到底层，要将移动的方块固定到背景矩阵上
        begin
            case (block)
            A_0: begin R[n][m]<=1;R[n][m+1]<=1;R[n+1][m]<=1;R[n+1][m+1]<=1;end
				B_0: begin R[n][m-1]<=1;R[n][m]<=1;R[n][m+1]<=1;R[n][m+2]<=1;end
            B_1: begin R[n-1][m]<=1;R[n][m]<=1;R[n+1][m]<=1;R[n+2][m]<=1;end        
				C_0: begin R[n-1][m]<=1;R[n][m]<=1;R[n+1][m]<=1;R[n+1][m+1]<=1;end
            C_1: begin R[n-1][m+1]<=1;R[n][m-1]<=1;R[n][m]<=1;R[n][m+1]<=1;end
				C_2: begin R[n-1][m-1]<=1;R[n-1][m]<=1;R[n][m]<=1;R[n+1][m]<=1;end
            C_3: begin R[n][m-1]<=1;R[n][m]<=1;R[n][m+1]<=1;R[n+1][m-1]<=1;end
				D_0: begin R[n-1][m]<=1;R[n][m]<=1;R[n+1][m]<=1;R[n+1][m-1]<=1;end
            D_1: begin R[n][m-1]<=1;R[n][m]<=1;R[n][m+1]<=1;R[n+1][m+1]<=1;end
				D_2: begin R[n-1][m]<=1;R[n-1][m+1]<=1;R[n][m]<=1;R[n+1][m]<=1;end
            D_3: begin R[n-1][m-1]<=1;R[n][m-1]<=1;R[n][m]<=1;R[n][m+1]<=1;end
				E_0: begin R[n-1][m]<=1;R[n-1][m+1]<=1;R[n][m-1]<=1;R[n][m]<=1;end
            E_1: begin R[n-1][m]<=1;R[n][m]<=1;R[n][m+1]<=1;R[n+1][m+1]<=1;end
				F_0: begin R[n][m-1]<=1;R[n][m]<=1;R[n+1][m]<=1;R[n+1][m+1]<=1;end
            F_1: begin R[n-1][m]<=1;R[n][m-1]<=1;R[n][m]<=1;R[n+1][m-1]<=1;end
				G_0: begin R[n-1][m]<=1;R[n][m-1]<=1;R[n][m]<=1;R[n][m+1]<=1;end
            G_1: begin R[n-1][m]<=1;R[n][m-1]<=1;R[n][m]<=1;R[n+1][m]<=1;end
				G_2: begin R[n][m-1]<=1;R[n][m]<=1;R[n][m+1]<=1;R[n+1][m]<=1;end
            G_3: begin R[n-1][m]<=1;R[n][m]<=1;R[n][m+1]<=1;R[n+1][m]<=1;end
            default
            begin
                for (i = 0; i < ROW+1; i = i + 1) //这样真的就可以了吗？
					 R[i] <= R[i];   //除非复位和行消除，否则只会增加，不会减少
            end
            endcase
				fix_over = 1;
            REMOVE_2_S<=4'b1111;
        end

		  
        else if (judge == 1 && row_succ == 0 && fix_over == 1)  //此时判断临近4行能否消去
        begin
		  if (!REMOVE_FINISH[0])//从上往下消，先判断的是n-1那一行
            begin 
				    if ((&R[n-1])|(sign))//此行能消去，sign标志着可以继续行移位
                begin
                    if (REMOVE_2_S[0]) begin REMOVE_2_C<=n-1; REMOVE_2_S[0]<=0; sign<=1;end
                    else begin  //这个行消除模块，用了几个时钟周期来完成
                        if (REMOVE_2_C>=1) begin R[REMOVE_2_C]<=R[REMOVE_2_C-1]; REMOVE_2_C<=REMOVE_2_C-1; sign<=1;end
                        else begin REMOVE_FINISH[0]<=1;sign<=0;end//若已经在顶行了，则不消去了
                    end
                end
					 else begin REMOVE_FINISH[0]<=1; sign<=0; end//此行不能消去
            end   
				
        else if (!REMOVE_FINISH[1]) //分别对可能有行消除的n-1行至n+2行进行判断，此处判断第n行
            begin 
				    if ((&R[n])|(sign))
                begin
                    if (REMOVE_2_S[1]) begin REMOVE_2_C<=n; REMOVE_2_S[1]<=0; sign<=1; end
                    else begin
                        if (REMOVE_2_C>=1) begin R[REMOVE_2_C]<=R[REMOVE_2_C-1]; REMOVE_2_C<=REMOVE_2_C-1; sign<=1; end
                        else begin REMOVE_FINISH[1]<=1; sign<=0; end
                    end
                end
            else begin REMOVE_FINISH[1]<=1; sign<=0; end
            end
				
        else if (!REMOVE_FINISH[2])//分别对可能有行消除的n-1行至n+2行进行判断，此处判断第n+1行
            begin
            if (n<=ROW-1)
                begin if ((&R[n+1])|(sign))
                    begin
                        if (REMOVE_2_S[2]) begin REMOVE_2_C<=n+1; REMOVE_2_S[2]<=0;sign<=1; end
                        else begin
                            if (REMOVE_2_C>=1) begin R[REMOVE_2_C]<=R[REMOVE_2_C-1]; REMOVE_2_C<=REMOVE_2_C-1; sign<=1; end
                            else begin REMOVE_FINISH[2]<=1; sign<=0; end
                        end
                    end
                    else begin REMOVE_FINISH[2]<=1; sign<=0; end
                end
            else begin REMOVE_FINISH[2]<=1; sign<=0; end
				fix_over = 0;//行消除判断结束后fix_over置为0
            end    
				
        else if (!REMOVE_FINISH[3])//分别对可能有行消除的n-1行至n+2行进行判断，此处判断第n+2行
            begin
            if (n<=ROW)
                begin if ((&R[n+2])|(sign))
                    begin
                        if (REMOVE_2_S[3]) begin REMOVE_2_C<=n+2; REMOVE_2_S[3]<=0; sign<=1; end
                        else begin
                            if (REMOVE_2_C>=1) begin R[REMOVE_2_C]<=R[REMOVE_2_C-1]; REMOVE_2_C<=REMOVE_2_C-1; sign<=1; end
                            else begin REMOVE_FINISH[3]<=1; sign<=1; end
                        end
                    end
                    else begin REMOVE_FINISH[3]<=1; sign<=0; end
                end
        else begin REMOVE_FINISH[3]<=1; sign<=0; end  
        end
			  
        else
        begin
            for (i=0; i <ROW+1; i = i + 1) R[i] <= R[i];
            REMOVE_FINISH<=0;
            sign<=0;
        end
     end
     else if (init) for (i=0;i<ROW+1;i=i+1) R[i]<=0;
end


    //block_next
    always @ (*)
    begin
        case (block)
        A_0: block_next = A_0;
        B_0: block_next = B_1;
        B_1: block_next = B_0;
		  C_0: block_next = C_1;
        C_1: block_next = C_2;
		  C_2: block_next = C_3;
        C_3: block_next = C_0;
		  D_0: block_next = D_1;
        D_1: block_next = D_2;
		  D_2: block_next = D_3;
        D_3: block_next = D_0;
		  E_0: block_next = E_1;
        E_1: block_next = E_0;
		  F_0: block_next = F_1;
        F_1: block_next = F_0;
		  G_0: block_next = G_1;
        G_1: block_next = G_2;
		  G_2: block_next = G_3;
        G_3: block_next = G_0;		  
        default block_next = A_0;
        endcase
    end

    // block
    always @ (posedge clk1k or negedge rst_n)
    begin
        if (!rst_n)
            block <= A_0;
        else if (gene)
            block <= new_block;
        else if (refresh && keys[2]) //旋转
		     begin
            block <= block_next;
			  end
        else
            block <= block;
    end

    // down_able signnal
    always @ (*)
    begin
      //  if (!rst_n)
        down_able = 0;
        if (down)
        begin
            case (block)
            A_0: if (n<=ROW-2) begin if (!((R[n+2][m])|(R[n+2][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
            B_0: if (n<=ROW-1) begin if (!((R[n+1][m-1])|(R[n+1][m])|(R[n+1][m+1])|(R[n+1][m+2]))) down_able = 1; else down_able = 0; end else down_able=0;
            B_1: if (n<=ROW-3)begin if (!(R[n+3][m])) down_able = 1; else down_able = 0; end else down_able=0;
				C_0: if (n<=ROW-2) begin if (!((R[n+2][m])|(R[n+2][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
            C_1: if (n<=ROW-1) begin if (!((R[n+1][m-1])|(R[n+1][m])|(R[n+1][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
				C_2: if (n<=ROW-2) begin if (!((R[n][m-1])|(R[n+2][m]))) down_able = 1; else down_able = 0; end else down_able=0;
            C_3: if (n<=ROW-2) begin if (!((R[n+2][m-1])|(R[n+1][m])|(R[n+1][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
				D_0: if (n<=ROW-2) begin if (!((R[n+2][m-1])|(R[n+2][m]))) down_able = 1; else down_able = 0; end else down_able=0;
            D_1: if (n<=ROW-2) begin if (!((R[n+1][m-1])|(R[n+1][m])|(R[n+2][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
				D_2: if (n<=ROW-2) begin if (!((R[n+2][m])|(R[n][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
            D_3: if (n<=ROW-1) begin if (!((R[n+1][m-1])|(R[n+1][m])|(R[n+1][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
				E_0: if (n<=ROW-1) begin if (!((R[n+1][m-1])|(R[n+1][m])|(R[n][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
            E_1: if (n<=ROW-2) begin if (!((R[n+1][m])|(R[n+2][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
				F_0: if (n<=ROW-2) begin if (!((R[n+1][m-1])|(R[n+2][m])|(R[n+2][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
            F_1: if (n<=ROW-2) begin if (!((R[n+2][m-1])|(R[n+1][m]))) down_able = 1; else down_able = 0; end else down_able=0;
				G_0: if (n<=ROW-1) begin if (!((R[n+1][m-1])|(R[n+1][m])|(R[n+1][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
            G_1: if (n<=ROW-2) begin if (!((R[n+1][m-1])|(R[n+2][m]))) down_able = 1; else down_able = 0; end else down_able=0;
				G_2: if (n<=ROW-2) begin if (!((R[n+1][m-1])|(R[n+2][m])|(R[n+1][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
            G_3: if (n<=ROW-2) begin if (!((R[n+2][m])|(R[n+1][m+1]))) down_able = 1; else down_able = 0; end else down_able=0;
				default down_able = 0;
            endcase
        end
        else
            down_able = 0;
    end

	 
    // n  行
    always @ (posedge clk1k or negedge rst_n)
    begin
        if (!rst_n)
            n <= 5'd0;
		  else if (init)
            n <= 5'd0;
        else if (gene)//若处于gene状态，则令n=1
		      n <= 5'd1;           
        else if (refresh && keys[3])//若处于refresh状态，下落键被按下
		      n <= n + 5'd1;
		  else if (refresh && clk1_over)//若处于refresh状态，计时时间到
		      n <= n + 5'd1;
        else
            n <= n;
    end

    // m  列
    always @ (posedge clk1k or negedge rst_n)
    begin
        if (!rst_n)
            m <= 4'd0;
		  else if (init)
            m <= 5'd0;
        else if (gene)
            m <= 4'd2;  //产生的方块，放在列的中间
        else if (refresh)
        begin
            if (keys[1])//左移键被按下
                m <= m - 4'd1;
            else if (keys[0])//右移键被按下
                m <= m + 4'd1;
            else
                m <= m;
		 end
        else
            m <= m;
    end

    // new_block
    always @(*)
    begin
        if (!rst_n)
		  begin
            new_block = A_0;
		  end
        else if (gene)
        begin
            case (ran_num)
				0: new_block = A_0;
            1: new_block = B_0;
            2: new_block = B_1;
				3: new_block = C_0;
				4: new_block = C_1;
				5: new_block = D_0;
				6: new_block = D_1;
				7: new_block = E_0;
				8: new_block = E_1;
				9: new_block = F_0;
				10: new_block = F_1;
				11: new_block = G_0;
				12: new_block = G_1;
				13: new_block = A_0;
				14: new_block = B_0;
				15: new_block = G_0;
            default new_block = A_0;
            endcase
        end
        else
		  begin
            new_block = A_0;
		  end
    end

    // 整行消除都已经判断完毕
    always @(posedge clk1k or negedge rst_n)
    begin
        if (!rst_n)
            row_succ <= 0;
        else if (&REMOVE_FINISH)
            row_succ <= 1;
        else
            row_succ <= 0;
    end

    // 判断游戏是否结束
    always @(*)
    begin
       if (judge == 1 &&  row_succ == 1)
		 begin
            if (|R[0]) over = 1;
            else over = 0;
       end
       else over = 0;
    end
    

endmodule
