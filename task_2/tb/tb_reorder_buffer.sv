`timescale 1ns/1ps

module tb_reorder_buffer();

// Params
localparam DATA_WIDTH = 8;

// System signals
logic                  clk_i       = 0;
logic                  arstn_i     = 0;

//AR slave interface
logic [3:0]            s_arid_i    = 0;
logic                  s_arvalid_i = 0;
logic                  s_arready_o;

//R slave interface
logic                  s_rready_i  = 0;
logic [DATA_WIDTH-1:0] s_rdata_o;
logic [3:0]            s_rid_o;
logic                  s_rvalid_o;

//AR master interface
logic                  m_arready_i = 1;
logic [3:0]            m_arid_o;
logic                  m_arvalid_o;

//R master interface
logic [DATA_WIDTH-1:0] m_rdata_i   = 0;
logic [3:0]            m_rid_i     = 0;
logic                  m_rvalid_i  = 0;
logic                  m_rready_o;

reorder_buffer #(
  .DATA_WIDTH  ( DATA_WIDTH  )
  ) buff (
  .clk         ( clk_i       ),
  .rst_n       ( arstn_i     ),

  //AR slave interface
  .s_arid_i    ( s_arid_i    ),
  .s_arvalid_i ( s_arvalid_i ),
  .s_arready_o ( s_arready_o ),

  //R slave interface
  .s_rready_i  ( s_rready_i  ),
  .s_rdata_o   ( s_rdata_o   ),
  .s_rid_o     ( s_rid_o     ),
  .s_rvalid_o  ( s_rvalid_o  ),

  //AR master interface
  .m_arready_i ( m_arready_i ),
  .m_arid_o    ( m_arid_o    ),
  .m_arvalid_o ( m_arvalid_o ),

  //R master interface
  .m_rdata_i   ( m_rdata_i   ),
  .m_rid_i     ( m_rid_i     ),
  .m_rvalid_i  ( m_rvalid_i  ),
  .m_rready_o  ( m_rready_o  )
);

always #( 10 ) clk_i <= !clk_i;

  initial begin
    @( posedge clk_i );
    arstn_i     <= 1;
    s_rready_i  <= 1;
    repeat (2) @( posedge clk_i );
    s_arvalid_i <= 1;
    s_arid_i    <= 4'h2;
    wait( s_arvalid_i && s_arready_o ) @( posedge clk_i );
    s_arvalid_i <= 0;
    repeat (2) @( posedge clk_i );
    s_arvalid_i <= 1;
    s_arid_i    <= 4'hb;
    wait( s_arvalid_i && s_arready_o )@( posedge clk_i );
    s_arvalid_i <= 0;
    repeat (3) @( posedge clk_i );
    s_arvalid_i <= 1;
    s_arid_i    <= 4'hf;
    wait( s_arvalid_i && s_arready_o ) @( posedge clk_i );
    s_arvalid_i <= 1;
    s_arid_i    <= 4'he;
    wait( s_arvalid_i && s_arready_o ) @( posedge clk_i );
    s_arvalid_i <= 0;
    @( posedge clk_i );
  end

  initial begin
    // @( posedge clk_i );
    wait(m_arid_o == 4'hb);
    m_rdata_i  <= 8'h1a;
    m_rid_i    <= 4'hb;
    m_rvalid_i <= 1;
    wait(m_rvalid_i && m_rready_o) @( posedge clk_i );
    m_rvalid_i <= 0;
    wait(m_arid_o == 4'hf);
    m_rdata_i  <= 8'h99;
    m_rid_i    <= 4'hf;
    m_rvalid_i <= 1;
    @( posedge clk_i );
    wait(m_rvalid_i && m_rready_o);
    m_rdata_i  <= 8'h67;
    m_rid_i    <= 4'h2;
    wait(m_rvalid_i && m_rready_o) @( posedge clk_i );
    m_rdata_i  <= 8'hee;
    m_rid_i    <= 4'he;
    wait(m_rvalid_i && m_rready_o) @( posedge clk_i );
    m_rvalid_i <= 0;
    repeat( 10 ) @( posedge clk_i );
    $finish;
  end

endmodule
