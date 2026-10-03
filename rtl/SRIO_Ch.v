`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/02 13:21:33
// Design Name: 
// Module Name: SRIO_Ch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SRIO_Ch(
    input               i_gtref_clk             ,
    input               i_rst                   ,
    input               gt0_qpll_clk_in         ,
    input               gt0_qpll_out_refclk_in  ,
//    input               gt0_qpll_lock_in        ,
    input               i_sim_train_en          ,
    output              o_gtrx_disperr_or       ,
    output              o_gtrx_notintable_or    ,
    output              o_port_error            ,
    output              o_srio_txn0             ,
    output              o_srio_txp0             ,
    input               i_srio_rxn0             ,
    input               i_srio_rxp0             ,

    input               s_axis_ireq_tvalid      , 
    output              s_axis_ireq_tready      , 
    input               s_axis_ireq_tlast       , 
    input  [63:0]       s_axis_ireq_tdata       , 
    input  [7 :0]       s_axis_ireq_tkeep       , 
    input  [31:0]       s_axis_ireq_tuser       , 
    output              m_axis_iresp_tvalid     , 
    input               m_axis_iresp_tready     , 
    output              m_axis_iresp_tlast      , 
    output [63:0]       m_axis_iresp_tdata      , 
    output [7 :0]       m_axis_iresp_tkeep      , 
    output [31:0]       m_axis_iresp_tuser      , 
    output              m_axis_treq_tvalid      , 
    input               m_axis_treq_tready      , 
    output              m_axis_treq_tlast       , 
    output [63:0]       m_axis_treq_tdata       , 
    output [7 :0]       m_axis_treq_tkeep       , 
    output [31:0]       m_axis_treq_tuser       , 
    input               s_axis_tresp_tvalid     , 
    output              s_axis_tresp_tready     , 
    input               s_axis_tresp_tlast      , 
    input  [63:0]       s_axis_tresp_tdata      , 
    input  [7 :0]       s_axis_tresp_tkeep      , 
    input  [31:0]       s_axis_tresp_tuser      ,
    output              o_log_clk               ,
    output              o_log_rst               ,
    output              o_link_initialized      ,
    output              o_port_initialized
    );

wire                    w_mode_1x               ;
wire                    w_log_clk               ;
wire                    w_phy_clk               ;
wire                    w_gt_clk                ;
wire                    w_gt_pcs_clk            ;
wire                    w_drpclk                ;
wire                    w_clk_lock              ;
wire                    w_log_rst               ;
wire                    w_link_initialized      ;
wire                    w_port_initialized      ;
wire [7 :0]             w_deviceid              ;
wire                    w_port_decode_error     ;
wire                    w_gtrx_disperr_or       ;
wire                    w_gtrx_notintable_or    ;

assign o_gtrx_disperr_or    = w_gtrx_disperr_or     ;
assign o_gtrx_notintable_or = w_gtrx_notintable_or  ;
assign o_log_clk            = w_log_clk             ;
assign o_log_rst            = w_log_rst             ;
assign o_link_initialized   = w_link_initialized    ;
assign o_port_initialized   = w_port_initialized    ;    

srio_gen2_0_srio_clk srio_clk_inst (
    .i_gtref_clk                (i_gtref_clk            ),
    .sys_rst                    (i_rst                  ),
    .mode_1x                    (w_mode_1x              ),
    
    .log_clk                    (w_log_clk              ),
    .phy_clk                    (w_phy_clk              ),
    .gt_clk                     (w_gt_clk               ),
    .gt_pcs_clk                 (w_gt_pcs_clk           ),
    .refclk                     (                       ),
    .drpclk                     (w_drpclk               ),
    .clk_lock                   (w_clk_lock             )
);  

srio_gen2_0_srio_rst srio_rst_inst (    
    .cfg_clk                    (w_log_clk             ),
    .log_clk                    (w_log_clk             ),
    .phy_clk                    (w_phy_clk             ),
    .gt_pcs_clk                 (w_gt_pcs_clk          ),
    
    .sys_rst                    (i_rst                 ),
    .port_initialized           (w_port_initialized    ),
    .phy_rcvd_link_reset        (w_phy_rcvd_link_reset ),
    .force_reinit               (0                     ),
    .clk_lock                   (w_clk_lock            ),
    .controlled_force_reinit    (w_o_force_reinit      ),
    
    .cfg_rst                    (w_cfg_rst             ),
    .log_rst                    (w_log_rst             ),
    .buf_rst                    (w_buf_rst             ),
    .phy_rst                    (w_phy_rst             ),
    .gt_pcs_rst                 (w_gt_pcs_rst          ) 
);
    
  srio_gen2_0 srio_gen2_0_inst
     (
// In support logic file for gt common signals

    .log_clk_in                 (w_log_clk          ),
    .phy_clk_in                 (w_phy_clk          ),
    .gt_clk_in                  (w_gt_clk           ),
    .gt_pcs_clk_in              (w_gt_pcs_clk       ),

    .drpclk_in                  (w_drpclk           ),

    .refclk_in                  (i_gtref_clk           ),
    .clk_lock_in                (w_clk_lock         ),

    .cfg_rst_in                 (w_cfg_rst          ),
    .log_rst_in                 (w_log_rst          ),
    .buf_rst_in                 (w_buf_rst          ),
    .phy_rst_in                 (w_phy_rst          ),
    .gt_pcs_rst_in              (w_gt_pcs_rst       ),

    .gt0_qpll_clk_in             (gt0_qpll_clk_in       ),
    .gt0_qpll_out_refclk_in      (gt0_qpll_out_refclk_in),






      .s_axi_maintr_rst           (0     ),

      .srio_rxn0                  (i_srio_rxn0),
      .srio_rxp0                  (i_srio_rxp0),

      .srio_txn0                  (o_srio_txn0),
      .srio_txp0                  (o_srio_txp0),
      .s_axis_ireq_tvalid            (s_axis_ireq_tvalid        ),
      .s_axis_ireq_tready            (s_axis_ireq_tready        ),
      .s_axis_ireq_tlast             (s_axis_ireq_tlast         ),
      .s_axis_ireq_tdata             (s_axis_ireq_tdata         ),
      .s_axis_ireq_tkeep             (s_axis_ireq_tkeep         ),
      .s_axis_ireq_tuser             (s_axis_ireq_tuser         ),

      .m_axis_iresp_tvalid           (m_axis_iresp_tvalid       ),
      .m_axis_iresp_tready           (m_axis_iresp_tready       ),
      .m_axis_iresp_tlast            (m_axis_iresp_tlast        ),
      .m_axis_iresp_tdata            (m_axis_iresp_tdata        ),
      .m_axis_iresp_tkeep            (m_axis_iresp_tkeep        ),
      .m_axis_iresp_tuser            (m_axis_iresp_tuser        ),

      .s_axis_tresp_tvalid           (s_axis_tresp_tvalid       ),
      .s_axis_tresp_tready           (s_axis_tresp_tready       ),
      .s_axis_tresp_tlast            (s_axis_tresp_tlast        ),
      .s_axis_tresp_tdata            (s_axis_tresp_tdata        ),
      .s_axis_tresp_tkeep            (s_axis_tresp_tkeep        ),
      .s_axis_tresp_tuser            (s_axis_tresp_tuser        ),

      .m_axis_treq_tvalid            (m_axis_treq_tvalid        ),
      .m_axis_treq_tready            (m_axis_treq_tready        ),
      .m_axis_treq_tlast             (m_axis_treq_tlast         ),
      .m_axis_treq_tdata             (m_axis_treq_tdata         ),
      .m_axis_treq_tkeep             (m_axis_treq_tkeep         ),
      .m_axis_treq_tuser             (m_axis_treq_tuser         ),

      .s_axi_maintr_awvalid          (0      ),
      .s_axi_maintr_awready          (      ),
      .s_axi_maintr_awaddr           (0       ),
      .s_axi_maintr_wvalid           (0       ),
      .s_axi_maintr_wready           (       ),
      .s_axi_maintr_wdata            (0        ),
      .s_axi_maintr_bvalid           (       ),
      .s_axi_maintr_bready           (0       ),
      .s_axi_maintr_bresp            (        ),

      .s_axi_maintr_arvalid          (0      ),
      .s_axi_maintr_arready          (      ),
      .s_axi_maintr_araddr           (0       ),
      .s_axi_maintr_rvalid           (       ),
      .s_axi_maintr_rready           (0       ),
      .s_axi_maintr_rdata            (        ),
      .s_axi_maintr_rresp            (        ),


      .sim_train_en                  (i_sim_train_en      ),
      .force_reinit                  (w_o_force_reinit),
      .phy_mce                       (0           ),
      .phy_link_reset                (0    ),

      .phy_rcvd_mce                  (      ),
      .phy_rcvd_link_reset           (w_phy_rcvd_link_reset),
      .phy_debug                     (         ),
      .gtrx_disperr_or               (w_gtrx_disperr_or   ),
      .gtrx_notintable_or            (w_gtrx_notintable_or),

      .port_error                      (o_port_error        ),
      .port_timeout                    (      ),
      .srio_host                       (         ),
      .port_decode_error               (w_port_decode_error ),//用于指示我们当前传输的报文（事务）不支持
      .deviceid                        (w_deviceid          ),
      .idle2_selected                  (    ),
      .phy_lcl_master_enable_out       (    ),
      .buf_lcl_response_only_out       (    ),
      .buf_lcl_tx_flow_control_out     (  ),
      .buf_lcl_phy_buf_stat_out        (     ),
      .phy_lcl_phy_next_fm_out         (      ),
      .phy_lcl_phy_last_ack_out        (     ),
      .phy_lcl_phy_rewind_out          (       ),
      .phy_lcl_phy_rcvd_buf_stat_out   (),
      .phy_lcl_maint_only_out          (       ),

//-------------newly added signals as per gt interface requirements-------------



                                                       

      .port_initialized           (w_port_initialized  ),
      .link_initialized           (w_link_initialized  ),

      .idle_selected              (     ),
      .mode_1x                    (w_mode_1x           )

     );    
    
endmodule
