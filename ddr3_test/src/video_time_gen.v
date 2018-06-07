module video_time_gen(input clk,
					  input rstn,
					  
					  output hs,
					  output vs,
					  output de,
					  output [23:0] rgb
						);
`define HS_HVALID
`define VS_HVALID
localparam HORIZON_WIDTH = 'd12,VERTICAL_WIDTH = 'd12;
localparam HS_SYNC = 'd3,HS_BACK_PORCH = 'd4,HS_FRONT_PORCH = 'd3,
		   VS_SYNC = 'd2,VS_BACK_PORCH = 'd3,VS_FRONT_PORCH = 'd4,
		   HORIZON_VALID = 'd8,VERTICAL_VALID = 'd6;

wire [HORIZON_WIDTH -1 : 0] horizon_total;
assign horizon_total = HS_SYNC + HS_BACK_PORCH + HORIZON_VALID + HS_FRONT_PORCH;
wire [VERTICAL_WIDTH -1 : 0] vertical_total;
assign vertical_total = VS_SYNC + VS_BACK_PORCH + VERTICAL_VALID + VS_FRONT_PORCH;
////////////////////////////////////////////////////////////////////////////////////
reg [HORIZON_WIDTH -1 : 0] horizon_cnt;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		horizon_cnt <= 0;
		end
	else if(horizon_cnt == horizon_total)
			begin
			horizon_cnt <= 0;
			end
	else begin
		 horizon_cnt <= horizon_cnt + 1'b1;
		 end

reg [VERTICAL_WIDTH -1 : 0] vertical_cnt;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		vertical_cnt <= 0;
		end
	else if(horizon_cnt == horizon_total)
			begin
			if(vertical_cnt == vertical_total)
				begin
				vertical_cnt <= 0;
				end
			else vertical_cnt <= vertical_cnt + 1'b1;
			end
////////////////////////////////////////////////////////////////
//de generate
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		de <= 0;
		end
	else if((horizon_cnt >= HS_SYNC + HS_BACK_PORCH)&&(horizon_cnt < HS_SYNC + HS_BACK_PORCH + HORIZON_VALID))
			begin
			de <= 1'b1;
			end
	else de <= 1'b0;
//hs generate
`ifdef HS_HVALID
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		hs <= 0;
		end
	else if((horizon_cnt < HS_SYNC))
			begin
			hs <= 1'b0;
			end
	else hs <= 1'b1;
`endif
`ifdef HS_LVALID
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		hs <= 0;
		end
	else if((horizon_cnt < HS_SYNC))
			begin
			hs <= 1'b1;
			end
	else hs <= 1'b0;
`endif
//vs generate
`ifdef VS_HVALID
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		vs <= 0;
		end
	else if((vertical_cnt < VS_SYNC))
			begin
			vs <= 1'b0;
			end
	else vs <= 1'b1;
`endif
`ifdef VS_LVALID
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		vs <= 0;
		end
	else if((vertical_cnt < VS_SYNC))
			begin
			vs <= 1'b1;
			end
	else vs <= 1'b0;
`endif
endmodule
		
