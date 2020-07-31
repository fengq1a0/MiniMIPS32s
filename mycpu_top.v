`include "defines.v"
module mycpu_top(
    input  wire        aclk         ,
    input  wire        aresetn      ,
    input  wire [5:0]  ext_int          ,
    //ar
    output wire [3 :0] arid         ,
    output wire [31:0] araddr       ,
    output wire [7 :0] arlen        ,
    output wire [2 :0] arsize       ,
    output wire [1 :0] arburst      ,
    output wire [1 :0] arlock       ,
    output wire [3 :0] arcache      ,
    output wire [2 :0] arprot       ,
    output wire        arvalid      ,
    input  wire        arready      ,
    //r           
    input  wire [3 :0] rid          ,
    input  wire [31:0] rdata        ,
    input  wire [1 :0] rresp        ,
    input  wire        rlast        ,
    input  wire        rvalid       ,
    output wire        rready       ,
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
    output wire        bready       ,
    //debug
    output wire [31:0] debug_wb_pc      ,
    output wire [3:0 ] debug_wb_rf_wen  ,
    output wire [4:0 ] debug_wb_rf_wnum ,
    output wire [31:0] debug_wb_rf_wdata
);

wire                  inst_sram_en   ;
wire [`INST_ADDR_BUS] inst_sram_addr ;
wire [`INST_BUS]      inst_sram_rdata;

wire                  data_sram_en   ;
wire [`BSEL_BUS     ] data_sram_wen  ;
wire [`INST_ADDR_BUS] data_sram_addr ;
wire [`INST_BUS     ] data_sram_wdata;
wire [`INST_BUS     ] data_sram_rdata;

wire [`INST_ADDR_BUS] addr;
wire [`INST_ADDR_BUS] inst_addr;
assign data_sram_addr = ((addr[31:24]==4'h8)||(addr[31:28]==4'ha)) ? {4'h0,addr[27:0]}:
                        ((addr[31:24]==4'h9)||(addr[31:28]==4'hb)) ? {4'h1,addr[27:0]}:
                        addr;
assign inst_sram_addr = ((inst_addr[31:24]==4'h8)||(inst_addr[31:28]==4'ha)) ? {4'h0,inst_addr[27:0]} :
                        ((inst_addr[31:24]==4'h9)||(inst_addr[31:28]==4'hb)) ? {4'h1,inst_addr[27:0]} :
                        inst_addr;
wire stop;
wire[4:0] stall;
MiniMIPS32 my(
    .cpu_clk_50M(aclk),
    .cpu_rst_n(aresetn),
    .int_i(ext_int),
    
    .iaddr(inst_addr),
    .ice(inst_sram_en),
    .inst(inst_sram_rdata),
    
    .dce(data_sram_en),
    .daddr(addr),
    .we(data_sram_wen),
    .din(data_sram_wdata),
    .dm(data_sram_rdata),
    
    .botb_stall_request(stop),
    
    .ostall(stall),
    
    .debug_wb_pc      (debug_wb_pc      ),
    .debug_wb_rf_wen  (debug_wb_rf_wen  ),
    .debug_wb_rf_wnum (debug_wb_rf_wnum ),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );

wire istop;
wire dstop;
assign stop = istop || dstop;

wire [3 :0] darid    ;
wire [31:0] daraddr  ;
wire [7 :0] darlen   ;
wire [2 :0] darsize  ;
wire [1 :0] darburst ;
wire [1 :0] darlock  ;
wire [3 :0] darcache ;
wire [2 :0] darprot  ;
wire        darvalid ;
wire        darready ;
                    
wire [3 :0] drid     ;
wire [31:0] drdata   ;
wire [1 :0] drresp   ;
wire        drlast   ;
wire        drvalid  ;
wire        drready  ;
                    
wire [3 :0] dawid    ;
wire [31:0] dawaddr  ;
wire [7 :0] dawlen   ;
wire [2 :0] dawsize  ;
wire [1 :0] dawburst ;
wire [1 :0] dawlock  ;
wire [3 :0] dawcache ;
wire [2 :0] dawprot  ;
wire        dawvalid ;
wire        dawready ;
                    
wire [3 :0] dwid     ;
wire [31:0] dwdata   ;
wire [3 :0] dwstrb   ;
wire        dwlast   ;
wire        dwvalid  ;
wire        dwready  ;
                    
wire [3 :0] dbid     ;
wire [1 :0] dbresp   ;
wire        dbvalid  ;
wire        dbready  ;

wire cached = !(addr[31:28]==4'ha||addr[31:28]==4'hb);
dcache bridge1(
    .clk(aclk),
	.rst(aresetn),

	.dce(data_sram_en),
	.daddr(data_sram_addr),
	.we(data_sram_wen),
	.din(data_sram_wdata),
	.dm(data_sram_rdata),
    .cached(cached),
	.stop(dstop),
        //axi
    //ar
    .arid   (darid   ),
    .araddr (daraddr ),
    .arlen  (darlen  ),
    .arsize (darsize ),
    .arburst(darburst),
    .arlock (darlock ) ,
    .arcache(darcache),
    .arprot (darprot ),
    .arvalid(darvalid),
    .arready(darready),

    .rid    (drid    ),
    .rdata  (drdata  ),
    .rresp  (drresp  ),
    .rlast  (drlast  ),
    .rvalid (drvalid ),
    .rready (drready ),

    .awid   (dawid   ),
    .awaddr (dawaddr ),
    .awlen  (dawlen  ),
    .awsize (dawsize ),
    .awburst(dawburst),
    .awlock (dawlock ),
    .awcache(dawcache),
    .awprot (dawprot ),
    .awvalid(dawvalid),
    .awready(dawready),

    .wid    (dwid    ),
    .wdata  (dwdata  ),
    .wstrb  (dwstrb  ),
    .wlast  (dwlast  ),
    .wvalid (dwvalid ),
    .wready (dwready ),

    .bid    (dbid    ),
    .bresp  (dbresp  ),
    .bvalid (dbvalid ),
    .bready (dbready )
    
    
);

wire [3 :0] iarid    ;
wire [31:0] iaraddr  ;
wire [7 :0] iarlen   ;
wire [2 :0] iarsize  ;
wire [1 :0] iarburst ;
wire [1 :0] iarlock  ;
wire [3 :0] iarcache ;
wire [2 :0] iarprot  ;
wire        iarvalid ;
wire        iarready ;
                     
wire [3 :0] irid     ;
wire [31:0] irdata   ;
wire [1 :0] irresp   ;
wire        irlast   ;
wire        irvalid  ;
wire        irready  ;
                     
wire [3 :0] iawid    ;
wire [31:0] iawaddr  ;
wire [7 :0] iawlen   ;
wire [2 :0] iawsize  ;
wire [1 :0] iawburst ;
wire [1 :0] iawlock  ;
wire [3 :0] iawcache ;
wire [2 :0] iawprot  ;
wire        iawvalid ;
wire        iawready ;
                     
wire [3 :0] iwid     ;
wire [31:0] iwdata   ;
wire [3 :0] iwstrb   ;
wire        iwlast   ;
wire        iwvalid  ;
wire        iwready  ;
                     
wire [3 :0] ibid     ;     
wire [1 :0] ibresp   ;     
wire        ibvalid  ;     
wire        ibready  ;     

wire from3;
reg inst_sel;
always @ (posedge aclk) begin
    inst_sel <= from3 ? 0 : stall[2];
end


wire [31:0] itmp1;
wire [31:0] itmp2;
assign inst_sram_rdata = inst_sel ? itmp2:itmp1;


icache bridge3(
    .clk(aclk),
    .cpu_rst_n(aresetn),
    
    .IM_ice_i   (inst_sram_en),
    .IM_iaddr_i (inst_sram_addr),
    
    .ins_data(itmp1),
    .reg_data(itmp2),
    .from3(from3),
    .cpu_stop(istop),

    //axi
    //ar
    .arid   (iarid   ),
    .araddr (iaraddr ),
    .arlen  (iarlen  ),
    .arsize (iarsize ),
    .arburst(iarburst),
    .arlock (iarlock ) ,
    .arcache(iarcache),
    .arprot (iarprot ),
    .arvalid(iarvalid),
    .arready(iarready),
             
    .rid    (irid    ),
    .rdata  (irdata  ),
    .rresp  (irresp  ),
    .rlast  (irlast  ),
    .rvalid (irvalid ),
    .rready (irready ),
             
    .awid   (iawid   ),
    .awaddr (iawaddr ),
    .awlen  (iawlen  ),
    .awsize (iawsize ),
    .awburst(iawburst),
    .awlock (iawlock ),
    .awcache(iawcache),
    .awprot (iawprot ),
    .awvalid(iawvalid),
    .awready(iawready),
             
    .wid    (iwid    ),
    .wdata  (iwdata  ),
    .wstrb  (iwstrb  ),
    .wlast  (iwlast  ),
    .wvalid (iwvalid ),
    .wready (iwready ),
             
    .bid    (ibid    ),
    .bresp  (ibresp  ),
    .bvalid (ibvalid ),
    .bready (ibready )
);
axi_crossbar_0 ha(
    .aclk(aclk),
    .aresetn(aresetn),
    
    .s_axi_arid   ({darid  ,iarid   }),
    .s_axi_araddr ({daraddr ,iaraddr }),
    .s_axi_arlen  ({darlen  ,iarlen  }),
    .s_axi_arsize ({darsize ,iarsize }),
    .s_axi_arburst({darburst,iarburst}),
    .s_axi_arlock ({darlock ,iarlock }) ,
    .s_axi_arcache({darcache,iarcache}),
    .s_axi_arprot ({darprot ,iarprot }),
    .s_axi_arqos  ( 8'd0          ),
    .s_axi_arvalid({darvalid,iarvalid}),
    .s_axi_arready({darready,iarready}),
   
    .s_axi_rid    ({drid   ,irid   }),
    .s_axi_rdata  ({drdata  ,irdata  }),
    .s_axi_rresp  ({drresp  ,irresp  }),
    .s_axi_rlast  ({drlast  ,irlast  }),
    .s_axi_rvalid ({drvalid ,irvalid }),
    .s_axi_rready ({drready ,irready }),
    
    .s_axi_awid   ({dawid  ,iawid  }),
    .s_axi_awaddr ({dawaddr ,iawaddr }),
    .s_axi_awlen  ({dawlen  ,iawlen  }),
    .s_axi_awsize ({dawsize ,iawsize }),
    .s_axi_awburst({dawburst,iawburst}),
    .s_axi_awlock ({dawlock ,iawlock }),
    .s_axi_awcache({dawcache,iawcache}),
    .s_axi_awprot ({dawprot ,iawprot }),
    .s_axi_awqos  ( 8'd0                 ),
    .s_axi_awvalid({dawvalid,iawvalid}),
    .s_axi_awready({dawready,iawready}),

    .s_axi_wdata  ({dwdata  ,iwdata  }),
    .s_axi_wstrb  ({dwstrb  ,iwstrb  }),
    .s_axi_wlast  ({dwlast  ,iwlast  }),
    .s_axi_wvalid ({dwvalid ,iwvalid }),
    .s_axi_wready ({dwready ,iwready }),
    
    .s_axi_bid    ({dbid   ,ibid  }),
    .s_axi_bresp  ({dbresp  ,ibresp  }),
    .s_axi_bvalid ({dbvalid ,ibvalid }),
    .s_axi_bready ({dbready ,ibready }),
    
    .m_axi_arid   (arid   ),
    .m_axi_araddr (araddr ),
    .m_axi_arlen  (arlen  ),
    .m_axi_arsize (arsize ),
    .m_axi_arburst(arburst),
    .m_axi_arlock (arlock ) ,
    .m_axi_arcache(arcache),
    .m_axi_arprot (arprot ),
    .m_axi_arqos      (   ),
    .m_axi_arvalid(arvalid),
    .m_axi_arready(arready),

    .m_axi_rid    (rid    ),
    .m_axi_rdata  (rdata  ),
    .m_axi_rresp  (rresp  ),
    .m_axi_rlast  (rlast  ),
    .m_axi_rvalid (rvalid ),
    .m_axi_rready (rready ),

    .m_axi_awid   (awid   ),
    .m_axi_awaddr (awaddr ),
    .m_axi_awlen  (awlen  ),
    .m_axi_awsize (awsize ),
    .m_axi_awburst(awburst),
    .m_axi_awlock (awlock ),
    .m_axi_awcache(awcache),
    .m_axi_awprot (awprot ),
    .m_axi_awqos      (   ),
    .m_axi_awvalid(awvalid),
    .m_axi_awready(awready),

    .m_axi_wdata  (wdata  ),
    .m_axi_wstrb  (wstrb  ),
    .m_axi_wlast  (wlast  ),
    .m_axi_wvalid (wvalid ),
    .m_axi_wready (wready ),

    .m_axi_bid    (bid    ),
    .m_axi_bresp  (bresp  ),
    .m_axi_bvalid (bvalid ),
    .m_axi_bready (bready )
);


endmodule
