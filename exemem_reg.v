`include "defines.v"

module exemem_reg (
    input  wire 				cpu_clk_50M,
    input  wire 				cpu_rst_n,

    // 来自执行阶段的信息
    input  wire [`ALUOP_BUS   ] exe_aluop,
    input  wire [`REG_ADDR_BUS] exe_wa,
    input  wire                 exe_wreg,
    input  wire [`REG_BUS 	  ] exe_wd,
	input  wire 				exe_mreg,
    input  wire [`REG_BUS 	  ] exe_din,
	input  wire 				exe_whilo,
    input  wire [`DOUBLE_REG_BUS] exe_hilo,
    
    // 送到访存阶段的信息 
    output reg  [`ALUOP_BUS   ] mem_aluop,
    output reg  [`REG_ADDR_BUS] mem_wa,
    output reg                  mem_wreg,
    output reg  [`REG_BUS 	  ] mem_wd,
	output reg  				mem_mreg,
    output reg  [`REG_BUS 	  ] mem_din,
	output reg  				mem_whilo,
    output reg  [`DOUBLE_REG_BUS] mem_hilo,
	
	/************************流水线暂停 begin*********************************/
    input  wire [`STALL_BUS   ] stall ,
	/************************流水线暂停 end***********************************/
/************************MFC0,MTC0 begin*******************************/
    input  wire                   exe_cp0_we,
    input  wire [`REG_ADDR_BUS  ] exe_cp0_waddr,
    input  wire [`REG_BUS       ] exe_cp0_wdata,

	output reg                    mem_cp0_we,
	output reg  [`REG_ADDR_BUS  ] mem_cp0_waddr,
	output reg  [`REG_BUS       ] mem_cp0_wdata,
/************************MFC0,MTC0 end*********************************/
/************************异常处理 begin*******************************/
    input  wire                 flush,
    input  wire [`INST_ADDR_BUS ] exe_pc,
    output reg  [`INST_ADDR_BUS ] mem_pc,
    input  wire                   exe_in_delay,
    output reg                    mem_in_delay,

    input  wire [`EXC_CODE_BUS  ] exe_exccode,
    output reg  [`EXC_CODE_BUS  ] mem_exccode
/************************异常处理 end*********************************/
    );

    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE || flush) begin
			mem_aluop              <= `MINIMIPS32_SLL;
			mem_wa 				   <= `REG_NOP;
			mem_wreg   			   <= `WRITE_DISABLE;
			mem_wd   			   <= `ZERO_WORD;
			mem_mreg  			   <= `WRITE_DISABLE;
			mem_din   			   <= `ZERO_WORD;
			mem_whilo 			   <= `WRITE_DISABLE;
			mem_hilo 		       <= `ZERO_DWORD;
/************************异常处理 begin*******************************/
        	mem_pc                 <= `PC_INIT;
       	 	mem_in_delay           <= `FALSE_V;
        	mem_exccode            <= `EXC_NONE;
/************************异常处理 end*********************************/
/************************MFC0,MTC0 begin*******************************/
	    	mem_cp0_we             <= `FALSE_V;
	    	mem_cp0_waddr          <= `ZERO_WORD;
	    	mem_cp0_wdata          <= `ZERO_WORD;
/************************MFC0,MTC0 end*********************************/
		end
	/************************流水线暂停 begin*********************************/
		else if(stall[3] == `STOP && stall[4] == `NOSTOP) begin
			mem_aluop              <= `MINIMIPS32_SLL;
			mem_wa 				   <= `REG_NOP;
			mem_wreg   			   <= `WRITE_DISABLE;
			mem_wd   			   <= `ZERO_WORD;
			mem_mreg  			   <= `WRITE_DISABLE;
			mem_din   			   <= `ZERO_WORD;
			mem_whilo 			   <= `WRITE_DISABLE;
			mem_hilo 		       <= `ZERO_DWORD;
/************************异常处理 begin*******************************/
			mem_pc                 <= `PC_INIT;
			mem_in_delay           <= `FALSE_V;
			mem_exccode            <= `EXC_NONE;
/************************异常处理 end*********************************/
/************************MFC0,MTC0 begin*******************************/
			mem_cp0_we             <= `FALSE_V;
			mem_cp0_waddr          <= `ZERO_WORD;
			mem_cp0_wdata          <= `ZERO_WORD;
/************************MFC0,MTC0 end*********************************/
		end
	/************************流水线暂停 end***********************************/
		else if(stall[4] == `NOSTOP) begin
			mem_aluop              <= exe_aluop;
			mem_wa 				   <= exe_wa;
			mem_wreg 		       <= exe_wreg;
			mem_wd 		    	   <= exe_wd;
			mem_mreg  			   <= exe_mreg;
			mem_din   			   <= exe_din;
			mem_whilo 			   <= exe_whilo;
			mem_hilo 		       <= exe_hilo;
/************************异常处理 begin*******************************/
			mem_pc                 <= exe_pc;
			mem_in_delay           <= exe_in_delay;
			mem_exccode            <= exe_exccode;
/************************异常处理 end*********************************/
/************************MFC0,MTC0 begin*******************************/
			mem_cp0_we             <= exe_cp0_we;
			mem_cp0_waddr          <= exe_cp0_waddr;
			mem_cp0_wdata          <= exe_cp0_wdata;
/************************MFC0,MTC0 end*********************************/
		end
	end
endmodule