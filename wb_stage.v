`include "defines.v"

module wb_stage(
    input  wire                   cpu_rst_n,
    // 从访存阶段获得的信息
	input  wire [`REG_ADDR_BUS  ] wb_wa_i,
	input  wire                   wb_wreg_i,
	input  wire [`REG_BUS       ] wb_dreg_i,
	input  wire 				  wb_mreg_i,
    input  wire [`BSEL_BUS 	    ] wb_dre_i,
	input  wire 				  wb_whilo_i,
    input  wire [`DOUBLE_REG_BUS] wb_hilo_i,
	input  wire 				  wb_extendtype_i,

	// 从数据存储器读出的数据
	input  wire [`WORD_BUS      ] dm,
    // 写回目的寄存器的数据
    output wire [`REG_ADDR_BUS  ] wb_wa_o,
	output wire                   wb_wreg_o,
    output wire [`WORD_BUS      ] wb_wd_o,
	output wire 				  wb_whilo_o,
    output wire [`DOUBLE_REG_BUS] wb_hilo_o ,
/************************MFC0,MTC0 begin*******************************/
    input  wire                     cp0_we_i,
    input  wire [`REG_ADDR_BUS  ]   cp0_waddr_i,
    input  wire [`REG_BUS       ]   cp0_wdata_i,

	output wire                     cp0_we_o,
	output wire [`REG_ADDR_BUS  ]   cp0_waddr_o,
	output wire [`REG_BUS       ] 	cp0_wdata_o,

	input wire [31:0]               de_pc,
    
	output wire [31:0] debug_wb_pc      ,
    output wire [3:0]  debug_wb_rf_wen  ,
    output wire [4:0]  debug_wb_rf_wnum ,
    output wire [31:0] debug_wb_rf_wdata,
    input  wire [`STALL_BUS   ] stall
/************************MFC0,MTC0 end*********************************/
    );

    assign wb_wa_o      = (cpu_rst_n == `RST_ENABLE) ? 5'b0 : wb_wa_i;
    assign wb_wreg_o    = (stall[4] || cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_wreg_i;
	assign wb_whilo_o   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_whilo_i;
	assign wb_hilo_o    = (cpu_rst_n == `RST_ENABLE) ? 64'b0 : wb_hilo_i;
/************************MFC0,MTC0 begin*******************************/
    // 直接送至CP0协处理器的信号
	assign cp0_we_o     = (stall[4] || cpu_rst_n == `RST_ENABLE) ? 1'b0  : cp0_we_i;
	assign cp0_waddr_o  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD  : cp0_waddr_i;
	assign cp0_wdata_o  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD  : cp0_wdata_i;
/************************MFC0,MTC0 end*********************************/	
	wire [`WORD_BUS] data = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
							(wb_dre_i == 4'b1111) ? dm :
							(wb_dre_i == 4'b1100) ? {{16{dm[15]&wb_extendtype_i}},dm[15:0]} :
							(wb_dre_i == 4'b0011) ? {{16{dm[31]&wb_extendtype_i}},dm[31:16]} :
							
							(wb_dre_i == 4'b1000) ? {{24{dm[ 7]&wb_extendtype_i}},dm[7:0]} :
							(wb_dre_i == 4'b0100) ? {{24{dm[15]&wb_extendtype_i}},dm[15:8]} :
							(wb_dre_i == 4'b0010) ? {{24{dm[23]&wb_extendtype_i}},dm[23:16]} :
							(wb_dre_i == 4'b0001) ? {{24{dm[31]&wb_extendtype_i}},dm[31:24]} : `ZERO_WORD;

    assign wb_wd_o = (cpu_rst_n == `RST_ENABLE ) ? `ZERO_WORD : 
					 (wb_mreg_i == `MREG_ENABLE) ? data : wb_dreg_i;
    assign debug_wb_pc = (cpu_rst_n == `RST_ENABLE) ? 0 : de_pc;
	assign debug_wb_rf_wen = {4{wb_wreg_o}};
	assign debug_wb_rf_wnum= wb_wa_o;
	assign debug_wb_rf_wdata= wb_wd_o;
endmodule
