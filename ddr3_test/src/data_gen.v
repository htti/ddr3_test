module data_gen(input clk,
				input afi_clk,
				input rstn,
				input rd_req,
				
				output [7:0] rd_usedw,
				output [63:0] data);

					 
wire hs,vs,de;
wire [23:0] rgb;					 
video_time_gen video_time_gen_inst( .clk(clk),
									.rstn(rstn),
					  
									.hs(hs),
									.vs(vs),
									.de(de),
									.rgb(rgb)
									);
wire vs_neg;
reg vs_r1,vs_r2;
always @(posedge clk or negedge rstn)
	if(!rstn)
		begin
		vs_r1 <= 0;
		vs_r2 <= 0;
		end
	else begin
		 vs_r1 <= vs;
		 vs_r2 <= vs_r1;
		 end
assign vs_neg = !vs_r1 & vs_r2;
ddr3_bfifo ddr3_bfifo_inst(
							aclr(vs_neg),
							data(rgb),
							rdclk(afi_clk),
							rdreq(rd_req),
							wrclk(clk),
							wrreq(de),
							q(data),
							rdempty(),
							rdfull(),
							rdusedw(rd_usedw),
							wrempty(),
							wrfull(),
							wrusedw());
							
endmodule