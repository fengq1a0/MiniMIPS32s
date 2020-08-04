`timescale 1ns / 1ps


`define RST_ENABLE      1'b0                
`define RST_DISABLE     1'b1                
`define ZERO_WORD       32'h00000000        
`define ZERO_DWORD      64'b0               
`define WRITE_ENABLE    1'b1                
`define WRITE_DISABLE   1'b0                
`define READ_ENABLE     1'b1                
`define READ_DISABLE    1'b0                
`define ALUOP_BUS       7 : 0               
`define SHIFT_ENABLE    1'b1                
`define ALUTYPE_BUS     2 : 0               
`define TRUE_V          1'b1                
`define FALSE_V         1'b0                
`define CHIP_ENABLE     1'b1                
`define CHIP_DISABLE    1'b0                
`define WORD_BUS        31: 0               
`define DOUBLE_REG_BUS  63: 0               
`define RT_ENABLE       1'b1                
`define SIGNED_EXT      1'b1                
`define IMM_ENABLE      1'b1                
`define UPPER_ENABLE    1'b1                
`define MREG_ENABLE     1'b1                
`define BSEL_BUS        3 : 0               
`define PC_INIT         32'hbfc00000        

`define INST_ADDR_BUS   31: 0               
`define INST_BUS        31: 0               


`define NOP             3'b000
`define ARITH           3'b001
`define LOGIC           3'b010
`define MOVE            3'b011
`define SHIFT           3'b100
`define JUMP            3'b101
`define PRIVILEGE       3'B110


`define MINIMIPS32_ADD             8'h01
`define MINIMIPS32_ADDI            8'h02
`define MINIMIPS32_ADDU            8'h03
`define MINIMIPS32_ADDIU           8'h04
`define MINIMIPS32_SUB             8'h05
`define MINIMIPS32_SUBU            8'h06
`define MINIMIPS32_SLT             8'h07
`define MINIMIPS32_SLTI            8'h08
`define MINIMIPS32_SLTU            8'h09
`define MINIMIPS32_SLTIU           8'h0A
`define MINIMIPS32_DIV             8'h0B
`define MINIMIPS32_DIVU            8'h0C
`define MINIMIPS32_MULT            8'h0D
`define MINIMIPS32_MULTU           8'h0E
`define MINIMIPS32_AND             8'h0F
`define MINIMIPS32_ANDI            8'h10
`define MINIMIPS32_LUI             8'h11
`define MINIMIPS32_NOR             8'h12
`define MINIMIPS32_OR              8'h13
`define MINIMIPS32_ORI             8'h14
`define MINIMIPS32_XOR             8'h15
`define MINIMIPS32_XORI            8'h16
`define MINIMIPS32_SLLV            8'h17
`define MINIMIPS32_SLL             8'h18
`define MINIMIPS32_SRAV            8'h19
`define MINIMIPS32_SRA             8'h1A
`define MINIMIPS32_SRLV            8'h1B
`define MINIMIPS32_SRL             8'h1C
`define MINIMIPS32_BEQ             8'h1D
`define MINIMIPS32_BNE             8'h1E
`define MINIMIPS32_BGEZ            8'h1F
`define MINIMIPS32_BGTZ            8'h20
`define MINIMIPS32_BLEZ            8'h21
`define MINIMIPS32_BLTZ            8'h22
`define MINIMIPS32_BGEZAL          8'h23
`define MINIMIPS32_BLTZAL          8'h24
`define MINIMIPS32_J               8'h25
`define MINIMIPS32_JAL             8'h26
`define MINIMIPS32_JR              8'h27
`define MINIMIPS32_JALR            8'h28
`define MINIMIPS32_MFHI            8'h29
`define MINIMIPS32_MFLO            8'h2A
`define MINIMIPS32_MTHI            8'h2B
`define MINIMIPS32_MTLO            8'h2C
`define MINIMIPS32_BREAK           8'h2D
`define MINIMIPS32_SYSCALL         8'h2E
`define MINIMIPS32_LB              8'h2F
`define MINIMIPS32_LBU             8'h30
`define MINIMIPS32_LH              8'h31
`define MINIMIPS32_LHU             8'h32
`define MINIMIPS32_LW              8'h33
`define MINIMIPS32_SB              8'h34
`define MINIMIPS32_SH              8'h35
`define MINIMIPS32_SW              8'h36
`define MINIMIPS32_ERET            8'h37
`define MINIMIPS32_MFC0            8'h38
`define MINIMIPS32_MTC0            8'h39

`define REG_BUS         31: 0               
`define REG_ADDR_BUS    4 : 0               
`define REG_NUM         32                  
`define REG_NOP         5'b00000            










`define STALL_BUS       4 : 0               
`define STOP            1'b1                
`define NOSTOP          1'b0                

`define DIV_FREE            2'b00           
`define DIV_BY_ZERO         2'b01           
`define DIV_ON              2'b10           
`define DIV_END             2'b11           
`define DIV_READY           1'b1            
`define DIV_NOT_READY       1'b0            
`define DIV_START           1'b1            
`define DIV_STOP            1'b0            

`define CP0_INT_BUS         5 : 0           
`define CP0_BADVADDR        8               
`define CP0_STATUS          12              
`define CP0_CAUSE           13              
`define CP0_EPC             14              

`define EXC_CODE_BUS        4 : 0           
`define EXC_INT             5'b00           
`define EXC_ADEL            5'h04           
`define EXC_ADES            5'h05           
`define EXC_SYS             5'h08           
`define EXC_BP              5'h09           
`define EXC_RI              5'h0a           
`define EXC_OV              5'h0c           
`define EXC_NONE            5'h10           
`define EXC_ERET            5'h11           
`define EXC_ADDR            32'hbfc00380    
`define EXC_INT_ADDR        32'hbfc00380    

`define NOFLUSH             1'b0            
`define FLUSH               1'b1            

`define SRAMLIKE_WRITE             	1'b1            
`define SRAMLIKE_READ              	1'b0

`define SRAMLIKE_SIZE_BYTE         	2'b00
`define SRAMLIKE_SIZE_2_BYTES      	2'b01
`define SRAMLIKE_SIZE_4_BYTES      	2'b10
`define SRAMLIKE_SIZE_ERROR        	2'b11

`define SRAMLIKE_STATE_FREE        	2'b00
`define SRAMLIKE_STATE_WAIT_DATA_OK	2'b01

`define SRAMLIKE_OK   			   	1'b1
`define SRAMLIKE_NOT_YET  		   	1'b0

`define SRAMLIKE_REQUEST   			1'b1
`define SRAMLIKE_NO_REQUEST  		1'b0
