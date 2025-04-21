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









endmodule
