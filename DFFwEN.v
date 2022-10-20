module DFFwEN #(parameter BIT_WIDTH=8)(
	input						clk, rst_n,
	input	[BIT_WIDTH-1:0]		i_D,
	input						i_EN,
	output	reg [BIT_WIDTH-1:0]		 o_Q
	);

always @(negedge clk or negedge rst_n) begin
	if (!rst_n) begin
		o_Q <= {BIT_WIDTH{1'b0}};
	end
	else begin
		if (i_EN)begin
			o_Q <= i_D;
		end
		else begin
			o_Q <= o_Q;
		end
	end
end
endmodule
