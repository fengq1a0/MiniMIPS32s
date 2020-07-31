`include "defines.v"
module icache(
    input  wire                        clk,
    input  wire                        cpu_rst_n,
    
    input  wire                        IM_ice_i,
    input  wire[31:0]                  IM_iaddr_i,
    output wire[31:0]                  ins_data,//直连数据
    output reg [31:0]                  reg_data,//缓存数据
    output wire                        cpu_stop,
    output    reg      from3,
    //axi
    //ar
    output wire [3 :0] arid         ,
    output wire [31:0] araddr       ,
    output wire [7 :0] arlen        ,
    output wire [2 :0] arsize       ,
    output wire [1 :0] arburst      ,
    output wire [1 :0] arlock       ,
    output wire [3 :0] arcache      ,
    output wire [2 :0] arprot       ,
    output reg         arvalid      ,
    input  wire        arready      ,
    //r
    input  wire [3 :0] rid          ,
    input  wire [31:0] rdata        ,
    input  wire [1 :0] rresp        ,
    input  wire        rlast        ,
    input  wire        rvalid       ,
    output reg         rready       ,
    //aw
    output wire [3 :0] awid         ,
    output wire [31:0] awaddr       ,
    output wire [7 :0] awlen        ,
    output wire [2 :0] awsize       ,
    output wire [1 :0] awburst      ,
    output wire [1 :0] awlock       ,
    output wire [3 :0] awcache      ,
    output wire [2 :0] awprot       ,
    output wire        awvalid      ,
    input  wire        awready      ,
    //w
    output wire [3 :0] wid          ,
    output wire [31:0] wdata        ,
    output wire [3 :0] wstrb        ,
    output wire        wlast        ,
    output wire        wvalid       ,
    input  wire        wready       ,
    //b
    input  wire [3 :0] bid          ,
    input  wire [1 :0] bresp        ,
    input  wire        bvalid       ,
    output wire        bready       
);
    // bram管理
    wire       en = 1'b1;
    wire[31:0] addr;
    reg [31:0] ram_wdata;
    
    reg       sel; // 两路片选
    reg       dwr; // 数据写使能
    reg       twr; // 标签写使能
    wire[3:0] pos; // 偏移量选取
    
    wire[3:0] w0tg_wen  = (sel == 0)             &&(twr) ? 4'b1111 : 4'b0000;      wire[31:0] w0tg_rdata;
    wire[3:0] w0b0_wen  = (sel == 0)&&(pos == 0 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b0_rdata;
    wire[3:0] w0b1_wen  = (sel == 0)&&(pos == 1 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b1_rdata;
    wire[3:0] w0b2_wen  = (sel == 0)&&(pos == 2 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b2_rdata;
    wire[3:0] w0b3_wen  = (sel == 0)&&(pos == 3 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b3_rdata;
    wire[3:0] w0b4_wen  = (sel == 0)&&(pos == 4 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b4_rdata;
    wire[3:0] w0b5_wen  = (sel == 0)&&(pos == 5 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b5_rdata;
    wire[3:0] w0b6_wen  = (sel == 0)&&(pos == 6 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b6_rdata;
    wire[3:0] w0b7_wen  = (sel == 0)&&(pos == 7 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b7_rdata;
    wire[3:0] w0b8_wen  = (sel == 0)&&(pos == 8 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b8_rdata;
    wire[3:0] w0b9_wen  = (sel == 0)&&(pos == 9 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b9_rdata;
    wire[3:0] w0b10_wen = (sel == 0)&&(pos == 10)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b10_rdata;
    wire[3:0] w0b11_wen = (sel == 0)&&(pos == 11)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b11_rdata;
    wire[3:0] w0b12_wen = (sel == 0)&&(pos == 12)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b12_rdata;
    wire[3:0] w0b13_wen = (sel == 0)&&(pos == 13)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b13_rdata;
    wire[3:0] w0b14_wen = (sel == 0)&&(pos == 14)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b14_rdata;
    wire[3:0] w0b15_wen = (sel == 0)&&(pos == 15)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w0b15_rdata;

    wire[3:0] w1tg_wen  = (sel == 1)             &&(twr) ? 4'b1111 : 4'b0000;      wire[31:0] w1tg_rdata;
    wire[3:0] w1b0_wen  = (sel == 1)&&(pos == 0 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b0_rdata;
    wire[3:0] w1b1_wen  = (sel == 1)&&(pos == 1 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b1_rdata;
    wire[3:0] w1b2_wen  = (sel == 1)&&(pos == 2 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b2_rdata;
    wire[3:0] w1b3_wen  = (sel == 1)&&(pos == 3 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b3_rdata;
    wire[3:0] w1b4_wen  = (sel == 1)&&(pos == 4 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b4_rdata;
    wire[3:0] w1b5_wen  = (sel == 1)&&(pos == 5 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b5_rdata;
    wire[3:0] w1b6_wen  = (sel == 1)&&(pos == 6 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b6_rdata;
    wire[3:0] w1b7_wen  = (sel == 1)&&(pos == 7 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b7_rdata;
    wire[3:0] w1b8_wen  = (sel == 1)&&(pos == 8 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b8_rdata;
    wire[3:0] w1b9_wen  = (sel == 1)&&(pos == 9 )&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b9_rdata;
    wire[3:0] w1b10_wen = (sel == 1)&&(pos == 10)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b10_rdata;
    wire[3:0] w1b11_wen = (sel == 1)&&(pos == 11)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b11_rdata;
    wire[3:0] w1b12_wen = (sel == 1)&&(pos == 12)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b12_rdata;
    wire[3:0] w1b13_wen = (sel == 1)&&(pos == 13)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b13_rdata;
    wire[3:0] w1b14_wen = (sel == 1)&&(pos == 14)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b14_rdata;
    wire[3:0] w1b15_wen = (sel == 1)&&(pos == 15)&&(dwr) ? 4'b1111 : 4'b0000;      wire[31:0] w1b15_rdata;
    
    cache_ram w0tg (.clka(clk),.ena(en),.wea(w0tg_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0tg_rdata ));
    cache_ram w0b0 (.clka(clk),.ena(en),.wea(w0b0_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b0_rdata ));
    cache_ram w0b1 (.clka(clk),.ena(en),.wea(w0b1_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b1_rdata ));
    cache_ram w0b2 (.clka(clk),.ena(en),.wea(w0b2_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b2_rdata ));
    cache_ram w0b3 (.clka(clk),.ena(en),.wea(w0b3_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b3_rdata ));
    cache_ram w0b4 (.clka(clk),.ena(en),.wea(w0b4_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b4_rdata ));
    cache_ram w0b5 (.clka(clk),.ena(en),.wea(w0b5_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b5_rdata ));
    cache_ram w0b6 (.clka(clk),.ena(en),.wea(w0b6_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b6_rdata ));
    cache_ram w0b7 (.clka(clk),.ena(en),.wea(w0b7_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b7_rdata ));
    cache_ram w0b8 (.clka(clk),.ena(en),.wea(w0b8_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b8_rdata ));
    cache_ram w0b9 (.clka(clk),.ena(en),.wea(w0b9_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b9_rdata ));
    cache_ram w0b10(.clka(clk),.ena(en),.wea(w0b10_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b10_rdata));
    cache_ram w0b11(.clka(clk),.ena(en),.wea(w0b11_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b11_rdata));
    cache_ram w0b12(.clka(clk),.ena(en),.wea(w0b12_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b12_rdata));
    cache_ram w0b13(.clka(clk),.ena(en),.wea(w0b13_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b13_rdata));
    cache_ram w0b14(.clka(clk),.ena(en),.wea(w0b14_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b14_rdata));
    cache_ram w0b15(.clka(clk),.ena(en),.wea(w0b15_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w0b15_rdata));
    
    cache_ram w1tg (.clka(clk),.ena(en),.wea(w1tg_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1tg_rdata ));
    cache_ram w1b0 (.clka(clk),.ena(en),.wea(w1b0_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b0_rdata ));
    cache_ram w1b1 (.clka(clk),.ena(en),.wea(w1b1_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b1_rdata ));
    cache_ram w1b2 (.clka(clk),.ena(en),.wea(w1b2_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b2_rdata ));
    cache_ram w1b3 (.clka(clk),.ena(en),.wea(w1b3_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b3_rdata ));
    cache_ram w1b4 (.clka(clk),.ena(en),.wea(w1b4_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b4_rdata ));
    cache_ram w1b5 (.clka(clk),.ena(en),.wea(w1b5_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b5_rdata ));
    cache_ram w1b6 (.clka(clk),.ena(en),.wea(w1b6_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b6_rdata ));
    cache_ram w1b7 (.clka(clk),.ena(en),.wea(w1b7_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b7_rdata ));
    cache_ram w1b8 (.clka(clk),.ena(en),.wea(w1b8_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b8_rdata ));
    cache_ram w1b9 (.clka(clk),.ena(en),.wea(w1b9_wen ),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b9_rdata ));
    cache_ram w1b10(.clka(clk),.ena(en),.wea(w1b10_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b10_rdata));
    cache_ram w1b11(.clka(clk),.ena(en),.wea(w1b11_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b11_rdata));
    cache_ram w1b12(.clka(clk),.ena(en),.wea(w1b12_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b12_rdata));
    cache_ram w1b13(.clka(clk),.ena(en),.wea(w1b13_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b13_rdata));
    cache_ram w1b14(.clka(clk),.ena(en),.wea(w1b14_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b14_rdata));
    cache_ram w1b15(.clka(clk),.ena(en),.wea(w1b15_wen),.addra(addr[12:6]),.dina(ram_wdata),.douta(w1b15_rdata));
    // reg管理
    wire lru; wire v0; wire v1;         // 读出的数据
    reg reg_wen; reg[2:0] reg_wdata;  // 数据写使能
    cache_reg creg(.clk(clk),.addr(addr[12:6]),.rdata({lru,v1,v0}),.wdata(reg_wdata),.wen(reg_wen),.rst(cpu_rst_n));
    
    // 请求缓存
    reg        is_req;
    reg        inst_req;
    reg [31:0] inst_addr;
    always @ (posedge clk) begin
        if (cpu_rst_n == `RST_ENABLE) begin
            is_req <= 0;
            inst_req  <= 0;
            inst_addr <= 0;
        end else begin
            is_req <= IM_ice_i;
            if (IM_ice_i) begin
                inst_req  <= IM_ice_i;
                inst_addr <= IM_iaddr_i;
            end
        end
    end
    // hit逻辑
    wire hit0 = (w0tg_rdata[18:0]==inst_addr[31:13]) && (v0);
    wire hit1 = (w1tg_rdata[18:0]==inst_addr[31:13]) && (v1);
    wire hit  = hit1 || hit0;
    wire[31:0] result = (~cpu_rst_n)       ?                       32'b0:
                        (inst_addr[5:2]==0 )?(hit1?w1b0_rdata :w0b0_rdata ):
                        (inst_addr[5:2]==1 )?(hit1?w1b1_rdata :w0b1_rdata ):
                        (inst_addr[5:2]==2 )?(hit1?w1b2_rdata :w0b2_rdata ):
                        (inst_addr[5:2]==3 )?(hit1?w1b3_rdata :w0b3_rdata ):
                        (inst_addr[5:2]==4 )?(hit1?w1b4_rdata :w0b4_rdata ):
                        (inst_addr[5:2]==5 )?(hit1?w1b5_rdata :w0b5_rdata ):
                        (inst_addr[5:2]==6 )?(hit1?w1b6_rdata :w0b6_rdata ):
                        (inst_addr[5:2]==7 )?(hit1?w1b7_rdata :w0b7_rdata ):
                        (inst_addr[5:2]==8 )?(hit1?w1b8_rdata :w0b8_rdata ):
                        (inst_addr[5:2]==9 )?(hit1?w1b9_rdata :w0b9_rdata ):
                        (inst_addr[5:2]==10)?(hit1?w1b10_rdata:w0b10_rdata):
                        (inst_addr[5:2]==11)?(hit1?w1b11_rdata:w0b11_rdata):
                        (inst_addr[5:2]==12)?(hit1?w1b12_rdata:w0b12_rdata):
                        (inst_addr[5:2]==13)?(hit1?w1b13_rdata:w0b13_rdata):
                        (inst_addr[5:2]==14)?(hit1?w1b14_rdata:w0b14_rdata):
                        (inst_addr[5:2]==15)?(hit1?w1b15_rdata:w0b15_rdata):0;
    
    //AXI
    assign arid    = 4'd0;
    assign araddr  = {addr[31:6],6'b0};
    assign arlen   = 8'd15;
    assign arsize  = 3'b010;
    assign arburst = 2'b01;
    assign arlock  = 2'd0;
    assign arcache = 4'd0;
    assign arprot  = 3'd0;
    
    // addr_fro
    reg addr_fro;     assign addr = addr_fro ? inst_addr : IM_iaddr_i;
    assign ins_data = result;
    // 状态机
    reg[1:0] inst_state;
    reg[3:0] cnt;
    reg      loading;
    assign   pos        = loading ? cnt : addr[5:2];
    wire     going      = (is_req||from3) ? (hit ? 0 : 1) : 0;
    assign   cpu_stop   = loading ? 1 : going;
    
    wire tt1 = lru?1:v1;
    wire tt0 = lru?v0:1;
    
    always @ (posedge clk) begin
        if (cpu_rst_n == `RST_ENABLE) begin
            // cache写入信号
            sel        <= 0;
            dwr        <= 0;
            twr        <= 0;
            
            reg_wen    <= 0;
            
            // 控制信号
            cnt        <= 0;
            inst_state <= 0;
            loading    <= 0;
            addr_fro   <= 0;
            rready     <= 0;
            reg_data   <= 0;
            arvalid    <= 0;
            from3      <= 0;
        end
        else
        case(inst_state)
            0: begin
                from3 <= 0;
                if (going) begin
                    loading    <= 1;
                    addr_fro   <= 1;
                    inst_state <= 1;
                    arvalid    <= 1;
                    reg_wen    <= 0;
                end else begin
                    addr_fro   <= 0;
                    loading    <= 0;
                    if (is_req || from3) begin
                        reg_data   <= ins_data;
                        reg_wen    <= 1;
                        reg_wdata  <= {hit0,v1,v0};
                    end else begin
                        reg_wen    <= 0;
                    end
                end
            end
            
            1: begin
                if (arready) begin
                    sel        <= lru;
                    twr        <= 1;
                    ram_wdata      <= {13'b0,addr[31:13]};
                    
                    reg_wen    <= 1;
                    reg_wdata  <= {lru,tt1,tt0};
                    
                    arvalid    <= 0;
                    rready     <= 1;
                    inst_state <= 2;
                    
                    cnt <= 15;
                end
            end
            
            2: begin
                twr     <= 0;
                reg_wen <= 0;
                
                if (rvalid) begin
                    if (rlast) begin
                        inst_state <= 3;
                        rready     <= 0;
                    end
                    dwr <= 1;
                    ram_wdata <= rdata;
                    cnt <= cnt+1;
                end else dwr <= 0;
            end
            
            3: begin
                dwr <= 0;
                inst_state <= 0;
                cnt        <= inst_addr[5:2];
                from3<=1;
            end
        endcase
    end
    
    // 忽略写
    //aw
    assign awid    = 0;
    assign awaddr  = 0;
    assign awlen   = 0;
    assign awsize  = 0;
    assign awburst = 0;
    assign awlock  = 0;
    assign awcache = 0;
    assign awprot  = 0;
    assign awvalid = 0;
    //w
    assign wid     = 0;
    assign wdata   = 0;
    assign wstrb   = 0;
    assign wlast   = 0;
    assign wvalid  = 0;
    //b
    assign bready  = 0;
endmodule
