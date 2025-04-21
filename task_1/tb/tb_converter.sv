`timescale 1ns/1ps

module tb_converter();

// Params
localparam DATA_WIDTH = 8;
localparam CREDIT_NUM = 2;

// System signals
logic                  clk_i     = 0;
logic                  arstn_i   = 0;
logic [DATA_WIDTH-1:0] s_data_i  = 0;
logic                  s_valid_i = 0;
logic                  s_credit_o;
logic                  m_ready_i = 0;
logic [DATA_WIDTH-1:0] m_data_o;
logic                  m_valid_o;

vc_vr_converter #(
  .DATA_WIDTH  ( DATA_WIDTH  ),
  .CREDIT_NUM  ( CREDIT_NUM  )
  ) converter (
  .clk         ( clk_i       ),
  .rst_n       ( arstn_i     ),
  .s_data_i    ( s_data_i    ),
  .s_valid_i   ( s_valid_i   ),
  .s_credit_o  ( s_credit_o  ),
  .m_ready_i   ( m_ready_i   ),
  .m_data_o    ( m_data_o    ),
  .m_valid_o   ( m_valid_o   )
);

always #( 10 ) clk_i <= !clk_i;

  initial begin
    @( posedge clk_i );
    arstn_i   <= 1;
    @( posedge clk_i );
    s_valid_i <= 1;
    s_data_i  <= 8'hee;
    @( posedge clk_i );
    s_valid_i <= 0;
    s_data_i  <= 8'h0;
    repeat( 5 ) @( posedge clk_i );
    m_ready_i <= 1;
    s_valid_i <= 1;
    s_data_i  <= 8'hff;
    @( posedge clk_i );
    s_data_i  <= 8'h11;
    m_ready_i <= 0;
    @( posedge clk_i );
    s_valid_i <= 0;
    repeat( 5 ) @( posedge clk_i );
    m_ready_i <= 1;
    repeat( 4 ) @( posedge clk_i );
    m_ready_i <= 0;
  end

endmodule
