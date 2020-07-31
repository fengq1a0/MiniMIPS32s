# MiniMIPS32s


<!-- TOC -->

- [MiniMIPS32s](#minimips32s)
  - [简介](#简介)
  - [关于前作:MiniMIPS32](#关于前作minimips32)
  - [改动集合](#改动集合)

<!-- /TOC -->

## 简介
MiniMIPS32s显然是MiniMIPS32的改进版，其s意为squeeze，即挤牙膏产品，只做了亿点点改动。  
## 关于前作:MiniMIPS32
是一个充满bug但是能莫名运行的版本

## 改动集合
溢出判断  
  
old
> ```verilog
> wire ov = (
>               (!exe_src1_i[31] && !exe_src2_t[31] && arith_tmp[31]) || 
>               (exe_src1_i[31] && exe_src2_t[31] && !arith_tmp[31])
>           );
> ```
new
> ```verilog
>     wire ov = (exe_aluop_i == `MINIMIPS32_SUB) ? 
>                    ((exe_src1_i[31] && !exe_src2_i[31] && !arthres[31])||(!exe_src1_i[31] && exe_src2_i[31] && arthres[31])) 
>                    :
>                    (exe_aluop_i == `MINIMIPS32_ADD || exe_aluop_i == `MINIMIPS32_ADDI) ? 
>                        ((exe_src1_i[31] && exe_src2_i[31] && !arthres[31])||(!exe_src1_i[31] && !exe_src2_i[31] && arthres[31])) : 0;
> ```

