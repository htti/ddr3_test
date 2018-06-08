module wr_rd //#(parameter)	
				(input 				 afi_clk,
				 input 				 rstn,
///////////////////////////////////write ddr buffer/////////////////////////////
				 input [23:0] 		 buf_wr_dat,
				 input [7:0]  		 buf_wr_usedw,
				 output   reg     	 buf_wr_fifo_req,
				  
///////////////////////////////////read ddr buffer/////////////////////////////
				 input [7:0]		 buf_rd_usedw,
				 output  reg  [23:0] buf_rd_dat,
				 output  reg         buf_rd_dat_en,
//////////////////////////////////uniphy interface/////////////////////////////				 
				 input           		local_init_done,    //               status.local_init_done
				 input           		local_cal_success,  //                     .local_cal_success
				 input           		local_cal_fail,
				 
				 input           	 	avl_ready,          //              avl.waitrequest_n
				 input           	 	avl_rdata_valid,    //                 .readdatavalid
				 input        [63:0] 	avl_rdata,
					
				 output   reg        	avl_burstbegin,     //                 .beginbursttransfer
				 output   reg [25:0] 	avl_addr,           //                 .address				 
				 output   reg [63:0] 	avl_wdata,          //                 .writedata
				 output       [7:0]  	avl_be,             //                 .byteenable
				 output   reg        	avl_read_req,       //                 .read
				 output   reg        	avl_write_req,      //                 .write
				 output   reg [2:0]  	avl_size,           //                 .burstcount
				 output   reg [63:0] 	data,				 

/////////////////////////////////////////////////////////////////////////////
				 output   reg act_sucess
				 );
localparam VIDEO_WIDTH = 'd1024;
localparam VIDEO_HEIGHT = 'd768;
localparam RAM_COL_LEN = 'd1024;
localparam RAM_BUR_LEN = 'd4;
localparam VIDEO_REMAINER = VIDEO_WIDTH*VIDEO_HEIGHT%RAM_BUR_LEN;
localparam RAM_ADDR_END = VIDEO_WIDTH*VIDEO_HEIGHT			 
assign avl_be = 8'hff;
localparam IDLE = 'd0,WRITE = 'd1,READ = 'd2,READ_DATA = 'd3,PARK = 'd4;

reg [3:0] cstate,nstate;
always @(posedge afi_clk or negedge rstn)
	if(!rstn)
		begin
		cstate <= IDLE;
		end
	else begin
		 cstate <= nstate;
		 end
always @(*)
	if(!rstn)
		begin
		nstate = IDLE;
		end
	else case(nstate)
			IDLE: begin
					if(local_cal_success)
						nstate = ARBITRATE;
					else nstate = IDLE;
					end
			ARBITRATE: begin
						if(buf_wr_usedw  >= 'd)
							
						end
			
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