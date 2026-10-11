`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/11 13:58:32
// Design Name: 
// Module Name: SRIO_Engine1
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
module SRIO_Engine1(
    input               i_clk                   ,
    input               i_rst                   ,
    input               i_start                 ,

    output              m_axis_ireq_tvalid      , 
    input               m_axis_ireq_tready      , 
    output              m_axis_ireq_tlast       , 
    output [63:0]       m_axis_ireq_tdata       , 
    output [7 :0]       m_axis_ireq_tkeep       , 
    output [31:0]       m_axis_ireq_tuser       , 
    input               s_axis_iresp_tvalid     , 
    output              s_axis_iresp_tready     , 
    input               s_axis_iresp_tlast      , 
    input  [63:0]       s_axis_iresp_tdata      , 
    input  [7 :0]       s_axis_iresp_tkeep      , 
    input  [31:0]       s_axis_iresp_tuser      , 

    input               s_axis_treq_tvalid      , 
    output              s_axis_treq_tready      , 
    input               s_axis_treq_tlast       , 
    input  [63:0]       s_axis_treq_tdata       , 
    input  [7 :0]       s_axis_treq_tkeep       , 
    input  [31:0]       s_axis_treq_tuser       , 
    output              m_axis_tresp_tvalid     , 
    input               m_axis_tresp_tready     , 
    output              m_axis_tresp_tlast      , 
    output [63:0]       m_axis_tresp_tdata      , 
    output [7 :0]       m_axis_tresp_tkeep      , 
    output [31:0]       m_axis_tresp_tuser       
);

localparam P_ST_IDLE           = 0,
           P_ST_SEND_DB1       = 1,
           P_ST_WAIT_DB2       = 2,
           P_ST_SEND_NWRITE    = 3,
           P_ST_SEND_DB_DONE   = 4,
           P_ST_SEND_NREAD     = 5,
           P_ST_WAIT_READ_RESP = 6,
           P_ST_SEND_MESSAGE   = 7,
           P_ST_WAIT_MSG_ACK   = 8;

reg [7:0]  r_st_current, r_st_next;
reg [15:0] r_st_cnt;

reg        rm_axis_ireq_tvalid;
reg        rm_axis_ireq_tlast;
reg [63:0] rm_axis_ireq_tdata;
reg [7:0]  rm_axis_ireq_tkeep;
reg [31:0] rm_axis_ireq_tuser;
reg        rs_axis_iresp_tready;
reg        rs_axis_treq_tready;
reg        rm_axis_tresp_tvalid;
reg        rm_axis_tresp_tlast;
reg [63:0] rm_axis_tresp_tdata;
reg [7:0]  rm_axis_tresp_tkeep;
reg [31:0] rm_axis_tresp_tuser;

reg [15:0] r_cnt; // NWRITE data counter

wire w_m_axis_ireq_act  = m_axis_ireq_tvalid & m_axis_ireq_tready;
wire w_s_axis_iresp_act = s_axis_iresp_tvalid & s_axis_iresp_tready;
wire w_s_axis_treq_act  = s_axis_treq_tvalid & s_axis_treq_tready;
wire w_m_axis_tresp_act = m_axis_tresp_tvalid & m_axis_tresp_tready;

// ===== Engine1 ILA debug signals =====
wire [7:0]  e1_ireq_type  = m_axis_ireq_tdata[55:48];
wire [31:0] e1_ireq_data  = m_axis_ireq_tdata[31:0];
wire [7:0]  e1_treq_type  = s_axis_treq_tdata[55:48];
wire [7:0]  e1_iresp_type = s_axis_iresp_tdata[55:48];

assign m_axis_ireq_tvalid = rm_axis_ireq_tvalid;
assign m_axis_ireq_tlast  = rm_axis_ireq_tlast;
assign m_axis_ireq_tdata  = rm_axis_ireq_tdata;
assign m_axis_ireq_tkeep  = rm_axis_ireq_tkeep;
assign m_axis_ireq_tuser  = rm_axis_ireq_tuser;
assign s_axis_iresp_tready = rs_axis_iresp_tready;
assign s_axis_treq_tready  = rs_axis_treq_tready;
assign m_axis_tresp_tvalid = rm_axis_tresp_tvalid;
assign m_axis_tresp_tlast  = rm_axis_tresp_tlast;
assign m_axis_tresp_tdata  = rm_axis_tresp_tdata;
assign m_axis_tresp_tkeep  = rm_axis_tresp_tkeep;
assign m_axis_tresp_tuser  = rm_axis_tresp_tuser;

// State register
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) r_st_current <= P_ST_IDLE;
    else      r_st_current <= r_st_next;
end

// State transition
always @(*) begin
    case(r_st_current)
        P_ST_IDLE          : r_st_next = i_start ? P_ST_SEND_DB1 : P_ST_IDLE;
        P_ST_SEND_DB1      : r_st_next = (w_m_axis_ireq_act && rm_axis_ireq_tlast) ? P_ST_WAIT_DB2 : P_ST_SEND_DB1;
        P_ST_WAIT_DB2      : r_st_next = (w_s_axis_treq_act && s_axis_treq_tlast && (s_axis_treq_tdata[55:48] == 8'hA0)) ? P_ST_SEND_NWRITE : P_ST_WAIT_DB2;
        P_ST_SEND_NWRITE   : r_st_next = (w_m_axis_ireq_act && rm_axis_ireq_tlast) ? P_ST_SEND_DB_DONE : P_ST_SEND_NWRITE;
        P_ST_SEND_DB_DONE  : r_st_next = (w_m_axis_ireq_act && rm_axis_ireq_tlast) ? P_ST_SEND_NREAD : P_ST_SEND_DB_DONE;
        P_ST_SEND_NREAD    : r_st_next = (w_m_axis_ireq_act && rm_axis_ireq_tlast) ? P_ST_WAIT_READ_RESP : P_ST_SEND_NREAD;
        P_ST_WAIT_READ_RESP: r_st_next = (w_s_axis_iresp_act && s_axis_iresp_tlast) ? P_ST_SEND_MESSAGE : P_ST_WAIT_READ_RESP;
        P_ST_SEND_MESSAGE  : r_st_next = (w_m_axis_ireq_act && rm_axis_ireq_tlast) ? P_ST_WAIT_MSG_ACK : P_ST_SEND_MESSAGE;
        P_ST_WAIT_MSG_ACK  : r_st_next = (w_s_axis_treq_act && s_axis_treq_tlast && (s_axis_treq_tdata[55:48] == 8'hB0)) ? P_ST_IDLE : P_ST_WAIT_MSG_ACK;
        default            : r_st_next = P_ST_IDLE;
    endcase
end

// State counter
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) r_st_cnt <= 0;
    else if(r_st_current != r_st_next) r_st_cnt <= 0;
    else r_st_cnt <= r_st_cnt + 1;
end

// tready always 1
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        rs_axis_iresp_tready <= 0;
        rs_axis_treq_tready  <= 0;
    end else begin
        rs_axis_iresp_tready <= 1;
        rs_axis_treq_tready  <= 1;
    end
end

// m_axis_ireq_tvalid
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) rm_axis_ireq_tvalid <= 0;
    else if(w_m_axis_ireq_act && rm_axis_ireq_tlast) rm_axis_ireq_tvalid <= 0;
    else if(r_st_current == P_ST_SEND_DB1     && r_st_cnt == 0) rm_axis_ireq_tvalid <= 1;
    else if(r_st_current == P_ST_SEND_NWRITE  && r_st_cnt == 0) rm_axis_ireq_tvalid <= 1;
    else if(r_st_current == P_ST_SEND_DB_DONE && r_st_cnt == 0) rm_axis_ireq_tvalid <= 1;
    else if(r_st_current == P_ST_SEND_NREAD   && r_st_cnt == 0) rm_axis_ireq_tvalid <= 1;
    else if(r_st_current == P_ST_SEND_MESSAGE && r_st_cnt == 0) rm_axis_ireq_tvalid <= 1;
    else rm_axis_ireq_tvalid <= rm_axis_ireq_tvalid;
end

// m_axis_ireq_tlast
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) rm_axis_ireq_tlast <= 0;
    else if(w_m_axis_ireq_act && rm_axis_ireq_tlast) rm_axis_ireq_tlast <= 0;
    else if(r_st_current == P_ST_SEND_DB1     && r_st_cnt == 0) rm_axis_ireq_tlast <= 1;
    else if(r_st_current == P_ST_SEND_DB_DONE && r_st_cnt == 0) rm_axis_ireq_tlast <= 1;
    else if(r_st_current == P_ST_SEND_NREAD   && r_st_cnt == 0) rm_axis_ireq_tlast <= 1;
    //else if(r_st_current == P_ST_SEND_MESSAGE && w_m_axis_ireq_act) rm_axis_ireq_tlast <= 1;
    else if(r_st_current == P_ST_SEND_MESSAGE && r_st_cnt == 16'd2) rm_axis_ireq_tlast <= 1;//message package contains at least 1 byte data
    else if(r_st_current == P_ST_SEND_NWRITE  && r_cnt == 31)   rm_axis_ireq_tlast <= 1;
    else rm_axis_ireq_tlast <= rm_axis_ireq_tlast;
end

// m_axis_ireq_tdata
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) rm_axis_ireq_tdata <= 0;
    else if(r_st_current == P_ST_SEND_DB1     && r_st_cnt == 0) rm_axis_ireq_tdata <= {8'd0,4'b1010,4'd0,1'b0,2'b0,1'b0,8'd0,2'b0,34'd0};
    else if(r_st_current == P_ST_SEND_NWRITE  && r_st_cnt == 0) rm_axis_ireq_tdata <= {8'd0,4'b0101,4'b0100,1'b0,2'b1,1'b0,8'd255,2'b0,34'd0};
    else if(r_st_current == P_ST_SEND_DB_DONE && r_st_cnt == 0) rm_axis_ireq_tdata <= {8'd0,4'b1010,4'd0,1'b0,2'b0,1'b0,8'd0,2'b0,34'd0};
    else if(r_st_current == P_ST_SEND_NREAD   && r_st_cnt == 0) rm_axis_ireq_tdata <= {8'd0,4'b0010,4'd4,1'b0,2'b0,1'b0,8'd255,2'b0,34'd0};
    else if(r_st_current == P_ST_SEND_MESSAGE && r_st_cnt == 0) rm_axis_ireq_tdata <= {4'd0,4'd0,4'b1011,4'd0,1'b0,2'b0,1'b0,8'd7,2'b0,34'd0};
    else if(w_m_axis_ireq_act && r_st_current == P_ST_SEND_NWRITE) rm_axis_ireq_tdata <= {4{r_cnt}};
    else rm_axis_ireq_tdata <= rm_axis_ireq_tdata;
end

// NWRITE data counter
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) r_cnt <= 0;
    else if(r_st_current != P_ST_SEND_NWRITE) r_cnt <= 0;
    else if(w_m_axis_ireq_act) r_cnt <= r_cnt + 1;
end

// tkeep and tuser
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        rm_axis_ireq_tkeep <= 8'hff;
        rm_axis_ireq_tuser <= 0;
    end else begin
        rm_axis_ireq_tkeep <= 8'hff;
        rm_axis_ireq_tuser <= 0;
    end
end

// Engine1 tresp output default
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        rm_axis_tresp_tvalid <= 0;
        rm_axis_tresp_tlast  <= 0;
        rm_axis_tresp_tdata  <= 0;
        rm_axis_tresp_tkeep  <= 8'hff;
        rm_axis_tresp_tuser  <= 0;
    end else begin
        rm_axis_tresp_tvalid <= 0;
        rm_axis_tresp_tlast  <= 0;
        rm_axis_tresp_tdata  <= 0;
        rm_axis_tresp_tkeep  <= 8'hff;
        rm_axis_tresp_tuser  <= 0;
    end
end

ila_0 ila_eng1 (
    .clk    (i_clk             ),  // input wire clk

    .probe0 (r_st_current      ),  // input wire [7:0]  current state
    .probe1 (r_st_next         ),  // input wire [7:0]  next state
    .probe2 (r_st_cnt          ),  // input wire [15:0] state counter
    .probe3 (r_cnt             ),  // input wire [15:0] NWRITE data counter

    .probe4 (m_axis_ireq_tvalid),  // input wire [0:0]  initiator request valid
    .probe5 (m_axis_ireq_tready),  // input wire [0:0]  initiator request ready
    .probe6 (m_axis_ireq_tlast ),  // input wire [0:0]  initiator request last
    .probe7 (e1_ireq_type      ),  // input wire [7:0]  initiator request type
    .probe8 (e1_ireq_data      ),  // input wire [31:0] initiator request data (NWRITE data)

    .probe9 (s_axis_treq_tvalid),  // input wire [0:0]  target request valid (received)
    .probe10(s_axis_treq_tready),  // input wire [0:0]  target request ready
    .probe11(s_axis_treq_tlast ),  // input wire [0:0]  target request last
    .probe12(e1_treq_type      ),  // input wire [7:0]  target request type

    .probe13(s_axis_iresp_tvalid), // input wire [0:0]  initiator response valid
    .probe14(s_axis_iresp_tready), // input wire [0:0]  initiator response ready
    .probe15(s_axis_iresp_tlast ), // input wire [0:0]  initiator response last
    .probe16(e1_iresp_type     ),  // input wire [7:0]  initiator response type

    .probe17(w_m_axis_ireq_act ),  // input wire [0:0]  initiator request handshake done
    .probe18(w_s_axis_treq_act ),  // input wire [0:0]  target request handshake done
    .probe19(w_s_axis_iresp_act)   // input wire [0:0]  initiator response handshake done
);

endmodule