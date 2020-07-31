`include "defines.v"

module mem_stage (
    input  wire                         cpu_rst_n,

    // 从执行阶段获得的信息
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire                         mem_wreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
	input  wire 				        mem_mreg_i,
    input  wire [`REG_BUS 	    ]       mem_din_i,
	input  wire 				        mem_whilo_i,
    input  wire [`DOUBLE_REG_BUS]       mem_hilo_i,
    
    // 送至写回阶段的信息
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire                         mem_wreg_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
	output wire 				        mem_mreg_o,
    output wire [`BSEL_BUS 	    ]       dre,
	output wire 				        mem_whilo_o,
    output wire [`DOUBLE_REG_BUS]       mem_hilo_o,
	output wire 						mem_extendtype_o,
	
	// 送至数据存储器的信号
	output wire                         dce,
	output wire [`INST_ADDR_BUS ]       daddr,
	output wire [`BSEL_BUS      ]       we,
	output wire [`REG_BUS       ]       din ,
/************************MFC0,MTC0 begin*******************************/
    input  wire                         cp0_we_i,
    input  wire [`REG_ADDR_BUS  ]       cp0_waddr_i,
    input  wire [`REG_BUS       ]       cp0_wdata_i,

	output wire                         cp0_we_o,
	output wire [`REG_ADDR_BUS  ]       cp0_waddr_o,
	output wire [`REG_BUS       ] 	    cp0_wdata_o,
/************************MFC0,MTC0 end*********************************/
/************************异常处理 begin*******************************/
    input  wire                         wb2mem_cp0_we,
    input  wire [`REG_ADDR_BUS  ]       wb2mem_cp0_wa,
    input  wire [`REG_BUS       ]       wb2mem_cp0_wd,

    input  wire [`INST_ADDR_BUS ]       mem_pc_i,
    output wire [`INST_ADDR_BUS ]       cp0_pc,
    input  wire                         mem_in_delay_i,
    output wire                         cp0_in_delay,
    input  wire [`EXC_CODE_BUS  ]       mem_exccode_i,
    output wire [`EXC_CODE_BUS  ]       cp0_exccode,
    input  wire [`WORD_BUS      ]       cp0_status,
    input  wire [`WORD_BUS      ]       cp0_cause,
    input  wire [`STALL_BUS   ] stall
/************************异常处理 end*********************************/
    );

    // 如果当前不是访存指令，则只需要把从执行阶段获得的信息直接输出
    assign mem_wa_o     = (cpu_rst_n == `RST_ENABLE) ? 5'b0  : mem_wa_i;
    assign mem_wreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_wreg_i;
    assign mem_dreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_wd_i;
    assign mem_whilo_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_whilo_i;
    assign mem_hilo_o   = (cpu_rst_n == `RST_ENABLE) ? 64'b0  : mem_hilo_i;
    assign mem_mreg_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_mreg_i;
/************************MFC0,MTC0 begin*******************************/
    // 直接送至写回阶段的信号
	assign cp0_we_o     = (cpu_rst_n == `RST_ENABLE) ? 1'b0  : cp0_we_i;
	assign cp0_waddr_o  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD  : cp0_waddr_i;
	assign cp0_wdata_o  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD  : cp0_wdata_i;
/************************MFC0,MTC0 end*********************************/
/************************异常处理 begin*******************************/
    // CP0中status寄存器和cause寄存器的最新值
    wire [`WORD_BUS] status;
    wire [`WORD_BUS] cause;

    // 判断是否存在针对CP0中寄存器的数据相关，并获得CP0中寄存器的最新值
    assign status = (wb2mem_cp0_we == `WRITE_ENABLE && wb2mem_cp0_wa == `CP0_STATUS) ? wb2mem_cp0_wd : cp0_status;
    assign cause = (wb2mem_cp0_we == `WRITE_ENABLE && wb2mem_cp0_wa == `CP0_CAUSE) ? wb2mem_cp0_wd : cp0_cause;

    // 生成输入到CP0协处理器的信号
    assign cp0_in_delay = (stall[4] || cpu_rst_n == `RST_ENABLE) ? 1'b0  : mem_in_delay_i;
    assign cp0_exccode  = (stall[4] || cpu_rst_n == `RST_ENABLE) ? `EXC_NONE : 
                          (((status[15:10] & cause[15:10]) != 8'h00 || (status[9:8] & cause[9:8]) != 2'b00) && status[1] == 1'b0 && status[0] == 1'b1) ? `EXC_INT : 
                          (mem_exccode_i != `EXC_NONE) ? mem_exccode_i :
						  (((mem_aluop_i == `MINIMIPS32_LH ||mem_aluop_i ==  `MINIMIPS32_LHU ) && daddr[0] != 1'b0) || (mem_aluop_i == `MINIMIPS32_LW && daddr[1:0] != 2'b00)) ? `EXC_ADEL : 
						  ((mem_aluop_i == `MINIMIPS32_SH  && daddr[0] != 1'b0) || (mem_aluop_i == `MINIMIPS32_SW && daddr[1:0] != 2'b00)) ? `EXC_ADES : 
						  mem_exccode_i;
    assign cp0_pc       = (stall[4] || cpu_rst_n == `RST_ENABLE) ? `PC_INIT : mem_pc_i;
/************************异常处理 end*********************************/    
    // 确定当前的访存指令
    wire inst_lb  = (mem_aluop_i == `MINIMIPS32_LB);
	wire inst_lbu = (mem_aluop_i == `MINIMIPS32_LBU);
	wire inst_lh  = (mem_aluop_i == `MINIMIPS32_LH);
	wire inst_lhu = (mem_aluop_i == `MINIMIPS32_LHU);
	wire inst_lw  = (mem_aluop_i == `MINIMIPS32_LW);
	wire inst_sb  = (mem_aluop_i == `MINIMIPS32_SB);
	wire inst_sh  = (mem_aluop_i == `MINIMIPS32_SH);
	wire inst_sw  = (mem_aluop_i == `MINIMIPS32_SW);
		
	// 获得数据存储器使能信号
	assign dce = (stall[4] || cpu_rst_n == `RST_ENABLE) ? 1'b0 :
				 (inst_lb |inst_lbu|inst_lh|inst_lhu|inst_lw |inst_sb |inst_sh |inst_sw); 

	// 是否是零扩展，0表示0扩展（字操作默认归为符号扩展）
	
	assign mem_extendtype_o = ~(inst_lbu|inst_lhu);
    
	// 获得数据存储器的访问地址
	assign daddr = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : mem_wd_i;

	assign dre = inst_lb ? (daddr[1:0]==2'b00 ? 4'b1000 :
						    daddr[1:0]==2'b01 ? 4'b0100 :
						    daddr[1:0]==2'b10 ? 4'b0010 :
						    daddr[1:0]==2'b11 ? 4'b0001 : 4'b0000) :
				 inst_lbu? (daddr[1:0]==2'b00 ? 4'b1000 :
						    daddr[1:0]==2'b01 ? 4'b0100 :
						    daddr[1:0]==2'b10 ? 4'b0010 :
						    daddr[1:0]==2'b11 ? 4'b0001 : 4'b0000) :
				 inst_lh ? (daddr[1:0]==2'b00 ? 4'b1100 :
						    daddr[1:0]==2'b10 ? 4'b0011 : 4'b0000) :
				 inst_lhu? (daddr[1:0]==2'b00 ? 4'b1100 :
						    daddr[1:0]==2'b10 ? 4'b0011 : 4'b0000) :
				 inst_lw ? (daddr[1:0]==2'b00 ? 4'b1111 : 4'b0000) : 4'b0000;

	assign we =  inst_sb ? (daddr[1:0]==2'b00 ? 4'b0001 :
						    daddr[1:0]==2'b01 ? 4'b0010 :
						    daddr[1:0]==2'b10 ? 4'b0100 :
						    daddr[1:0]==2'b11 ? 4'b1000 : 4'b0000) :
				 inst_sh ? (daddr[1:0]==2'b00 ? 4'b0011 :
						    daddr[1:0]==2'b10 ? 4'b1100 : 4'b0000) :
				 inst_sw ? (daddr[1:0]==2'b00 ? 4'b1111 : 4'b0000) :  4'b0000;

	// 缺定待写入数据存储器的数据
	wire [`WORD_BUS] din_reverse = mem_din_i;
	wire [`WORD_BUS] din_byte    = {mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0],mem_din_i[7:0]};
	wire [`WORD_BUS] din_halfword= {mem_din_i[15:0],mem_din_i[15:0]};
	assign din = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
				 (we == 4'b1111) ? din_reverse :
				 (we == 4'b1100) ? din_halfword :
				 (we == 4'b0011) ? din_halfword :
				 (we == 4'b0001) ? din_byte :
				 (we == 4'b0010) ? din_byte :
				 (we == 4'b0100) ? din_byte :
				 (we == 4'b1000) ? din_byte : `ZERO_WORD;
				 
endmodule