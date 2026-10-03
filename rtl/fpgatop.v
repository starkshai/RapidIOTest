`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/09/13 15:05:19
// Design Name: 
// Module Name: fpgatop
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


module fpgatop(
    // Clocks and Resets
    input            sys_clkp,              // MMCM reference clock
    input            sys_clkn,              // MMCM reference clock

    input            clk200m_p,
    input            clk200m_n,

    // high-speed IO
    output [1 :0]   o_gtref_tx_p            ,
    output [1 :0]   o_gtref_tx_n            ,
    input  [1 :0]   i_gtref_rx_p            ,
    input  [1 :0]   i_gtref_rx_n            ,
    
    output fan_pwm,
    output[3:0]   tx_disable,
    output        pll_clk1,
    inout         si5338_scl, //i2c clock
    inout         si5338_sda, //i2c data 
    
    output wire [3:0]    led

    );

wire clk_200m;
wire done;
wire [7:0] led0;
wire log_clk;

wire                w_gtref_clk             ;
wire                w_1_gtrx_disperr_or     ;
wire                w_1_gtrx_notintable_or  ;
wire                w_1_port_error          ;
wire                w_2_gtrx_disperr_or     ;
wire                w_2_gtrx_notintable_or  ;
wire                w_2_port_error          ;
(* MARK_DEBUG = "TRUE" *)wire                s_1_axis_ireq_tvalid    ;
(* MARK_DEBUG = "TRUE" *)wire                s_1_axis_ireq_tready    ;
(* MARK_DEBUG = "TRUE" *)wire                s_1_axis_ireq_tlast     ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         s_1_axis_ireq_tdata     ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         s_1_axis_ireq_tkeep     ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         s_1_axis_ireq_tuser     ;
(* MARK_DEBUG = "TRUE" *)wire                m_1_axis_iresp_tvalid   ;
(* MARK_DEBUG = "TRUE" *)wire                m_1_axis_iresp_tready   ;
(* MARK_DEBUG = "TRUE" *)wire                m_1_axis_iresp_tlast    ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         m_1_axis_iresp_tdata    ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         m_1_axis_iresp_tkeep    ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         m_1_axis_iresp_tuser    ;
(* MARK_DEBUG = "TRUE" *)wire                m_1_axis_treq_tvalid    ;
(* MARK_DEBUG = "TRUE" *)wire                m_1_axis_treq_tready    ;
(* MARK_DEBUG = "TRUE" *)wire                m_1_axis_treq_tlast     ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         m_1_axis_treq_tdata     ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         m_1_axis_treq_tkeep     ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         m_1_axis_treq_tuser     ;
(* MARK_DEBUG = "TRUE" *)wire                s_1_axis_tresp_tvalid   ;
(* MARK_DEBUG = "TRUE" *)wire                s_1_axis_tresp_tready   ;
(* MARK_DEBUG = "TRUE" *)wire                s_1_axis_tresp_tlast    ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         s_1_axis_tresp_tdata    ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         s_1_axis_tresp_tkeep    ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         s_1_axis_tresp_tuser    ;

(* MARK_DEBUG = "TRUE" *)wire                s_2_axis_ireq_tvalid    ;
(* MARK_DEBUG = "TRUE" *)wire                s_2_axis_ireq_tready    ;
(* MARK_DEBUG = "TRUE" *)wire                s_2_axis_ireq_tlast     ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         s_2_axis_ireq_tdata     ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         s_2_axis_ireq_tkeep     ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         s_2_axis_ireq_tuser     ;
(* MARK_DEBUG = "TRUE" *)wire                m_2_axis_iresp_tvalid   ;
(* MARK_DEBUG = "TRUE" *)wire                m_2_axis_iresp_tready   ;
(* MARK_DEBUG = "TRUE" *)wire                m_2_axis_iresp_tlast    ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         m_2_axis_iresp_tdata    ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         m_2_axis_iresp_tkeep    ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         m_2_axis_iresp_tuser    ;
(* MARK_DEBUG = "TRUE" *)wire                m_2_axis_treq_tvalid    ;
(* MARK_DEBUG = "TRUE" *)wire                m_2_axis_treq_tready    ;
(* MARK_DEBUG = "TRUE" *)wire                m_2_axis_treq_tlast     ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         m_2_axis_treq_tdata     ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         m_2_axis_treq_tkeep     ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         m_2_axis_treq_tuser     ;
(* MARK_DEBUG = "TRUE" *)wire                s_2_axis_tresp_tvalid   ;
(* MARK_DEBUG = "TRUE" *)wire                s_2_axis_tresp_tready   ;
(* MARK_DEBUG = "TRUE" *)wire                s_2_axis_tresp_tlast    ;
(* MARK_DEBUG = "TRUE" *)wire [63:0]         s_2_axis_tresp_tdata    ;
(* MARK_DEBUG = "TRUE" *)wire [7 :0]         s_2_axis_tresp_tkeep    ;
(* MARK_DEBUG = "TRUE" *)wire [31:0]         s_2_axis_tresp_tuser    ;
wire                w_2_log_clk             ;
wire                w_2_log_rst             ;
wire                w_1_log_clk             ;
wire                w_1_log_rst             ;
wire                w_sys_clk               ;
wire                w_sys_rst               ;
wire                w_1_link_initialized    ;
wire                w_2_link_initialized    ;
wire                w_1_port_initialized    ;
wire                w_2_port_initialized    ;
    
assign fan_pwm=1'b0;
assign tx_disable = 4'd0;
assign  pll_clk1 = 1'b0;   

assign led[0]=w_1_link_initialized; //5338locked
assign led[1]=w_1_port_initialized;//port_initialized
assign led[2]=w_2_link_initialized;//link_initialized
assign led[3]=w_2_port_initialized;//clk_lock

IBUFDS IBUFDS_clk200m (
    .O  (clk_200m),        // µ¥¶ËÊä³ö
    .I  (clk200m_p),
    .IB (clk200m_n)
);

IBUFDS_GTE2 IBUFDS_GTE2_U0(
    .O                              (w_gtref_clk            ),
    .I                              (sys_clkp          ),
    .IB                             (sys_clkn          ),
    .CEB                            (1'b0                   ),
    .ODIV2                          (                       )
);

/*POWER ON RESET*/
rst_gen_module#(
    .P_RST_CYCLE                    (200                     )   
)                   
rst_gen_module_u0                   
(                   
    .i_clk                          (clk_200m              ),
    .o_rst                          (w_sys_rst              )
);

si5338#
 (
     .kInitFileName                  ("si5338_i4_50_200_125_125_100.mif"),
     .input_clk                      (200000000                ),
     .i2c_address                    (7'b1110000               ),
     .bus_clk                        (400000                   )
 )
 si5338_inst(
     .clk                            (clk_200m             ),
     .reset                          (1'b0                   ),
     .done                           (done                     ),
     .error                          (                         ),
     .SCL                            (si5338_scl               ),
     .SDA                            (si5338_sda               )
     ); 

SRIO_Engine SRIO_Engine_u0(
    .i_clk                          (w_1_log_clk            ),
    .i_rst                          (w_1_log_rst | ~w_1_port_initialized ),

    .m_axis_ireq_tvalid             (s_1_axis_ireq_tvalid   ), 
    .m_axis_ireq_tready             (s_1_axis_ireq_tready   ), 
    .m_axis_ireq_tlast              (s_1_axis_ireq_tlast    ), 
    .m_axis_ireq_tdata              (s_1_axis_ireq_tdata    ), 
    .m_axis_ireq_tkeep              (s_1_axis_ireq_tkeep    ), 
    .m_axis_ireq_tuser              (s_1_axis_ireq_tuser    ), 
    .s_axis_iresp_tvalid            (m_1_axis_iresp_tvalid  ), 
    .s_axis_iresp_tready            (m_1_axis_iresp_tready  ), 
    .s_axis_iresp_tlast             (m_1_axis_iresp_tlast   ), 
    .s_axis_iresp_tdata             (m_1_axis_iresp_tdata   ), 
    .s_axis_iresp_tkeep             (m_1_axis_iresp_tkeep   ), 
    .s_axis_iresp_tuser             (m_1_axis_iresp_tuser   ), 
    .s_axis_treq_tvalid             (m_1_axis_treq_tvalid   ), 
    .s_axis_treq_tready             (m_1_axis_treq_tready   ), 
    .s_axis_treq_tlast              (m_1_axis_treq_tlast    ), 
    .s_axis_treq_tdata              (m_1_axis_treq_tdata    ), 
    .s_axis_treq_tkeep              (m_1_axis_treq_tkeep    ), 
    .s_axis_treq_tuser              (m_1_axis_treq_tuser    ), 
    .m_axis_tresp_tvalid            (s_1_axis_tresp_tvalid  ), 
    .m_axis_tresp_tready            (s_1_axis_tresp_tready  ), 
    .m_axis_tresp_tlast             (s_1_axis_tresp_tlast   ), 
    .m_axis_tresp_tdata             (s_1_axis_tresp_tdata   ), 
    .m_axis_tresp_tkeep             (s_1_axis_tresp_tkeep   ), 
    .m_axis_tresp_tuser             (s_1_axis_tresp_tuser   ) 
);

SRIO_Engine SRIO_Engine_u1(
    .i_clk                          (w_2_log_clk            ),
    .i_rst                          (w_2_log_rst | ~w_2_port_initialized),

    .m_axis_ireq_tvalid             (s_2_axis_ireq_tvalid   ), 
    .m_axis_ireq_tready             (s_2_axis_ireq_tready   ), 
    .m_axis_ireq_tlast              (s_2_axis_ireq_tlast    ), 
    .m_axis_ireq_tdata              (s_2_axis_ireq_tdata    ), 
    .m_axis_ireq_tkeep              (s_2_axis_ireq_tkeep    ), 
    .m_axis_ireq_tuser              (s_2_axis_ireq_tuser    ), 
    .s_axis_iresp_tvalid            (m_2_axis_iresp_tvalid  ), 
    .s_axis_iresp_tready            (m_2_axis_iresp_tready  ), 
    .s_axis_iresp_tlast             (m_2_axis_iresp_tlast   ), 
    .s_axis_iresp_tdata             (m_2_axis_iresp_tdata   ), 
    .s_axis_iresp_tkeep             (m_2_axis_iresp_tkeep   ), 
    .s_axis_iresp_tuser             (m_2_axis_iresp_tuser   ), 
    .s_axis_treq_tvalid             (m_2_axis_treq_tvalid   ), 
    .s_axis_treq_tready             (m_2_axis_treq_tready   ), 
    .s_axis_treq_tlast              (m_2_axis_treq_tlast    ), 
    .s_axis_treq_tdata              (m_2_axis_treq_tdata    ), 
    .s_axis_treq_tkeep              (m_2_axis_treq_tkeep    ), 
    .s_axis_treq_tuser              (m_2_axis_treq_tuser    ), 
    .m_axis_tresp_tvalid            (s_2_axis_tresp_tvalid  ), 
    .m_axis_tresp_tready            (s_2_axis_tresp_tready  ), 
    .m_axis_tresp_tlast             (s_2_axis_tresp_tlast   ), 
    .m_axis_tresp_tdata             (s_2_axis_tresp_tdata   ), 
    .m_axis_tresp_tkeep             (s_2_axis_tresp_tkeep   ), 
    .m_axis_tresp_tuser             (s_2_axis_tresp_tuser   ) 
);    
 
SRIO_Mod SRIO_Mod_u0(
    .i_gtref_clk                    (w_gtref_clk            ),
    .i_rst                          (w_sys_rst||~done       ),
    .i_sim_train_en                 (0                      ),

    .o_1_gtrx_disperr_or            (w_1_gtrx_disperr_or    ),
    .o_1_gtrx_notintable_or         (w_1_gtrx_notintable_or ),
    .o_1_port_error                 (w_1_port_error         ),
    .o_1_srio_txn0                  (o_gtref_tx_n[0]        ),
    .o_1_srio_txp0                  (o_gtref_tx_p[0]        ),
    .i_1_srio_rxn0                  (i_gtref_rx_n[0]        ),         
    .i_1_srio_rxp0                  (i_gtref_rx_p[0]        ),      
    .s_1_axis_ireq_tvalid           (s_1_axis_ireq_tvalid   ), 
    .s_1_axis_ireq_tready           (s_1_axis_ireq_tready   ), 
    .s_1_axis_ireq_tlast            (s_1_axis_ireq_tlast    ), 
    .s_1_axis_ireq_tdata            (s_1_axis_ireq_tdata    ), 
    .s_1_axis_ireq_tkeep            (s_1_axis_ireq_tkeep    ), 
    .s_1_axis_ireq_tuser            (s_1_axis_ireq_tuser    ), 
    .m_1_axis_iresp_tvalid          (m_1_axis_iresp_tvalid  ), 
    .m_1_axis_iresp_tready          (m_1_axis_iresp_tready  ), 
    .m_1_axis_iresp_tlast           (m_1_axis_iresp_tlast   ), 
    .m_1_axis_iresp_tdata           (m_1_axis_iresp_tdata   ), 
    .m_1_axis_iresp_tkeep           (m_1_axis_iresp_tkeep   ), 
    .m_1_axis_iresp_tuser           (m_1_axis_iresp_tuser   ), 
    .m_1_axis_treq_tvalid           (m_1_axis_treq_tvalid   ), 
    .m_1_axis_treq_tready           (m_1_axis_treq_tready   ), 
    .m_1_axis_treq_tlast            (m_1_axis_treq_tlast    ), 
    .m_1_axis_treq_tdata            (m_1_axis_treq_tdata    ), 
    .m_1_axis_treq_tkeep            (m_1_axis_treq_tkeep    ), 
    .m_1_axis_treq_tuser            (m_1_axis_treq_tuser    ), 
    .s_1_axis_tresp_tvalid          (s_1_axis_tresp_tvalid  ), 
    .s_1_axis_tresp_tready          (s_1_axis_tresp_tready  ), 
    .s_1_axis_tresp_tlast           (s_1_axis_tresp_tlast   ), 
    .s_1_axis_tresp_tdata           (s_1_axis_tresp_tdata   ), 
    .s_1_axis_tresp_tkeep           (s_1_axis_tresp_tkeep   ), 
    .s_1_axis_tresp_tuser           (s_1_axis_tresp_tuser   ), 
    .o_1_log_clk                    (w_1_log_clk            ),
    .o_1_log_rst                    (w_1_log_rst            ),
    .o_1_link_initialized           (w_1_link_initialized   ),
    .o_1_port_initialized           (w_1_port_initialized   ),

    .o_2_gtrx_disperr_or            (w_2_gtrx_disperr_or    ),
    .o_2_gtrx_notintable_or         (w_2_gtrx_notintable_or ),
    .o_2_port_error                 (w_2_port_error         ),
    .o_2_srio_txn0                  (o_gtref_tx_n[1]        ),
    .o_2_srio_txp0                  (o_gtref_tx_p[1]        ),
    .i_2_srio_rxn0                  (i_gtref_rx_n[1]        ),         
    .i_2_srio_rxp0                  (i_gtref_rx_p[1]        ),      
    .s_2_axis_ireq_tvalid           (s_2_axis_ireq_tvalid   ), 
    .s_2_axis_ireq_tready           (s_2_axis_ireq_tready   ), 
    .s_2_axis_ireq_tlast            (s_2_axis_ireq_tlast    ), 
    .s_2_axis_ireq_tdata            (s_2_axis_ireq_tdata    ), 
    .s_2_axis_ireq_tkeep            (s_2_axis_ireq_tkeep    ), 
    .s_2_axis_ireq_tuser            (s_2_axis_ireq_tuser    ), 
    .m_2_axis_iresp_tvalid          (m_2_axis_iresp_tvalid  ), 
    .m_2_axis_iresp_tready          (m_2_axis_iresp_tready  ), 
    .m_2_axis_iresp_tlast           (m_2_axis_iresp_tlast   ), 
    .m_2_axis_iresp_tdata           (m_2_axis_iresp_tdata   ), 
    .m_2_axis_iresp_tkeep           (m_2_axis_iresp_tkeep   ), 
    .m_2_axis_iresp_tuser           (m_2_axis_iresp_tuser   ), 
    .m_2_axis_treq_tvalid           (m_2_axis_treq_tvalid   ), 
    .m_2_axis_treq_tready           (m_2_axis_treq_tready   ), 
    .m_2_axis_treq_tlast            (m_2_axis_treq_tlast    ), 
    .m_2_axis_treq_tdata            (m_2_axis_treq_tdata    ), 
    .m_2_axis_treq_tkeep            (m_2_axis_treq_tkeep    ), 
    .m_2_axis_treq_tuser            (m_2_axis_treq_tuser    ), 
    .s_2_axis_tresp_tvalid          (s_2_axis_tresp_tvalid  ), 
    .s_2_axis_tresp_tready          (s_2_axis_tresp_tready  ), 
    .s_2_axis_tresp_tlast           (s_2_axis_tresp_tlast   ), 
    .s_2_axis_tresp_tdata           (s_2_axis_tresp_tdata   ), 
    .s_2_axis_tresp_tkeep           (s_2_axis_tresp_tkeep   ), 
    .s_2_axis_tresp_tuser           (s_2_axis_tresp_tuser   ), 
    .o_2_log_clk                    (w_2_log_clk            ),
    .o_2_log_rst                    (w_2_log_rst            ),
    .o_2_link_initialized           (w_2_link_initialized   ),
    .o_2_port_initialized           (w_2_port_initialized   )
);                   
    
endmodule
