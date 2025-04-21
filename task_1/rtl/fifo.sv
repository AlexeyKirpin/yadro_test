module fifo
  #(
  parameter DATA_WIDTH = 8,
  parameter DEPTH      = 2
  )(
  input  logic                  clk_i,
  input  logic                  arstn_i,

  input  logic                  push_i,
  input  logic                  pop_i,
  input  logic [DATA_WIDTH-1:0] data_i,

  output logic [DATA_WIDTH-1:0] data_o,
  output logic                  full_o,
  output logic                  empty_o
);

  localparam DEPTH_N = $clog2( DEPTH ) + 1;

  logic [DEPTH_N-1:0]    w_ptr;
  logic [DEPTH_N-1:0]    r_ptr;
  logic [DATA_WIDTH-1:0] fifo[0:DEPTH-1];

  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if( !arstn_i )
      w_ptr   <= 0;
    else if( push_i & !full_o )
      if( w_ptr + 1 < DEPTH )
        w_ptr <= w_ptr + 1;
      else
        w_ptr <= 0;
    else
      w_ptr <= w_ptr;
  end

  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if( !arstn_i )
      r_ptr    <= 0;
    else if( pop_i & !empty_o )
      if( r_ptr + 1 < DEPTH )
        r_ptr  <= r_ptr + 1;
      else
        r_ptr  <= 0;
    else
      r_ptr    <= r_ptr;
  end

  // To write data to FIFO
  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if( push_i & !full_o )begin
      fifo[w_ptr] <= data_i;
    end
  end

  // To read data from FIFO
  always_ff @( posedge clk_i or negedge arstn_i ) begin
    if( !arstn_i )
      data_o <= 0;
    else if( pop_i & !empty_o )
      data_o <= fifo[r_ptr];
    else
      data_o <= data_o;
  end

  assign full_o  = ( ( w_ptr + 1'b1 ) == r_ptr ) && push_i;
  assign empty_o = ( w_ptr == r_ptr );

endmodule
