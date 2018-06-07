module wr_rd(input afi_clk,
				 input rstn,
				 output   reg [63:0] data,
				 
				 input           	 avl_ready,          //              avl.waitrequest_n
				 output   reg        avl_burstbegin,     //                 .beginbursttransfer
				 output   reg [25:0] avl_addr,           //                 .address
				 
				 input           	 avl_rdata_valid,    //                 .readdatavalid
				 input        [63:0] avl_rdata,          //                 .readdata
				 
				 output   reg [63:0] avl_wdata,          //                 .writedata
				 output       [7:0]  avl_be,             //                 .byteenable
				 output   reg        avl_read_req,       //                 .read
				 output   reg        avl_write_req,      //                 .write
				 output   reg [2:0]  avl_size,           //                 .burstcount
				 
				 input           local_init_done,    //               status.local_init_done
				 input           local_cal_success,  //                     .local_cal_success
				 input           local_cal_fail,
/////////////////////////////////////////////////////////////////////////////
				 input [23:0] w_data,
				 output       rd_fifo_req,
				 input [7:0]  rd_usedw,
				 output   reg act_sucess
				 );
				 
assign avl_be = 8'hff;
localparam IDLE = 'd0,WRITE = 'd1,READ = 'd2,READ_DATA = 'd3,PARK = 'd4;
reg [2:0] state;				 
always @(posedge afi_clk or negedge rstn)
	if(!rstn)
		begin
		state <= IDLE;
		avl_write_req <= 0;
		avl_size <= 0;
		avl_addr <= 0;
		avl_wdata <= 0;
		avl_burstbegin <= 0;	
		avl_read_req <= 0;
		data <= 0;
		end
	else case(state)
			IDLE:	begin
					if(local_cal_success)
						begin
						state <= WRITE;
						end
					else begin
							state <= IDLE;
							end
					end
			WRITE: begin
						if(avl_ready)
							begin
							avl_write_req <= 1'b1;
							avl_size <= 3'd1;
							avl_addr <= 0;
							avl_wdata <= 64'hf0f0f0f0_f0f0f0f0;
							avl_burstbegin <= 1'b1;
							state <= READ;
							end
						else begin
								state <= WRITE;
							  end
					 end
			READ: begin
					avl_write_req <= 0;
					avl_burstbegin <= 0;
					if(avl_ready)
						begin
						avl_read_req <= 1'b1;
						avl_burstbegin <= 1'b1;
						avl_addr <= 0;
						avl_size <= 3'd1;
						state <= READ_DATA;
						end
					else begin
							state <= READ;
							end
					end
			READ_DATA: begin
							avl_read_req <= 0;
							avl_burstbegin <= 0;
							if(avl_rdata_valid)
								begin
								data <= avl_rdata;
								state <= PARK;
								end
							else begin
									state <= READ_DATA;
									end
							end
			PARK:	begin
					state <= PARK;
					if(data == 64'hf0f0f0f0_f0f0f0f0)
						begin
						act_sucess <= 1'b1;
						end
					else act_sucess <= 0;
					end
			default:state <= IDLE;
			endcase
endmodule 