`include "defines.v"

module exe_stage(
    input  wire                     cpu_rst_n,
    input  wire                     cpu_clk_50M,
    
    // 从译码阶段获得的信息
    input  wire [`ALUTYPE_BUS    ]     exe_alutype_i,
    input  wire [`ALUOP_BUS      ]     exe_aluop_i,
    input  wire [`REG_BUS        ]     exe_src1_i,
    input  wire [`REG_BUS        ]     exe_src2_i,
    input  wire [`REG_ADDR_BUS   ]     exe_wa_i,
    input  wire                        exe_wreg_i,
    input  wire                        exe_mreg_i,
    input  wire [`REG_BUS        ]     exe_din_i,
    input  wire                        exe_whilo_i,
    
    // 从HILO寄存器获得的数据
    input  wire [`REG_BUS      ]    hi_i,
    input  wire [`REG_BUS      ]    lo_i,
    
    // 从访存阶段获得的HILO寄存器的值
    input  wire                        mem2exe_whilo,
    input  wire [`DOUBLE_REG_BUS    ]    mem2exe_hilo,
    
    // 从写回阶段获得的HILO寄存器的值
    input  wire                        wb2exe_whilo,
    input  wire [`DOUBLE_REG_BUS    ]    wb2exe_hilo,
    
    input  wire [`INST_ADDR_BUS]     ret_addr,
    
    // 送至执行阶段的信息
    output wire [`ALUOP_BUS        ]     exe_aluop_o,
    output wire [`REG_ADDR_BUS     ]     exe_wa_o,
    output wire                     exe_wreg_o,
    output wire [`REG_BUS         ]     exe_wd_o,
    output wire                     exe_mreg_o,
    output wire [`REG_BUS         ]     exe_din_o,
    output wire                     exe_whilo_o,
    output wire [`DOUBLE_REG_BUS]     exe_hilo_o,
    
/************************流水线暂停 begin*********************************/
    // 执行阶段暂停信号
    output wire                     stallreq_exe ,
/************************流水线暂停 end***********************************/
/************************MFC0,MTC0 begin*******************************/
    input  wire [`REG_ADDR_BUS  ]   cp0_addr_i,
    input  wire [`REG_BUS       ]   cp0_data_i,

    input  wire                     mem2exe_cp0_we,
    input  wire [`REG_ADDR_BUS  ]   mem2exe_cp0_wa,
    input  wire [`REG_BUS       ]   mem2exe_cp0_wd,
    input  wire                     wb2exe_cp0_we,
    input  wire [`REG_ADDR_BUS  ]   wb2exe_cp0_wa,
    input  wire [`REG_BUS       ]   wb2exe_cp0_wd,

    output wire                     cp0_re_o,
    output wire [`REG_ADDR_BUS  ]   cp0_raddr_o,
    output wire                     cp0_we_o,
    output wire [`REG_ADDR_BUS  ]   cp0_waddr_o,
    output wire [`REG_BUS       ]     cp0_wdata_o,
/************************MFC0,MTC0 end*********************************/
/************************异常处理 begin*******************************/
    // 延迟槽信号
    input  wire [`INST_ADDR_BUS ]   exe_pc_i,
    output wire [`INST_ADDR_BUS ]   exe_pc_o,
    input  wire                     exe_in_delay_i,
    output wire                     exe_in_delay_o,
    // 异常信号
    input  wire [`EXC_CODE_BUS  ]   exe_exccode_i,
    output wire [`EXC_CODE_BUS  ]   exe_exccode_o
/************************异常处理 end*********************************/    
    );

    // 直接传到下一阶段
    assign exe_aluop_o = (cpu_rst_n == `RST_ENABLE) ? 8'b0  : exe_aluop_i;
    assign exe_mreg_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : exe_mreg_i;
    assign exe_din_o   = (cpu_rst_n == `RST_ENABLE) ? 32'b0 : exe_din_i;
    assign exe_whilo_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : exe_whilo_i;
    assign exe_pc_o        = (cpu_rst_n == `RST_ENABLE) ? `PC_INIT : exe_pc_i;
    assign exe_in_delay_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : exe_in_delay_i;

    wire [`REG_BUS       ]      logicres;       // 保存逻辑运算的结果
    wire [`REG_BUS       ]      arthres;        // 保存算术运算的结果
    wire [`REG_BUS       ]      shiftres;       // 保存移位运算的结果
    wire [`REG_BUS       ]      moveres;        // 保存移动操作的结果
    wire [`REG_BUS       ]      hi_t;           // 保存HI寄存器的最新值
    wire [`REG_BUS       ]      lo_t;           // 保存LO寄存器的最新值
    wire [`REG_BUS       ]      memres;         // 保存访存操作的地址
    wire [`DOUBLE_REG_BUS]     mulres;         // 保存乘法操作的结果
/************************MFC0,MTC0 begin*******************************/
    wire [`REG_BUS       ]      cp0_t;          // 保存CP0中寄存器的最新值
/************************MFC0,MTC0 end*********************************/       

    // 根据内部操作码aluop进行逻辑运算
    assign logicres = (cpu_rst_n == `RST_ENABLE)  ? `ZERO_WORD : 
                      (exe_aluop_i == `MINIMIPS32_AND )  ? (exe_src1_i & exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_ANDI )  ? (exe_src1_i & exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_LUI )  ? (exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_NOR )  ? (~(exe_src1_i | exe_src2_i)) :
                      (exe_aluop_i == `MINIMIPS32_OR )  ? (exe_src1_i | exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_ORI )  ? (exe_src1_i | exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_XOR )  ? (exe_src1_i ^ exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_XORI )  ? (exe_src1_i ^ exe_src2_i) : `ZERO_WORD;
    
    //根据内部操作码aluop进行算术运算
    assign arthres = (cpu_rst_n == `RST_ENABLE)  ? `ZERO_WORD :
                     (exe_aluop_i == `MINIMIPS32_ADD )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_ADDI )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_ADDU )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_ADDIU )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_SUB )  ? (exe_src1_i - exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_SUBU )  ? (exe_src1_i - exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_SLT )  ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) :
                     (exe_aluop_i == `MINIMIPS32_SLTI )  ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) :
                     (exe_aluop_i == `MINIMIPS32_SLTU )  ?  (($unsigned(exe_src1_i) < $unsigned(exe_src2_i)) ? 32'b1 : 32'b0) :
                     (exe_aluop_i == `MINIMIPS32_SLTIU )  ? (($unsigned(exe_src1_i) < $unsigned(exe_src2_i)) ? 32'b1 : 32'b0) :
                     (exe_aluop_i == `MINIMIPS32_LB )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_LBU )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_LH )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_LHU )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_LW )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_SB )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_SH )  ? (exe_src1_i + exe_src2_i) :
                     (exe_aluop_i == `MINIMIPS32_SW )  ? (exe_src1_i + exe_src2_i) :
                    `ZERO_WORD;
    
    
    
    
    // 根据内部操作码aluop进行位移运算
    wire [31:0] SRA_tmp;
    assign SRA_tmp  = $signed(exe_src2_i) >>> exe_src1_i[4:0];
    assign shiftres = (cpu_rst_n == `RST_ENABLE)  ? `ZERO_WORD :
                      (exe_aluop_i == `MINIMIPS32_SLLV )  ? (exe_src2_i << exe_src1_i[4:0]) :
                      (exe_aluop_i == `MINIMIPS32_SLL )  ? (exe_src2_i << exe_src1_i[4:0]) :
                      (exe_aluop_i == `MINIMIPS32_SRAV )  ? (SRA_tmp) :
                      (exe_aluop_i == `MINIMIPS32_SRA )  ? (SRA_tmp) :
                      (exe_aluop_i == `MINIMIPS32_SRLV )  ? (exe_src2_i >> exe_src1_i[4:0]) :
                      (exe_aluop_i == `MINIMIPS32_SRL )  ? (exe_src2_i >> exe_src1_i[4:0]) : `ZERO_WORD;
    
/************************MFC0,MTC0 begin*******************************/
    // 根据内部操作码aluop_i，确定CP0寄存器的读/写访问信号
    assign cp0_we_o    = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                         (exe_aluop_i == `MINIMIPS32_MTC0) ? 1'b1 : 1'b0;

    assign cp0_wdata_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                         (exe_aluop_i == `MINIMIPS32_MTC0) ? exe_src2_i  : `ZERO_WORD;

    assign cp0_waddr_o = (cpu_rst_n == `RST_ENABLE) ? `REG_NOP : cp0_addr_i;

    assign cp0_raddr_o = (cpu_rst_n == `RST_ENABLE) ? `REG_NOP : cp0_addr_i;

    assign cp0_re_o    = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                         (exe_aluop_i == `MINIMIPS32_MFC0) ? 1'b1 : 1'b0;
    
    // 判断是否存在针对CP0中寄存器的数据相关，并获得CP0中寄存器的最新值
    assign cp0_t = (cp0_re_o != `READ_ENABLE) ? `ZERO_WORD : 
                   (mem2exe_cp0_we == `WRITE_ENABLE && mem2exe_cp0_wa == cp0_raddr_o) ? mem2exe_cp0_wd :
                   (wb2exe_cp0_we  == `WRITE_ENABLE && wb2exe_cp0_wa == cp0_raddr_o) ? wb2exe_cp0_wd : cp0_data_i;
/************************MFC0,MTC0 end*********************************/

    // 根据内部操作码aluop进行数据移动，得到最新的HI、LO寄存器的值          
        //根据aluop进行数据移动，得到最新的HI、LO寄存器的值
    //HI、LO也可能来自访存或写回阶段
    assign hi_t =     (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                    (mem2exe_whilo == `WRITE_ENABLE) ? mem2exe_hilo[63:32] :
                    (wb2exe_whilo == `WRITE_ENABLE) ? wb2exe_hilo[63:32] : hi_i;//记得告诉我为什么吧mem2exe写在前面
        
    assign lo_t =     (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                    (mem2exe_whilo == `WRITE_ENABLE) ? mem2exe_hilo[31:0] :
                    (wb2exe_whilo == `WRITE_ENABLE) ? wb2exe_hilo[31:0] : lo_i;//记得告诉我为什么吧mem2exe写在前面

    assign moveres = (cpu_rst_n   == `RST_ENABLE ) ? `ZERO_WORD :
                     (exe_aluop_i == `MINIMIPS32_MFHI ) ? hi_t :
                     (exe_aluop_i == `MINIMIPS32_MFLO ) ? lo_t : 
                      (exe_aluop_i == `MINIMIPS32_MFC0) ? cp0_t : `ZERO_WORD;
                      
    // 判断是否存在整数溢出异常
    //wire [31: 0] exe_src2_t = (exe_aluop_i == `MINIMIPS32_SUBU || exe_aluop_i == `MINIMIPS32_SUB) ? (~exe_src2_i) + 1 : exe_src2_i;
    //wire [31: 0] arith_tmp = exe_src1_i + exe_src2_t;
    wire ov = (exe_aluop_i == `MINIMIPS32_SUB) ? 
                    ((exe_src1_i[31] && !exe_src2_i[31] && !arthres[31])||(!exe_src1_i[31] && exe_src2_i[31] && arthres[31])) 
                    :
                    (exe_aluop_i == `MINIMIPS32_ADD || exe_aluop_i == `MINIMIPS32_ADDI) ? 
                        ((exe_src1_i[31] && exe_src2_i[31] && !arthres[31])||(!exe_src1_i[31] && !exe_src2_i[31] && arthres[31])) : 0;

    // 根据内部操作码aluop进行乘法运算，并保存送至下一阶段
    wire [`DOUBLE_REG_BUS] mul_tmp  = ($signed(exe_src1_i)*$signed(exe_src2_i));
    wire [`DOUBLE_REG_BUS] mulu_tmp = ($unsigned(exe_src1_i)*$unsigned(exe_src2_i));
    assign mulres = (exe_aluop_i == `MINIMIPS32_MULT ) ? mul_tmp :
                    (exe_aluop_i == `MINIMIPS32_MULTU ) ? mulu_tmp : 
                    (exe_aluop_i == `MINIMIPS32_MTHI ) ? ({exe_src1_i, lo_t}) : 
                    (exe_aluop_i == `MINIMIPS32_MTLO ) ? ({hi_t, exe_src1_i}) : 64'h0000000000000000;
    
/*********************** 除法指令修改 begin*******************************/    
    reg  [`DOUBLE_REG_BUS]      divres;         // 保存除法操作的结果
    assign exe_hilo_o = (cpu_rst_n   == `RST_ENABLE ) ? `ZERO_DWORD :
                        ((exe_aluop_i == `MINIMIPS32_DIV) | (exe_aluop_i == `MINIMIPS32_DIVU))   ? divres : mulres;
/*********************** 除法指令修改 end*********************************/    
    
    assign exe_wa_o   = (cpu_rst_n   == `RST_ENABLE ) ? 5'b0      : exe_wa_i;
    assign exe_wreg_o = (cpu_rst_n   == `RST_ENABLE ) ? 1'b0      : exe_wreg_i;
    
    // 根据操作类型alutype确定执行阶段最终的运算结果（既可能是待写入目的寄存器的数据，也可能是访问数据存储器的地址）
    assign exe_wd_o = (cpu_rst_n   == `RST_ENABLE ) ? `ZERO_WORD : 
                      (exe_exccode_o == `EXC_ADEL) ? exe_pc_o : 
                      (exe_alutype_i == `LOGIC    ) ? logicres  :
                      (exe_alutype_i == `ARITH    ) ? arthres  :
                      (exe_alutype_i == `MOVE     ) ? moveres  :
                      (exe_alutype_i == `SHIFT    ) ? shiftres :
                      (exe_alutype_i == `JUMP     ) ? ret_addr : `ZERO_WORD;

    // 根据ADD运算确定是否有溢出异常
    assign exe_exccode_o = (cpu_rst_n == `RST_ENABLE  ) ? `EXC_NONE : 
                        (exe_exccode_i != `EXC_NONE) ? exe_exccode_i :
                      ((exe_aluop_i == `MINIMIPS32_ADD || exe_aluop_i == `MINIMIPS32_ADDI || exe_aluop_i == `MINIMIPS32_SUB) && (ov == `TRUE_V))  ? `EXC_OV : exe_exccode_i;                  
                      
                      
                      
/*********************** 除法指令添加 begin*******************************/
    
    
        // 除法运算
    wire                   signed_div_i;
    wire [`REG_BUS          ] div_opdata1;
    wire [`REG_BUS          ] div_opdata2;
    wire                   div_start;
    reg                       div_ready;

    assign stallreq_exe = (cpu_rst_n == `RST_ENABLE) ? `NOSTOP : 
                          (((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU))  && (div_ready == `DIV_NOT_READY))  ? `STOP : `NOSTOP;

    assign div_opdata1  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                          ((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU)) ? exe_src1_i : `ZERO_WORD;

    assign div_opdata2  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                          ((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU)) ? exe_src2_i : `ZERO_WORD;                                    
    assign div_start    = (cpu_rst_n == `RST_ENABLE) ? `DIV_STOP : 
                          (((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU)) && (div_ready == `DIV_NOT_READY))  ? `DIV_START : `DIV_STOP; 

    assign signed_div_i = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                          ((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU)) ? 1'b1 : 1'b0; 

    wire   [34:0]                     div_temp;
    wire   [34:0]                     div_temp0;
    wire   [34:0]                     div_temp1;
    wire   [34:0]                     div_temp2;
    wire   [34:0]                     div_temp3;
    wire   [ 1:0]                     mul_cnt;

    //记录试商法进行了几轮，当等于16时，表示试商法结束
    reg    [ 5:0]                     cnt;

    reg    [65:0]                     dividend;
    reg    [ 1:0]                     state;
    reg    [33:0]                     divisor;
    reg    [31:0]                     temp_op1;
    reg    [31:0]                     temp_op2;
    
    wire   [33:0]                     divisor_temp;    
    wire   [33:0]                     divisor2;
    wire   [33:0]                     divisor3;
    
    assign divisor_temp = temp_op2;                   
    assign divisor2     = divisor_temp << 1;       //除数的两倍，替代乘法；
    assign divisor3     = divisor2 + divisor;      //除数的三倍；
    
    //dividend的低32位保存的是被除数、中间结果，第k次迭代结束的时候dividend[k:0]  
    //保存的就是当前得到的中间结果，dividend[32:k+1]保存的就是被除数中还没有参与运算  
    //的数据，dividend高32位是每次迭代时的被减数
    assign div_temp0 = {1'b000,dividend[63:32]} - {1'b000,`ZERO_WORD};  //部分余数与被除数的 0 倍相减；
    assign div_temp1 = {1'b000,dividend[63:32]} - {1'b0,divisor};       //部分余数与被除数的 1 倍相减；
    assign div_temp2 = {1'b000,dividend[63:32]} - {1'b0,divisor2};      //部分余数与被除数的 2 倍相减；
    assign div_temp3 = {1'b000,dividend[63:32]} - {1'b0,divisor3};      //部分余数与被除数的 3 倍相减；
    
    assign div_temp  = (div_temp3[34] == 1'b0 ) ? div_temp3 : 
                       (div_temp2[34] == 1'b0 ) ? div_temp2 : div_temp1;
                      
    assign mul_cnt   = (div_temp3[34] == 1'b0 ) ? 2'b11 : 
                       (div_temp2[34] == 1'b0 ) ? 2'b10 : 2'b01;
    
    always @ (posedge cpu_clk_50M) begin
        if (cpu_rst_n == `RST_ENABLE) begin
            state         <= `DIV_FREE;
            div_ready     <= `DIV_NOT_READY;
            divres       <= {`ZERO_WORD,`ZERO_WORD};
        end else begin
        case (state)
    //*******************   DIV_FREE状态    ***********************  
    //分三种情况：  
    //（1）开始除法运算，如果除数为0，那么进入DivByZero状态  
    //（2）开始除法运算，且除数不为0，那么进入DivOn状态，初始化cnt为0，如  
    //     果是有符号除法，且被除数或者除数为负，那么对被除数或者除数求正数的补码。  
    //     除数保存到divisor中，将被除数的最高位保存到dividend的第32位，  
    //     准备进行第一次迭代  
    //（3）没有进行除法运算，保持div_ready为0，divres为0  
    //*********************************************************** 
              `DIV_FREE: begin                       //DIV_FREE
                  if(div_start == `DIV_START) begin
                      if(div_opdata2 == `ZERO_WORD) begin        // 除数为0
                          state <= `DIV_BY_ZERO;
                      end else begin                            // 除数为0
                          state <= `DIV_ON;
                          cnt   <= 6'b000000;
                        
                        if(exe_aluop_i == `MINIMIPS32_DIV) begin
                            if(div_opdata1[31] == 1'b1 ) begin
                                temp_op1 = ~div_opdata1 + 1;    // 取正数的补码
                            end else begin
                                temp_op1 = div_opdata1;
                            end
                            if(div_opdata2[31] == 1'b1 ) begin
                                temp_op2 = ~div_opdata2 + 1;    // 取正数的补码
                            end else begin
                                temp_op2 = div_opdata2;
                            end
                        end
                        else begin//(exe_aluop_i == `MINIMIPS32_DIVU)
                            temp_op1 = div_opdata1;
                            temp_op2 = div_opdata2;
                        end
                        
                          dividend <= {`ZERO_WORD,`ZERO_WORD};
                        dividend[31:0] <= temp_op1;
                        divisor          <= temp_op2;
                    end
                end else begin     // 没有开始除法运算
                        div_ready  <= `DIV_NOT_READY;
                        divres <= {`ZERO_WORD,`ZERO_WORD};
                end              
              end

    //*******************   DivByZero状态    ********************  
    //如果进入DivByZero状态，那么直接进入DivEnd状态，除法结束，且结果为0  
    //*********************************************************** 
              `DIV_BY_ZERO: begin               //DivByZero
                 dividend <= {`ZERO_WORD,`ZERO_WORD};
                  state    <= `DIV_END;                 
              end

    //*******************   DivOn状态      ***********************  
    //（1）如果cnt不为16，那么表示试商法还没有结束，此时  
    //    如果减法结果div_temp为负，那么此次迭代结果是0；如  
    //    果减法结果div_temp为正，那么此次迭代结果是1，dividend  
    //    的最低位保存每次的迭代结果。同时保持DivOn状态，cnt加1。  
    //（2）如果cnt为16，那么表示试商法结束，如果是有符号  
    //    除法，且被除数、除数一正一负，那么将试商法的结果求正数的补码，得到最终的  
    //    结果，此处的商、余数都要求正数的补码。商保存在dividend的低32位，余数  
    //    保存在dividend的高32位。同时进入DivEnd状态。  
    //***********************************************************
              `DIV_ON: begin               //DivOn
                  if(cnt != 6'b100010) begin    //cnt不为16，表示试商法还没有结束
                    if(div_temp[34] == 1'b1) begin
                        //如果div_temp[32]为1，表示（minuend-n）结果小于0，  
                          //将dividend向左移一位，这样就将被除数还没有参与运算的  
                          //最高位加入到下一次迭代的被减数中，同时将0追加到中间结果
                        dividend <= {dividend[63:0] , 2'b00};
                    end else begin
                        //如果div_temp[32]为0，表示（minuend-n）结果大于等  
                          //于0，将减法的结果与被除数还没有参运算的最高位加入到下  
                          //一次迭代的被减数中，同时将1追加到中间结果 
                        dividend <= {div_temp[31:0] , dividend[31:0] , mul_cnt};
                    end
                    cnt <= cnt + 2;
                end else begin    //试商法结束
                
                if(exe_aluop_i == `MINIMIPS32_DIV) begin
                    if((div_opdata1[31] ^ div_opdata2[31]) == 1'b1) begin
                        dividend[31:0] <= (~dividend[31:0] + 1);    // 取正数的补码
                    end
                    if((div_opdata1[31] ^ dividend[65]) == 1'b1) begin              
                        dividend[65:34] <= (~dividend[65:34] + 1);    // 取正数的补码
                    end
                end//`MINIMIPS32_DIV则不改变dividend
                
                state <= `DIV_END;        //进入DivEnd状态 
                cnt   <= 6'b000000;       //cnt清零         
               end
              end

     //*******************   DivEnd状态    ***********************  
     //除法运算结束，divres的宽度是64位，其高32位存储余数，低32位存储商，  
     //设置输出信号div_ready为DivResultReady，表示除法结束，然后等待EX模块  
     //送来DivStop信号，当EX模块送来DivStop信号时，DIV模块回到DIV_FREE状态  
     //********************************************************** 
              `DIV_END: begin               //DivEnd
               divres <= {dividend[65:34], dividend[31:0]};  
               div_ready  <= `DIV_READY;
               if(div_start == `DIV_STOP) begin
                      state         <= `DIV_FREE;
                    div_ready     <= `DIV_NOT_READY;
                    divres      <= {`ZERO_WORD,`ZERO_WORD};           
               end              
              end
          endcase
        end
    end
/*********************** 除法指令添加 end*********************************/                  
    
endmodule