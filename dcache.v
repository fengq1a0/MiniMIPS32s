`include "defines.v"
module dcache(
    input         clk,
    input         rst,
    
    input         cached,
    
    input  wire                  dce,
    input  wire [`INST_ADDR_BUS] daddr,
    input  wire [`BSEL_BUS     ] we,
    input  wire [`INST_BUS     ] din,
    output reg  [`INST_BUS     ] dm,
    
    output reg                   stop,
    
    //axi
    //ar
    output [3 :0] arid         ,
    output [31:0] araddr       ,
    output [7 :0] arlen        ,
    output [2 :0] arsize       ,
    output [1 :0] arburst      ,
    output [1 :0] arlock        ,
    output [3 :0] arcache      ,
    output [2 :0] arprot       ,
    output        arvalid      ,
    input         arready      ,
    //r           
    input  [3 :0] rid          ,
    input  [31:0] rdata        ,
    input  [1 :0] rresp        ,
    input         rlast        ,
    input         rvalid       ,
    output        rready       ,
    //aw          
    output [3 :0] awid         ,
    output [31:0] awaddr       ,
    output [7 :0] awlen        ,
    output [2 :0] awsize       ,
    output [1 :0] awburst      ,
    output [1 :0] awlock       ,
    output [3 :0] awcache      ,
    output [2 :0] awprot       ,
    output        awvalid      ,
    input         awready      ,
    //w          
    output [3 :0] wid          ,
    output [31:0] wdata        ,
    output [3 :0] wstrb        ,
    output        wlast        ,
    output        wvalid       ,
    input         wready       ,
    //b           
    input  [3 :0] bid          ,
    input  [1 :0] bresp        ,
    input         bvalid       ,
    output        bready       
);

reg[2:0]  state;

reg[1:0]  du;
reg[1:0]  xie;


reg[31:0] addr;
reg       req;
reg       wr;
reg       won;
reg[1 :0] size;
reg[31:0] wdata_r;

reg flag;





reg[511:0] tmp;
reg [31:0] ttt;

reg[31:0] caddr;
reg       cwr;
reg[3 :0] cwe;
reg[31:0] cwdata_r;

    reg       fro;
    reg       dwr;
    reg       ddwr;
    reg       twr;
    reg[31:0]    ram_wdata;
    wire[31:0] taddr=fro ? caddr:daddr;
    reg [3:0] cnt1; reg xx; reg [3:0] cnt2;
    wire[3:0] pos=xx ? cnt1:taddr[5:2];
    wire      en = 1'b1;
    wire[3:0] tg_wen  =              (twr) ? 4'b1111 : 4'b0000;  wire[31:0] tg_rdata;
    wire[3:0] b0_wen  = (pos == 0 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b0_rdata;
    wire[3:0] b1_wen  = (pos == 1 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b1_rdata;
    wire[3:0] b2_wen  = (pos == 2 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b2_rdata;
    wire[3:0] b3_wen  = (pos == 3 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b3_rdata;
    wire[3:0] b4_wen  = (pos == 4 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b4_rdata;
    wire[3:0] b5_wen  = (pos == 5 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b5_rdata;
    wire[3:0] b6_wen  = (pos == 6 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b6_rdata;
    wire[3:0] b7_wen  = (pos == 7 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b7_rdata;
    wire[3:0] b8_wen  = (pos == 8 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b8_rdata;
    wire[3:0] b9_wen  = (pos == 9 )?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b9_rdata;
    wire[3:0] b10_wen = (pos == 10)?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b10_rdata;
    wire[3:0] b11_wen = (pos == 11)?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b11_rdata;
    wire[3:0] b12_wen = (pos == 12)?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b12_rdata;
    wire[3:0] b13_wen = (pos == 13)?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b13_rdata;
    wire[3:0] b14_wen = (pos == 14)?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b14_rdata;
    wire[3:0] b15_wen = (pos == 15)?(ddwr)?cwe:(dwr?4'b1111:4'b0000):4'b0000;  wire[31:0] b15_rdata;
    cache_ram tg (.clka(clk),.ena(en),.wea(tg_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(tg_rdata ));
    cache_ram b0 (.clka(clk),.ena(en),.wea(b0_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b0_rdata ));
    cache_ram b1 (.clka(clk),.ena(en),.wea(b1_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b1_rdata ));
    cache_ram b2 (.clka(clk),.ena(en),.wea(b2_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b2_rdata ));
    cache_ram b3 (.clka(clk),.ena(en),.wea(b3_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b3_rdata ));
    cache_ram b4 (.clka(clk),.ena(en),.wea(b4_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b4_rdata ));
    cache_ram b5 (.clka(clk),.ena(en),.wea(b5_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b5_rdata ));
    cache_ram b6 (.clka(clk),.ena(en),.wea(b6_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b6_rdata ));
    cache_ram b7 (.clka(clk),.ena(en),.wea(b7_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b7_rdata ));
    cache_ram b8 (.clka(clk),.ena(en),.wea(b8_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b8_rdata ));
    cache_ram b9 (.clka(clk),.ena(en),.wea(b9_wen ),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b9_rdata ));
    cache_ram b10(.clka(clk),.ena(en),.wea(b10_wen),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b10_rdata));
    cache_ram b11(.clka(clk),.ena(en),.wea(b11_wen),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b11_rdata));
    cache_ram b12(.clka(clk),.ena(en),.wea(b12_wen),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b12_rdata));
    cache_ram b13(.clka(clk),.ena(en),.wea(b13_wen),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b13_rdata));
    cache_ram b14(.clka(clk),.ena(en),.wea(b14_wen),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b14_rdata));
    cache_ram b15(.clka(clk),.ena(en),.wea(b15_wen),.addra(taddr[12:6]),.dina(ram_wdata),.douta(b15_rdata));
    wire hit  = (tg_rdata[18:0]==caddr[31:13]) && (tg_rdata[31]);
    wire[31:0] result = (~rst)        ?    32'b0:
                        (caddr[5:2]==0 )?b0_rdata :
                        (caddr[5:2]==1 )?b1_rdata :
                        (caddr[5:2]==2 )?b2_rdata :
                        (caddr[5:2]==3 )?b3_rdata :
                        (caddr[5:2]==4 )?b4_rdata :
                        (caddr[5:2]==5 )?b5_rdata :
                        (caddr[5:2]==6 )?b6_rdata :
                        (caddr[5:2]==7 )?b7_rdata :
                        (caddr[5:2]==8 )?b8_rdata :
                        (caddr[5:2]==9 )?b9_rdata :
                        (caddr[5:2]==10)?b10_rdata:
                        (caddr[5:2]==11)?b11_rdata:
                        (caddr[5:2]==12)?b12_rdata:
                        (caddr[5:2]==13)?b13_rdata:
                        (caddr[5:2]==14)?b14_rdata:
                        (caddr[5:2]==15)?b15_rdata:0;
    reg las;
    reg arval;
    reg awval;
    reg brea;
    reg rrea;
    reg wval;
always @ (posedge clk) begin
    if (~rst) begin
        state <= 0;
        req   <= 0;
        won   <= 0;
        stop  <= 0;
        flag  <= 0;
        arval <= 0;
        awval <= 0;
        brea  <= 0;
        rrea  <= 0;
        wval  <= 0;
        las<= 0;
        du <= 0;
        xie <= 0;
        
        ddwr  <= 0;
        fro   <= 0;
        dwr   <= 0;
        twr   <= 0;
    end else
    case (state)
        0: if (dce) begin
            if (cached) begin
                flag   <= 1;
                stop   <= 1;
                state  <= 3;
                fro    <= 1;
                xx     <= 0;
                caddr  <= daddr;
                cwr    <= (we == 4'b0000) ? `SRAMLIKE_READ : `SRAMLIKE_WRITE;
                cwe  <= we;
                cwdata_r<= din;
            end else begin
                addr  <= daddr;
                req   <= 1;
                wr    <= (we == 4'b0000) ? `SRAMLIKE_READ : `SRAMLIKE_WRITE;
                won   <= (we == 4'b0000) ? `SRAMLIKE_READ : `SRAMLIKE_WRITE;
                size  <= (we == 4'b0000) ? `SRAMLIKE_SIZE_4_BYTES :
                        (we == 4'b0001 || we == 4'b0010 || we == 4'b0100 || we == 4'b1000) ? `SRAMLIKE_SIZE_BYTE :
                        (we == 4'b0011 || we == 4'b1100) ? `SRAMLIKE_SIZE_2_BYTES :
                        (we == 4'b1111) ? `SRAMLIKE_SIZE_4_BYTES : `SRAMLIKE_SIZE_ERROR;
                wdata_r <= din;
                
                state <= 1;
                stop  <= 1;
            end
        end
        1: if (wr) begin
            if (awvalid&&awready) req <= 0;
            if (wvalid&&wready) won <= 0;
            if (((req==0)||(awvalid&&awready))&&((won==0)||(wvalid&&wready)))
            begin
                if (bvalid) begin
                    state <= 0;
                    stop  <= 0;
                end else begin
                    state <= 2;
                end
            end
        end else begin
            if (arvalid&&arready)begin
                if (rvalid) begin
                    req   <= 0;
                    dm    <= rdata;
                    state <= 0;
                    stop  <= 0;
                end else begin
                    req   <= 0;
                    state <= 2;
                end
            end
        end
        
        2: if (wr) begin
            if (bvalid) begin
                state <= 0;
                stop  <= 0;
            end
        end else begin
            if (rvalid) begin
                dm    <= rdata;
                state <= 0;
                stop  <= 0;
            end
        end
        
        3:if (hit) begin
            if (cwr) begin
                ddwr      <= 1;
                ram_wdata <= cwdata_r;
                state     <= 4;
            end else begin
                dm    <= result;
                stop  <= 0;
                flag  <= 0;
                state <= 0;
                fro   <= 0;
            end
        end else begin
            tmp   <= {
            b0_rdata ,
            b1_rdata ,
            b2_rdata ,
            b3_rdata ,
            b4_rdata ,
            b5_rdata ,
            b6_rdata ,
            b7_rdata ,
            b8_rdata ,
            b9_rdata ,
            b10_rdata,
            b11_rdata,
            b12_rdata,
            b13_rdata,
            b14_rdata,
            b15_rdata
            }; ttt<={tg_rdata[18:0],caddr[12:6],6'b0};
            state <= 5;
            du    <= 1;
            arval <= 1;
            
            if (tg_rdata[31]) begin
            xie   <= 1;
            awval <= 1;
            brea  <= 1; end
        end
        
        4:begin
            ddwr  <= 0;
            stop  <= 0;
            flag  <= 0;
            state <= 0;
            fro   <= 0;
        end
        
        5:begin
            case (du)
                1:if (arready) begin
                    arval  <= 0;
                    rrea   <= 1;
                    cnt1   <= 15;
                    dwr    <= 1;
                    xx     <= 1;
                    du     <= 2;
                    
                    twr <=1;
                    ram_wdata <= {1'b1,12'b0,caddr[31:13]};
                end
                2:
                begin twr <= 0;
                if (rvalid) begin
                    if (rlast) begin
                        du <= 0;
                        rrea<= 0;
                    end
                    ram_wdata <= rdata;
                    cnt1 <= cnt1+1;
                end
                end
            endcase
            case (xie)
                1:if (awready) begin
                    awval  <= 0;
                    wval   <= 1;
                    cnt2   <= 0;
                    xie    <= 2;
                end
                2:begin
                if (wready) begin
                    if (cnt2==14) las <= 1;
                    else if (cnt2==15) begin
                        las<=0;
                        wval <= 0;
                    end
                    
                    cnt2 <= cnt2+1;
                end
                if (bvalid) begin
                        brea <= 0;
                        xie  <= 0;
                end end
            endcase
            if (du==0 && xie==0) begin
                state<=3;
                xx   <=0;
                dwr<=0;
            end
        end
    endcase
end

//ar
assign arid    = 4'd0001;
assign araddr  = flag?{caddr[31:6],6'b0}:addr;
assign arlen   = flag? 8'd15:8'd0;
assign arsize  = flag? 3'b010:size;
assign arburst = flag? 2'b01:2'd0;
assign arlock  = flag? 2'd0:2'd0;
assign arcache = flag? 4'd0:4'd0;
assign arprot  = flag? 3'd0:3'd0;
assign arvalid = flag? arval:req&&!wr;
//r
assign rready  = flag? rrea:1'b1;

//aw
assign awid    = 4'd0001;
assign awaddr  = flag?ttt:addr;
assign awlen   = flag? 8'd15:8'd0;
assign awsize  = flag? 3'b010:size;
assign awburst = flag? 2'b01:2'd0;
assign awlock  = flag? 2'd0:2'd0;
assign awcache = flag? 4'd0:4'd0;
assign awprot  = flag? 3'd0:3'd0;
assign awvalid = flag? awval:req&&wr;
//w
assign wid     = 4'd0001;
assign wdata   = flag? cnt2 == 15 ? tmp[31:0]:
                       cnt2 == 14 ? tmp[63:32]:
                       cnt2 == 13 ? tmp[95:64]:
                       cnt2 == 12 ? tmp[127:96]:
                       cnt2 == 11 ? tmp[159:128]:
                       cnt2 == 10 ? tmp[191:160]:
                       cnt2 == 9 ? tmp[223:192]:
                       cnt2 == 8 ? tmp[255:224]:
                       cnt2 == 7 ? tmp[287:256]:
                       cnt2 == 6 ? tmp[319:288]:
                       cnt2 == 5 ? tmp[351:320]:
                       cnt2 == 4 ? tmp[383:352]:
                       cnt2 == 3 ? tmp[415:384]:
                       cnt2 == 2 ? tmp[447:416]:
                       cnt2 == 1 ? tmp[479:448]:
                       cnt2 == 0 ? tmp[511:480]:32'd0:wdata_r;
assign wstrb   = flag? 4'b1111:
                 (size==2'd0 ? 4'b0001<<addr[1:0]:size==2'd1 ? 4'b0011<<addr[1:0] : 4'b1111);
assign wlast   = flag? las:1'd1;
assign wvalid  = flag? wval:wr&&won;
//b
assign bready  = flag? brea:1'b1;

endmodule

