module AdderNetPE_woZero_woAlpha#(	parameter BIT_WIDTH_XW=8		,
					parameter BIT_WIDTH_PSUM=16		)(
	input									clk, rst_n,
	// data interface
	input	[BIT_WIDTH_XW-1:0]				i_X 		,	// unsigned number
	input	[BIT_WIDTH_XW-1:0]				i_W  		,	// unsigned number
	input	[BIT_WIDTH_PSUM-1:0]			i_PSUM 		,	// unsigned number
	// controll interface
	input									i_StoreW	,	// load weights
	input									i_NegZeroW	,	// generated off-chip, W is less than or equal to zero 

	output	[BIT_WIDTH_XW-1:0]				o_X			,  // propagate to the right PE
	output	[BIT_WIDTH_XW-1:0]				o_PSUM		   // propagate to the bottom PE
	);

// local registers 
wire	[BIT_WIDTH_XW-1:0]		w_reg;
DFFwEN #(BIT_WIDTH_XW) inst1_DFFwEN (.clk(clk),.rst_n(rst_n),.i_D(i_W),.i_EN(i_StoreW),.o_Q(w_reg));

wire 	[BIT_WIDTH_XW-1:0]		x_reg, x_bypass_reg;
wire 	en_bypass;
assign  en_bypass = i_NegZeroW;
DFFwEN #(BIT_WIDTH_XW) inst2_DFFwEN (.clk(clk),.rst_n(rst_n),.i_D(i_X),.i_EN(~en_bypass),.o_Q(x_reg));
DFFwEN #(BIT_WIDTH_XW) inst3_DFFwEN (.clk(clk),.rst_n(rst_n),.i_D(i_X),.i_EN(en_bypass),.o_Q(x_bypass_reg));

wire 	[BIT_WIDTH_PSUM-1:0]	psum_reg, psum_bypass_reg;
DFFwEN #(BIT_WIDTH_PSUM) inst4_DFFwEN (.clk(clk),.rst_n(rst_n),.i_D(i_PSUM),.i_EN(~en_bypass),.o_Q(psum_reg));
DFFwEN #(BIT_WIDTH_PSUM) inst5_DFFwEN (.clk(clk),.rst_n(rst_n),.i_D(i_PSUM),.i_EN(en_bypass),.o_Q(psum_bypass_reg));


// compute path
wire 	comp_rslt_wire;
assign comp_rslt_wire = w_reg > x_reg;
wire  	[BIT_WIDTH_XW-1:0]	mux1_rslt_wire;
assign mux1_rslt_wire = comp_rslt_wire ? x_reg : w_reg;
wire    [BIT_WIDTH_PSUM-1:0]	add_rslt;
assign add_rslt = { {(BIT_WIDTH_PSUM-BIT_WIDTH_XW){1'b0}}, mux1_rslt_wire} + psum_reg;

assign o_X = en_bypass ? x_bypass_reg : x_reg;
assign o_PSUM = en_bypass ? psum_bypass_reg : add_rslt;

endmodule
