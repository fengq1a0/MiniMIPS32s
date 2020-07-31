`include "defines.v"

module cp0_reg(
    input  wire 				 cpu_clk_50M,
	input  wire 				 cpu_rst_n,
	input  wire 				 we,
	input  wire 				 re,
	input  wire [`REG_ADDR_BUS ] raddr,
	input  wire [`REG_ADDR_BUS ] waddr,
	input  wire [`REG_BUS      ] wdata,
	input  wire [`CP0_INT_BUS  ] int_i,
	
	input  wire [`EXC_CODE_BUS ] exccode_i,
	
	output wire 				 flush,
	output reg                   flush_im,
	output wire [`INST_ADDR_BUS] cp0_excaddr,

	output wire	[`REG_BUS      ] data_o,
	
	output wire [`REG_BUS 	   ] status_o,
	output wire [`REG_BUS 	   ] cause_o,
	
	input  wire [`INST_ADDR_BUS] pc_i,
	input  wire 				 in_delay_i,
	input  wire [`INST_ADDR_BUS ]       daddr_i,
    input  wire [`STALL_BUS   ] stall
    );

	reg [`REG_BUS] badvaddr;	// CP0��badvaddr�Ĵ���
	reg [`REG_BUS] status;		// CP0��status�Ĵ���
	reg [`REG_BUS] cause;		// CP0��cause�Ĵ���
	reg [`REG_BUS] epc;			// CP0��epc�Ĵ���

	assign status_o = status;
	assign cause_o = cause;

    // �����쳣��Ϣ���������ˮ���ź�flush
    assign flush = (cpu_rst_n == `RST_ENABLE) ? `NOFLUSH : 
                   (exccode_i != `EXC_NONE ) ? `FLUSH : `NOFLUSH;

	// ������մ�ָ��洢��IM��ȡ����ָ����ź�flush_im
    always @(posedge cpu_clk_50M) begin
        if (cpu_rst_n == `RST_ENABLE) begin
			flush_im <= `NOFLUSH;
		end else
        if (stall[4]==`NOSTOP)
        begin
			flush_im <= flush;
		end
    end

    // �����쳣
    task do_exc; begin
		if (status[1] == 0) begin
			if(in_delay_i) begin        // �ж��쳣����ָ���Ƿ�Ϊ�ӳٲ�ָ��
				cause[31] <= 1;   		// ��Ϊ�ӳٲ�ָ�cause[31]��Ϊ1
				epc       <= pc_i - 4;
			end else begin	
				cause[31] <= 0;
				epc       <= pc_i;
			end
		end
		status[1]  <= 1'b1;
		//cause[15:8]<= cause[15:8] & status[15:8];
		cause[6:2] <= exccode_i;
		if (exccode_i == `EXC_ADEL || exccode_i == `EXC_ADES)badvaddr <= daddr_i;
	end
	endtask

    // ����ERETָ��
	task do_eret; begin
		status[1]   <= 0;
	end
	endtask

	// �����쳣����������ڵ�ַ
	assign cp0_excaddr = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
						 (exccode_i == `EXC_INT   ) ? `EXC_INT_ADDR :
						 (exccode_i == `EXC_ERET && waddr == `CP0_EPC && we == `WRITE_ENABLE) ? wdata :
						 (exccode_i == `EXC_ERET  ) ? epc :
						 (exccode_i != `EXC_NONE  ) ? `EXC_ADDR : `ZERO_WORD;

    // ����CP0�Ĵ�������
    always @ (posedge cpu_clk_50M) begin
		if(cpu_rst_n == `RST_ENABLE) begin
            badvaddr 	  <= `ZERO_WORD;
            status 	      <= 32'h10000000;              // status[28]Ϊ1����ʾʹ��CP0Э������
            cause 	      <= `ZERO_WORD;
            epc 		  <= `ZERO_WORD;
		end 
        else 
        begin
			cause[15:10] <= int_i;
			case (exccode_i)
				`EXC_NONE:       // ���쳣����ʱ���ж��Ƿ�Ϊд�Ĵ���ָ�д������
					if (we == `WRITE_ENABLE) begin
						case(waddr)
						 	`CP0_BADVADDR: badvaddr <= wdata;
						 	`CP0_STATUS: status <= wdata;
						 	`CP0_CAUSE: cause   <= wdata;
						 	`CP0_EPC: epc       <= wdata;
						endcase
					end
				`EXC_ERET:       // ERETָ��
					do_eret();
				default:        // �쳣����ʱ��������Ӧ�쳣
					do_exc();
			endcase
		end
	end

	// ��CP0�еļĴ���
    assign data_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                    (re != `READ_ENABLE      ) ? `ZERO_WORD :
                    (raddr == `CP0_BADVADDR  ) ? badvaddr :
				    (raddr == `CP0_STATUS    ) ? status :
				    (raddr == `CP0_CAUSE     ) ? cause :
				    (raddr == `CP0_EPC       ) ? epc : `ZERO_WORD;

endmodule
