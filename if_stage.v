`include "defines.v"

module if_stage(
    input  wire                    clk,
    input  wire                    rst,
    
    // 转移指令
    input  wire [`INST_ADDR_BUS]   jump_addr_1,
    input  wire [`INST_ADDR_BUS]   jump_addr_2,
    input  wire [`INST_ADDR_BUS]   jump_addr_3,
    input  wire [1:0]              jump_select,
    
    // 流水线暂停
    input  wire [`STALL_BUS    ]   stall,
    
    // 异常处理
    input  wire                    flush,
    input  wire [`INST_ADDR_BUS]   cp0_excaddr,
    
    // 后向传播
    output reg  [`INST_ADDR_BUS]   pc,
    output wire [`INST_ADDR_BUS]   pc_plus_4,
    output wire [`EXC_CODE_BUS ]   if_exccode_o,
    
    // 送往指令存储器
    output wire                    ice,
    output wire [`INST_ADDR_BUS]   iaddr
);
    
    assign pc_plus_4 = pc+4;
    
    reg [`INST_ADDR_BUS] pc_next;
    always @(*) begin
        case(jump_select)
        2'b00: pc_next <= pc_plus_4  ;
        2'b01: pc_next <= jump_addr_1;
        2'b10: pc_next <= jump_addr_3;
        2'b11: pc_next <= jump_addr_2;
        endcase
    end
    
    always @(posedge clk) begin
        if (rst == `CHIP_DISABLE)
            pc <= `PC_INIT;
        else if (flush == `TRUE_V)
            pc <= cp0_excaddr;
        else if (stall[0] == `NOSTOP)
            pc <= pc_next;
    end
    
    assign iaddr = pc;
    assign ice = (stall[1] == `STOP || flush) ? 0 : rst;
    assign if_exccode_o = (pc[1:0]==2'b00) ? `EXC_NONE : `EXC_ADEL;
    
endmodule