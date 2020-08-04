`include "defines.v"

module ifid_reg(
    input  wire                    cpu_clk_50M,
    input  wire                    cpu_rst_n,
    
    // 暂停
    input  wire [`STALL_BUS    ]   stall,
    
    // 清空流水线
    input wire                     flush,
    
    // if传入
    input  wire [`INST_ADDR_BUS]   if_pc,
    input  wire [`INST_ADDR_BUS]   if_pc_plus_4,
    input  wire [`EXC_CODE_BUS ]   if_exccode,
    
    // 传出给id
    output reg  [`INST_ADDR_BUS]   id_pc,
    output reg  [`INST_ADDR_BUS]   id_pc_plus_4,
    output reg  [`EXC_CODE_BUS ]   id_exccode
    );
    
    always @(posedge cpu_clk_50M) begin
        if (cpu_rst_n == `RST_ENABLE || flush) begin
            id_pc        <= `PC_INIT;
            id_pc_plus_4 <= `PC_INIT;
            id_exccode   <= `EXC_NONE;
        end
        else if(stall[1] == `STOP && stall[2] == `NOSTOP) begin
            id_pc        <= `PC_INIT;
            id_pc_plus_4 <= `PC_INIT;
            id_exccode   <= `EXC_NONE;
        end
        else if(stall[1] == `NOSTOP) begin
            id_pc        <= if_pc;
            id_pc_plus_4 <= if_pc_plus_4;
            id_exccode   <= if_exccode;
        end
    end
    
endmodule