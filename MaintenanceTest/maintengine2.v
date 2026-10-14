`timescale 1ns / 1ps
module maintengine2(
    input                       i_log_clk           ,
    input                       i_log_rst           ,
    input                       i_port_initialized  ,

    output reg                  o_maintr_awvalid    ,
    input                       i_maintr_awready    ,
    output reg [31:0]           o_maintr_awaddr     ,
    output reg                  o_maintr_wvalid     ,
    input                       i_maintr_wready     ,
    output reg [31:0]           o_maintr_wdata      ,
    input                       i_maintr_bvalid     ,
    output reg                  o_maintr_bready     ,
    input  [1 :0]               i_maintr_bresp      ,

    output reg                  o_maintr_arvalid    ,
    input                       i_maintr_arready    ,
    output reg [31:0]           o_maintr_araddr     ,
    input                       i_maintr_rvalid     ,
    output reg                  o_maintr_rready     ,
    input  [31:0]               i_maintr_rdata      ,
    input  [1 :0]               i_maintr_rresp      ,

    output reg [31:0]           o_observe_data      ,
    output reg                  o_maint_rcvd
);

localparam  P_ST_IDLE  = 8'd0  ;
localparam  P_ST_READ  = 8'd1  ;
localparam  P_ST_WAIT  = 8'd2  ;
localparam  P_ST_DONE  = 8'd3  ;

// ============================================================
// 本地读地址：高8位 = Hop count + 1 = 0，低24位 = offset 0x60
// ============================================================
wire [31:0] p_maint_addr = {8'h00, 24'h000060};

// 本端（引擎2侧）Device ID = 0xFE
localparam  P_EXPECT_DATA  = 32'h000000FE;

reg [7:0]   r_cur_state ;
reg [7:0]   r_next_state;
reg [31:0]  r_rd_data   ;

reg [31:0]  r_poll_cnt;

always @(posedge i_log_clk) begin
    if(i_log_rst)
        r_cur_state <= P_ST_IDLE;
    else
        r_cur_state <= r_next_state;
end

always @(posedge i_log_clk) begin
    if(i_log_rst)
        r_poll_cnt <= 32'd0;
    else if(r_cur_state == P_ST_READ)
        r_poll_cnt <= r_poll_cnt + 1'b1;
end

always @(*) begin
    r_next_state = r_cur_state;
    case(r_cur_state)
        P_ST_IDLE: begin
            if(i_port_initialized)
                r_next_state = P_ST_READ;
        end
        P_ST_READ: begin
            if(i_maintr_arready)
                r_next_state = P_ST_WAIT;
        end
        P_ST_WAIT: begin
            if(i_maintr_rvalid) begin
                if(i_maintr_rdata[23:16] == P_EXPECT_DATA[7:0])
                    r_next_state = P_ST_DONE;
                else
                    r_next_state = P_ST_READ;
            end
        end
        P_ST_DONE: r_next_state = P_ST_DONE;
        default:   r_next_state = P_ST_IDLE;
    endcase
end

always @(posedge i_log_clk) begin
    if(i_log_rst) begin
        o_maintr_awvalid    <= 1'b0;
        o_maintr_awaddr     <= 32'd0;
        o_maintr_wvalid     <= 1'b0;
        o_maintr_wdata      <= 32'd0;
        o_maintr_bready     <= 1'b0;
        o_maintr_arvalid    <= 1'b0;
        o_maintr_araddr     <= 32'd0;
        o_maintr_rready     <= 1'b0;
        o_observe_data      <= 32'd0;
        o_maint_rcvd        <= 1'b0;
        r_rd_data           <= 32'd0;
    end
    else begin
        case(r_cur_state)
            P_ST_IDLE: begin
                o_maintr_arvalid    <= 1'b0;
                o_maintr_rready     <= 1'b0;
                o_maintr_awvalid    <= 1'b0;
                o_maintr_wvalid     <= 1'b0;
                o_maintr_bready     <= 1'b0;
                o_maint_rcvd        <= 1'b0;
            end
            P_ST_READ: begin
                o_maintr_arvalid    <= 1'b1;
                o_maintr_araddr     <= p_maint_addr;
                o_maintr_rready     <= 1'b0;
            end
            P_ST_WAIT: begin
                o_maintr_arvalid    <= 1'b0;
                o_maintr_rready     <= 1'b1;
                if(i_maintr_rvalid) begin
                    r_rd_data       <= i_maintr_rdata;
                    o_observe_data  <= i_maintr_rdata;
                end
            end
            P_ST_DONE: begin
                o_maint_rcvd <= 1'b1;
            end
            default: begin
                o_maintr_awvalid    <= 1'b0;
                o_maintr_wvalid     <= 1'b0;
                o_maintr_bready     <= 1'b0;
                o_maintr_arvalid    <= 1'b0;
                o_maintr_rready     <= 1'b0;
            end
        endcase
    end
end

ila_1 u_ila_maint2 (
    .clk        (i_log_clk),
    .probe0     (r_cur_state),
    .probe1     ({i_port_initialized, o_maint_rcvd}),
    .probe2     (o_maintr_araddr),
    .probe3     ({o_maintr_arvalid, i_maintr_arready, i_maintr_rvalid, o_maintr_rready}),
    .probe4     (i_maintr_rdata),
    .probe5     (i_maintr_rresp),
    .probe6     (r_rd_data),
    .probe7     (o_observe_data),
    .probe8     (r_poll_cnt),
    .probe9     (0)
);

endmodule