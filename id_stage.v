`include "defines.v"

 module id_stage(
    input  wire                    cpu_rst_n,
    input  wire [`EXC_CODE_BUS ]   id_exccode_i,
    
    // 从取指阶段获得的数据
    input  wire [`INST_ADDR_BUS]   id_pc_i,
    input  wire [`INST_ADDR_BUS]   pc_plus_4,
    input  wire [`INST_BUS     ]   id_inst_i,
    
    // 从通用寄存器堆读出的数据 
    input  wire [`REG_BUS      ]   rd1,
    input  wire [`REG_BUS      ]   rd2,
    
    // 通用寄存器堆定向前推
    input  wire                    exe2id_wreg,
    input  wire [`REG_ADDR_BUS ]   exe2id_wa,
    input  wire [`INST_BUS     ]   exe2id_wd,
    input  wire                    mem2id_wreg,
    input  wire [`REG_ADDR_BUS ]   mem2id_wa,
    input  wire [`INST_BUS     ]   mem2id_wd,
    
    // 跳转指令相关信号
    output wire [1:0]              jump_select,
    output wire [`INST_ADDR_BUS]   jump_addr_1,
    output wire [`INST_ADDR_BUS]   jump_addr_2,
    output wire [`INST_ADDR_BUS]   jump_addr_3,
    output wire [`INST_ADDR_BUS]   ret_addr,
    
    // 送至执行阶段的译码信息
    output wire [`ALUTYPE_BUS  ]   id_alutype_o,
    output wire [`ALUOP_BUS    ]   id_aluop_o,
    output wire                    id_whilo_o,
    output wire                    id_mreg_o,
    output wire [`REG_ADDR_BUS ]   id_wa_o,
    output wire                    id_wreg_o,
    output wire [`REG_BUS      ]   id_din_o,
    
    // 送至执行阶段的源操作数1、源操作数2
    output wire [`REG_BUS      ]   id_src1_o,
    output wire [`REG_BUS      ]   id_src2_o,
    
    // 送至读通用寄存器堆端口的读使能和地址
    output wire [`REG_ADDR_BUS ]   ra1,
    output wire [`REG_ADDR_BUS ]   ra2,
    
    // 流水线暂停
    input  wire                    exe2id_mreg,    // 判断加载相关
    input  wire                    mem2id_mreg,
    output wire                    stallreq_id,    // 译码阶段暂停请求信号
    
    // 送至cp0
    output wire [`REG_ADDR_BUS ]   cp0_addr,       // CP0中寄存器的地址
    
    // 异常处理
    input  wire                    flush_im,       // 取消从指令存储器IM读出的指令
    input  wire                    id_in_delay_i,  // 处于译码阶段的指令是延迟槽指令
    output wire [`INST_ADDR_BUS]   id_pc_o,        // 处于译码阶段的指令的PC值
    output wire                    id_in_delay_o,  // 处于译码阶段的指令是延迟槽指令
    output wire                    next_delay_o,   // 下一条进入译码阶段的指令是延迟槽指令
    output wire [`EXC_CODE_BUS ]   id_exccode_o    // 处于译码阶段的指令的异常类型编码
);
    
    // 如果清空信号flush_im为1,则取出的指令为空指令
    wire [`INST_BUS] id_inst = (flush_im == `FLUSH) ? `ZERO_WORD : id_inst_i;
    
    // 提取指令字中各个字段的信息
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 
    
    /*-------------------- 第一级译码逻辑：确定当前需要译码的指令 --------------------*/
    wire inst_reg   = ~|op;   // R型指令
    // 算术运算
    wire inst_add   = inst_reg&func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_addi  = ~op[5]&~op[4]&op[3]&~op[2]&~op[1]&~op[0];
    wire inst_addu  = inst_reg&func[5]&~func[4]&~func[3]&~func[2]&~func[1]&func[0];
    wire inst_addiu = ~op[5]&~op[4]&op[3]&~op[2]&~op[1]&op[0];
    wire inst_sub   = inst_reg&func[5]&~func[4]&~func[3]&~func[2]&func[1]&~func[0];
    wire inst_subu  = inst_reg&func[5]&~func[4]&~func[3]&~func[2]&func[1]&func[0];
    wire inst_slt   = inst_reg&func[5]&~func[4]&func[3]&~func[2]&func[1]&~func[0];
    wire inst_slti  = ~op[5]&~op[4]&op[3]&~op[2]&op[1]&~op[0];
    wire inst_sltu  = inst_reg&func[5]&~func[4]&func[3]&~func[2]&func[1]&func[0];
    wire inst_sltiu = ~op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];
    wire inst_div   = inst_reg&~func[5]&func[4]&func[3]&~func[2]&func[1]&~func[0];
    wire inst_divu  = inst_reg&~func[5]&func[4]&func[3]&~func[2]&func[1]&func[0];
    wire inst_mult  = inst_reg&~func[5]&func[4]&func[3]&~func[2]&~func[1]&~func[0];
    wire inst_multu = inst_reg&~func[5]&func[4]&func[3]&~func[2]&~func[1]&func[0];
    // 逻辑运算
    wire inst_and   = inst_reg&func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_andi  = ~op[5]&~op[4]&op[3]&op[2]&~op[1]&~op[0];
    wire inst_lui   = ~op[5]&~op[4]&op[3]&op[2]&op[1]&op[0];
    wire inst_nor   = inst_reg&func[5]&~func[4]&~func[3]&func[2]&func[1]&func[0];
    wire inst_or    = inst_reg&func[5]&~func[4]&~func[3]&func[2]&~func[1]&func[0];
    wire inst_ori   = ~op[5]&~op[4]&op[3]&op[2]&~op[1]&op[0];
    wire inst_xor   = inst_reg&func[5]&~func[4]&~func[3]&func[2]&func[1]&~func[0];
    wire inst_xori  = ~op[5]&~op[4]&op[3]&op[2]&op[1]&~op[0];
    // 移位指令
    wire inst_sllv  = inst_reg&~func[5]&~func[4]&~func[3]&func[2]&~func[1]&~func[0];
    wire inst_sll   = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_srav  = inst_reg&~func[5]&~func[4]&~func[3]&func[2]&func[1]&func[0];
    wire inst_sra   = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&func[1]&func[0];
    wire inst_srlv  = inst_reg&~func[5]&~func[4]&~func[3]&func[2]&func[1]&~func[0];
    wire inst_srl   = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&func[1]&~func[0];
    // 分支跳转
    wire inst_beq   = ~op[5]&~op[4]&~op[3]&op[2]&~op[1]&~op[0];
    wire inst_bne   = ~op[5]&~op[4]&~op[3]&op[2]&~op[1]&op[0];
    wire inst_bgez  = ~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&op[0]&~rt[4]&rt[0];
    wire inst_bltz  = ~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&op[0]&~rt[4]&~rt[0];
    wire inst_bgezal= ~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&op[0]&rt[4]&rt[0];
    wire inst_bltzal= ~op[5]&~op[4]&~op[3]&~op[2]&~op[1]&op[0]&rt[4]&~rt[0];
    wire inst_bgtz  = ~op[5]&~op[4]&~op[3]&op[2]&op[1]&op[0];
    wire inst_blez  = ~op[5]&~op[4]&~op[3]&op[2]&op[1]&~op[0];
    wire inst_j     = ~op[5]&~op[4]&~op[3]&~op[2]&op[1]&~op[0];
    wire inst_jal   = ~op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0];
    wire inst_jr    = inst_reg&~func[5]&~func[4]&func[3]&~func[2]&~func[1]&~func[0];
    wire inst_jalr  = inst_reg&~func[5]&~func[4]&func[3]&~func[2]&~func[1]&func[0];
    //数据移动
    wire inst_mfhi  = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo  = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&func[1]&~func[0];
    wire inst_mthi  = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&~func[1]&func[0];
    wire inst_mtlo  = inst_reg&~func[5]&func[4]&~func[3]&~func[2]&func[1]&func[0];
    //自陷指令
    wire inst_break   = inst_reg&~func[5]&~func[4]&func[3]&func[2]&~func[1]&func[0];
    wire inst_syscall = inst_reg&~func[5]&~func[4]&func[3]&func[2]&~func[1]&~func[0];
    //访存指令
    wire inst_lb    = op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];
    wire inst_lbu   = op[5]&~op[4]&~op[3]&op[2]&~op[1]&~op[0];
    wire inst_lh    = op[5]&~op[4]&~op[3]&~op[2]&~op[1]&op[0];
    wire inst_lhu   = op[5]&~op[4]&~op[3]&op[2]&~op[1]&op[0];
    wire inst_lw    = op[5]&~op[4]&~op[3]&~op[2]&op[1]&op[0];
    wire inst_sb    = op[5]&~op[4]&op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sh    = op[5]&~op[4]&op[3]&~op[2]&~op[1]&op[0];
    wire inst_sw    = op[5]&~op[4]&op[3]&~op[2]&op[1]&op[0];
    //特权指令
    wire inst_eret  = ~op[5]&op[4]&~op[3]&~op[2]&~op[1]&~op[0]&~func[5]&func[4]&func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mfc0  = ~op[5]&op[4]&~op[3]&~op[2]&~op[1]&~op[0]&~id_inst[23];
    wire inst_mtc0  = ~op[5]&op[4]&~op[3]&~op[2]&~op[1]&~op[0]& id_inst[23];
    /*--------------------------------------------------------------------------------*/
    
    
    /*------------------------ 第二级译码逻辑：生成具体控制信号 ----------------------*/
    // 操作类型alutype
    wire inst_lsmem = inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | inst_sb | inst_sh | inst_sw;
    assign id_alutype_o[2] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_sllv|inst_sll|inst_srav|inst_sra|inst_srlv|inst_srl|
                             inst_beq|inst_bne|inst_bgez|inst_bltz|inst_bgezal|inst_bltzal|inst_bgtz|inst_blez|inst_j|inst_jal|inst_jr|inst_jalr|
                             inst_break | inst_syscall | inst_eret | inst_mtc0);
    assign id_alutype_o[1] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_and|inst_andi|inst_lui|inst_nor|inst_or|inst_ori|inst_xor|inst_xori|
                             inst_mfhi|inst_mflo|
                             inst_break | inst_syscall | inst_eret | inst_mfc0 | inst_mtc0);
    assign id_alutype_o[0] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_add|inst_addi|inst_addu|inst_addiu|inst_sub|inst_subu|inst_slt|inst_slti|inst_sltu|inst_sltiu|inst_div|inst_divu|inst_mult|inst_multu|
                             inst_mfhi|inst_mflo|
                             inst_beq|inst_bne|inst_bgez|inst_bltz|inst_bgezal|inst_bltzal|inst_bgtz|inst_blez|inst_j|inst_jal|inst_jr|inst_jalr|
                             inst_mfc0 | inst_lsmem);

    // 内部操作码aluop
    assign id_aluop_o[7]   = 1'b0;
    assign id_aluop_o[6]   = 1'b0;
    assign id_aluop_o[5]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 :
                             (inst_mfhi|inst_mflo|inst_mthi|inst_mtlo|
                              inst_lb|inst_lbu|inst_lh|inst_lhu|inst_lw|inst_sb|inst_sh|inst_sw|
                              inst_break|inst_syscall|inst_eret|inst_mfc0|inst_mtc0);
    assign id_aluop_o[4]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_lui|inst_andi|inst_nor|inst_or|inst_ori|inst_xor|inst_xori|
                              inst_sllv|inst_sll|inst_srav|inst_sra|inst_srlv|inst_srl|
                              inst_lbu|inst_lh|inst_lhu|inst_lw|inst_sb|inst_sh|inst_sw|
                              inst_eret|inst_mfc0|inst_mtc0);
    assign id_aluop_o[3]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_and|inst_sll|inst_srav|inst_sra|inst_srlv|inst_srl|
                             inst_slti|inst_sltu|inst_sltiu|inst_div|inst_divu|inst_mult|inst_multu|
                             inst_mfhi|inst_mflo|inst_mthi|inst_mtlo|
                             inst_lb|
                             inst_break|inst_syscall|inst_mfc0|inst_mtc0);
    assign id_aluop_o[2]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_and|inst_ori|inst_xor|inst_xori|inst_sllv|inst_srl|
                             inst_addiu|inst_sub|inst_subu|inst_slt|inst_divu|inst_mult|inst_multu|
                             inst_mtlo|
                             inst_lb|inst_sb|inst_sh|inst_sw|
                             inst_break|inst_syscall|inst_eret);
    assign id_aluop_o[1]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_and|inst_nor|inst_or|inst_xori|inst_sllv|inst_sra|inst_srlv|
                             inst_addi|inst_addu|inst_subu|inst_slt|inst_sltiu|inst_div|inst_multu|
                             inst_mflo|inst_mthi|
                             inst_lb|inst_lhu|inst_lw|inst_sw|
                             inst_syscall|inst_eret);
    assign id_aluop_o[0]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_and|inst_lui|inst_or|inst_xor|inst_sllv|inst_srav|inst_srlv|
                             inst_add|inst_addu|inst_sub|inst_slt|inst_sltu|inst_div|inst_mult|
                             inst_mfhi|inst_mthi|
                             inst_lb|inst_lh|inst_lw|inst_sh|
                             inst_break|inst_eret|inst_mtc0);
    
    // 写通用寄存器使能信号
    assign id_wreg_o = (inst_and|inst_andi|inst_lui|inst_nor|inst_or|inst_ori|inst_xor|inst_xori|
                        inst_sllv|inst_sll|inst_srav|inst_sra|inst_srlv|inst_srl|
                        inst_add|inst_addi|inst_addu|inst_addiu|inst_sub|inst_subu|inst_slt|inst_slti|inst_sltu|inst_sltiu|
                        inst_mfhi|inst_mflo|
                        inst_lb|inst_lbu|inst_lh|inst_lhu|inst_lw|
                        inst_bgezal|inst_bltzal|inst_jal|inst_jalr|
                        inst_mfc0);
    
    // 写入目的寄存器的地址
    wire rtsel     = inst_lui|inst_andi|inst_ori|inst_xori|inst_addi|inst_addiu|inst_slti|inst_sltiu|inst_div|inst_divu|inst_mult|inst_multu|
                     inst_lb|inst_lbu|inst_lh|inst_lhu|inst_lw|inst_mfc0;
    assign id_wa_o = (inst_bgezal|inst_bltzal|inst_jal) ? 5'b11111 :
                     rtsel ? rt : rd;
    
    // 写HILO寄存器使能信号
    assign id_whilo_o = (inst_div|inst_divu|inst_mult|inst_multu|inst_mthi|inst_mtlo);
    
    // 写回阶段数据源 1:data_ram 0:exe_stage
    assign id_mreg_o  = (inst_lb|inst_lbu|inst_lh|inst_lhu|inst_lw);
    /*------------------------------------------------------------------------------*/
    
    // 读通用寄存器堆端口1的地址为rs字段，读端口2的地址为rt字段
    assign ra1 = rs;
    assign ra2 = rt;
    // 定向前推
    wire[1:0] fwrd1 =   (cpu_rst_n == `RST_ENABLE) ? 2'b00 :
                        (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra1) ? 2'b01 :
                        (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra1) ? 2'b10 :2'b11;
    wire[1:0] fwrd2 =   (cpu_rst_n == `RST_ENABLE) ? 2'b00 :
                        (exe2id_wreg == `WRITE_ENABLE && exe2id_wa == ra2) ? 2'b01 :
                        (mem2id_wreg == `WRITE_ENABLE && mem2id_wa == ra2) ? 2'b10 :2'b11;
    // 获得访存阶段要存入数据储存器的数据
    // 可能来自执行阶段前推的数据，访存阶段前推的数据，通用寄存器堆的读端口2
    assign id_din_o =   (fwrd2 == 2'b01) ? exe2id_wd :
                        (fwrd2 == 2'b10) ? mem2id_wd :
                        (fwrd2 == 2'b11) ? rd2 : `ZERO_WORD;
    
    // 移位使能信号   (src1选择) 0 rd1   1 sa
    wire shift  = inst_sll|inst_sra|inst_srl;
    // 立即数使能信号 (src2选择) 0 rd2   1 imm_32
    wire immsel = inst_andi|inst_lui|inst_ori|inst_xori|inst_addi|inst_addiu|inst_slti|inst_sltiu|
                  inst_lb|inst_lbu|inst_lh|inst_lhu|inst_lw|inst_sb|inst_sh|inst_sw;
    // 获得立即数
    wire sext = (inst_addi|inst_addiu|inst_slti|inst_sltiu|inst_lb|inst_lbu|inst_lh|inst_lhu|inst_lw|inst_sb|inst_sh|inst_sw) ? imm[15] : 0;
    wire [31:0] imm_ext = inst_lui ? {imm,16'b0} : {{16{sext}},imm};
    // 获得源操作数1.源操作数1可能是移位位数、来自执行阶段前推的数据、来自访存阶段前推的数据、来自通用寄存器堆的读端口1
    assign id_src1_o = (shift == `SHIFT_ENABLE) ? {27'b0, sa} :
                        (fwrd1 == 2'b01) ? exe2id_wd :
                        (fwrd1 == 2'b10) ? mem2id_wd :
                        (fwrd1 == 2'b11) ? rd1 : `ZERO_WORD;
    // 获得源操作数2.源操作数2可能是立即数、来自执行阶段前推的数据、来自访存阶段前推的数据、来自通用寄存器堆的读端口2
    assign id_src2_o = (immsel == `IMM_ENABLE) ? imm_ext :
                        (fwrd2 == 2'b01) ? exe2id_wd :
                        (fwrd2 == 2'b10) ? mem2id_wd :
                        (fwrd2 == 2'b11) ? rd2 : `ZERO_WORD;
    
    // 转移指令专用
    wire lesseq =  id_src1_o[31]|(~|id_src1_o);
    wire great  =  ~lesseq;
    assign jump_select[1] = (inst_beq&id_src1_o==id_src2_o)|(inst_bne&id_src1_o!=id_src2_o)|
                            (inst_bgez&~id_src1_o[31])|(inst_bltz&id_src1_o[31])|
                            (inst_bgezal&~id_src1_o[31])|(inst_bltzal&id_src1_o[31])|
                            (inst_blez&lesseq)|(inst_bgtz&great)|inst_jr|inst_jalr;
    assign jump_select[0] = (inst_beq&id_src1_o==id_src2_o)|(inst_bne&id_src1_o!=id_src2_o)|
                            (inst_bgez&~id_src1_o[31])|(inst_bltz&id_src1_o[31])|
                            (inst_bgezal&~id_src1_o[31])|(inst_bltzal&id_src1_o[31])|
                            (inst_blez&lesseq)|(inst_bgtz&great)|inst_j|inst_jal;
    assign jump_addr_1 = {pc_plus_4[31:28],id_inst[25:0],2'b00};
    assign jump_addr_2 = pc_plus_4 + {{14{imm[15]}},imm,2'b00};
    assign jump_addr_3 = id_src1_o;
    assign ret_addr    = pc_plus_4 + 4;
/************************流水线暂停 begin*********************************/
    // 译码阶段暂停信号，解决加载相关
    // 如果当前处于执行阶段的指令是加载指令，并且与处于译码阶段指令存在数据相关，则这种数据相关属于加载相关
    // 如果当前处于访存阶段的指令是加载指令，并且与处于译码阶段指令存在数据相关，则这种数据相关也属于加载相关
    assign stallreq_id = (cpu_rst_n == `RST_ENABLE) ? `NOSTOP :
                         ((fwrd1 == 2'b01 || fwrd2 == 2'b01) && (exe2id_mreg == `TRUE_V)) ? `STOP :
                         ((fwrd1 == 2'b10 || fwrd2 == 2'b10) && (mem2id_mreg == `TRUE_V)) ? `STOP : `NOSTOP;
/************************流水线暂停 end***********************************/
/************************异常处理 begin*******************************/
    // 判断下一条指令是否为延迟槽指令
    assign next_delay_o = (inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal | inst_j | inst_jal | inst_jr | inst_jalr);
    // 判断当前处于译码阶段指令是否存在异常，并设置相应的异常类型编码
    assign id_exccode_o = (cpu_rst_n == `RST_ENABLE) ? `EXC_NONE : 
                        (id_exccode_i == `EXC_ADEL) ? id_exccode_i :
                        (!(inst_add | inst_addi | inst_addu | inst_addiu | inst_sub | inst_subu | inst_slt| inst_slti | inst_sltu | inst_sltiu | inst_div | inst_divu | inst_mult | inst_multu |
                        inst_and | inst_andi | inst_lui | inst_nor | inst_or | inst_ori | inst_xor | inst_xori | 
                        inst_sllv | inst_sll | inst_srav | inst_sra | inst_srlv | inst_srl | 
                        inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz | inst_bgezal | inst_bltzal | inst_j | inst_jal | inst_jr | inst_jalr |
                        inst_mfhi | inst_mflo | inst_mthi | inst_mtlo |
                        inst_break | inst_syscall | 
                        inst_lb | inst_lbu | inst_lh | inst_lhu | inst_lw | inst_sb | inst_sh | inst_sw |
                        inst_eret | inst_mfc0 | inst_mtc0)) ? `EXC_RI :
                       (inst_syscall == `TRUE_V ) ? `EXC_SYS : 
                       (inst_eret == `TRUE_V    ) ? `EXC_ERET : 
                       (inst_break == `TRUE_V) ? `EXC_BP : 
                        id_exccode_i;
/************************异常处理 end*********************************/
/************************MFC0,MTC0 begin*******************************/
    assign cp0_addr = (cpu_rst_n == `RST_ENABLE) ? `REG_NOP : rd;       // 获得CP0寄存器的访问地址
/************************MFC0,MTC0 end*********************************/
    // 直接送至下一阶段的信号
    assign id_pc_o = id_pc_i;
    assign id_in_delay_o = id_in_delay_i;

endmodule
