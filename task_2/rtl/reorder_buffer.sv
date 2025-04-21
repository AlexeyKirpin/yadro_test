module reorder_buffer
  #(
  parameter DATA_WIDTH = 8
  )(
  input  logic                  clk,
  input  logic                  rst_n,

  //AR slave interface
  input  logic [3:0]            s_arid_i,
  input  logic                  s_arvalid_i,
  output logic                  s_arready_o,

  //R slave interface
  input  logic                  s_rready_i,
  output logic [DATA_WIDTH-1:0] s_rdata_o,
  output logic [3:0]            s_rid_o,
  output logic                  s_rvalid_o,

  //AR master interface
  input  logic                  m_arready_i,
  output logic [3:0]            m_arid_o,
  output logic                  m_arvalid_o,

  //R master interface
  input  logic [DATA_WIDTH-1:0] m_rdata_i,
  input  logic [3:0]            m_rid_i,
  input  logic                  m_rvalid_i,
  output logic                  m_rready_o
);

  localparam ID_WIDTH = 4;

  logic [DATA_WIDTH+ID_WIDTH:0] mem[0:2**ID_WIDTH-1];
  logic [DATA_WIDTH+ID_WIDTH:0] mem_next[0:2**ID_WIDTH-1];
  logic [ID_WIDTH-1:0]            w_ptr;
  logic [ID_WIDTH-1:0]            r_ptr;

  assign m_arvalid_o = s_arvalid_i;
  assign s_arready_o = m_arready_i;
  assign m_arid_o    = s_arid_i;

  assign s_rvalid_o  = mem[r_ptr][DATA_WIDTH+ID_WIDTH];
  assign s_rid_o     = mem[r_ptr][DATA_WIDTH+ID_WIDTH-1:DATA_WIDTH];
  assign s_rdata_o   = mem[r_ptr][DATA_WIDTH-1:0];

  always_comb begin
    for(int i = 0; i < 2**ID_WIDTH; i++)
      m_rready_o |= !mem[i][DATA_WIDTH+ID_WIDTH];
  end

  always_ff @( posedge clk or negedge rst_n ) begin
    if( !rst_n )
      w_ptr   <= 0;
    else if( s_arvalid_i && s_arready_o )
      if( w_ptr == '1 )
        w_ptr <= 0;
      else
        w_ptr <= w_ptr + 1;
    else
      w_ptr   <= w_ptr;
  end

  always_ff @( posedge clk or negedge rst_n ) begin
    if( !rst_n )
      r_ptr   <= 0;
    else if( s_rvalid_o && s_rready_i )
      if( r_ptr == '1 )
        r_ptr <= 0;
      else
        r_ptr <= r_ptr + 1;
    else
      r_ptr   <= r_ptr;
  end

  always_comb begin
    mem_next = mem;

    if( s_arvalid_i && s_arready_o )
      mem_next[w_ptr][DATA_WIDTH+ID_WIDTH-1:DATA_WIDTH] = s_arid_i;

    if( s_rvalid_o && s_rready_i )
      mem_next[r_ptr] = 0;

    if( m_rvalid_i && m_rready_o ) begin
      if( s_arvalid_i && s_arready_o && m_rid_i == m_arid_o ) begin
        mem_next[w_ptr][DATA_WIDTH-1:0]      = m_rdata_i;
        mem_next[w_ptr][DATA_WIDTH+ID_WIDTH] = 1;
      end

      else begin
        for (int i = 0; i < 2**ID_WIDTH; i++) begin
          if (mem[i][DATA_WIDTH+ID_WIDTH-1:DATA_WIDTH] == m_rid_i) begin
            mem_next[i][DATA_WIDTH-1:0]      = m_rdata_i;
            mem_next[i][DATA_WIDTH+ID_WIDTH] = 1;
          end
        end
      end

    end
  end

  always_ff @( posedge clk or negedge rst_n ) begin
    if( !rst_n )
      for( int i = 0; i < 2**ID_WIDTH; i++ )
        mem[i] <= 0;
    else
      for( int i = 0; i < 2**ID_WIDTH; i++ )
        mem[i] <= mem_next[i];
  end

endmodule
