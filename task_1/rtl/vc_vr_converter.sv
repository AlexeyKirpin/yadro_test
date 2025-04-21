module vc_vr_converter
  #(
  parameter DATA_WIDTH = 8,
  parameter CREDIT_NUM = 2
  )(
  input  logic                   clk,
  input  logic                   rst_n,

  // valid/credit interface
  input  logic [DATA_WIDTH-1:0]  s_data_i,
  input  logic                   s_valid_i,
  output logic                   s_credit_o,

  // valid/ready interface
  input  logic                   m_ready_i,
  output logic [DATA_WIDTH-1:0]  m_data_o,
  output logic                   m_valid_o
);

  localparam CNT_WIDTH = $clog2(CREDIT_NUM) + 1;

  // Pointers and counters
  logic [CNT_WIDTH-1:0] cnt_credit;
  logic                 empty_fifo;

  assign m_valid_o  = !empty_fifo;
  assign s_credit_o = cnt_credit != 0;

  fifo #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .DEPTH      ( CREDIT_NUM )
    ) fifo (
    .clk_i      ( clk                    ),
    .arstn_i    ( rst_n                  ),

    .push_i     ( s_valid_i              ),
    .pop_i      ( m_ready_i && m_valid_o ),
    .data_i     ( s_data_i               ),

    .data_o     ( m_data_o               ),
    .full_o     (                        ),
    .empty_o    ( empty_fifo             )
  );

always_ff @( posedge clk or negedge rst_n ) begin
  if( !rst_n )
    cnt_credit <= CREDIT_NUM;
  else if( s_credit_o )
    cnt_credit <= cnt_credit - 1;
  else if( m_valid_o && m_ready_i )
    cnt_credit <= cnt_credit + 1;
  else
    cnt_credit <= cnt_credit;
end

endmodule
