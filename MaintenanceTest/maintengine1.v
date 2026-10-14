`timescale 1ns / 1ps
module maintengine1(
    input                       i_log_clk           ,
    input                       i_log_rst           ,
    input                       i_port_initialized  ,
    input                       i_engine1_start     ,

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

    output reg [31:0]           o_rd_data_init      ,
    output reg [31:0]           o_rd_data_back      ,
    output reg                  o_maint_done
);

localparam  P_ST_IDLE         = 8'd0  ;
localparam  P_ST_WRITE_REQ    = 8'd1  ;
localparam  P_ST_WRITE_WAIT   = 8'd2  ;
localparam  P_ST_READ_LOCAL   = 8'd3  ;
localparam  P_ST_WAIT_LOCAL   = 8'd4  ;
localparam  P_ST_READ_REMOTE  = 8'd5  ;
localparam  P_ST_WAIT_REMOTE  = 8'd6  ;
localparam  P_ST_DONE         = 8'd7  ;

// ============================================================
// 维护读地址：高8位 = Hop count + 1，低24位 = 配置偏移
// 本地读：hop=0 → 高8位=0
// 远程读：hop=0 → 高8位=1（端点直通）
// ============================================================
wire [31:0] p_maint_addr_local  = {8'h00, 24'h000060};
wire [31:0] p_maint_addr_remote = {8'h01, 24'h000060};

// ============================================================
// Maintenance Request Information Register (offset 0x10100)
// 写入数据：TID=0, Priority=0, CRF=0, DestID=0x00FE
// ============================================================
wire [31:0] p_maint_addr_reqinfo = {8'h00, 24'h10100};
wire [31:0] p_maint_wdata_reqinfo = {8'h00, 8'h00, 16'h00FE};

// 本端（引擎1侧）Device ID = 0xFF
localparam  P_EXPECT_LOCAL  = 32'h000000FF;
// 接口2 Device ID = 0xFE
localparam  P_EXPECT_REMOTE = 32'h000000FE;

reg [7:0]   r_cur_state ;
reg [7:0]   r_next_state;

always @(posedge i_log_clk) begin
    if(i_log_rst)
        r_cur_state <= P_ST_IDLE;
    else
        r_cur_state <= r_next_state;
end

always @(*) begin
    r_next_state = r_cur_state;
    case(r_cur_state)
        P_ST_IDLE: begin
            if(i_port_initialized && i_engine1_start)
                r_next_state = P_ST_WRITE_REQ;
        end
        P_ST_WRITE_REQ: begin
            if(i_maintr_awready && i_maintr_wready)
                r_next_state = P_ST_WRITE_WAIT;
        end
        P_ST_WRITE_WAIT: begin
            if(i_maintr_bvalid)
                r_next_state = P_ST_READ_LOCAL;
        end
        P_ST_READ_LOCAL: begin
            if(i_maintr_arready)
                r_next_state = P_ST_WAIT_LOCAL;
        end
        P_ST_WAIT_LOCAL: begin
            if(i_maintr_rvalid)
                r_next_state = P_ST_READ_REMOTE;
        end
        P_ST_READ_REMOTE: begin
            if(i_maintr_arready)
                r_next_state = P_ST_WAIT_REMOTE;
        end
        P_ST_WAIT_REMOTE: begin
            if(i_maintr_rvalid)
                r_next_state = P_ST_DONE;
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
        o_rd_data_init      <= 32'd0;
        o_rd_data_back      <= 32'd0;
        o_maint_done        <= 1'b0;
    end
    else begin
        case(r_cur_state)
            P_ST_IDLE: begin
                o_maintr_awvalid    <= 1'b0;
                o_maintr_wvalid     <= 1'b0;
                o_maintr_bready     <= 1'b0;
                o_maintr_arvalid    <= 1'b0;
                o_maintr_rready     <= 1'b0;
                o_maint_done        <= 1'b0;
            end
            P_ST_WRITE_REQ: begin
                o_maintr_awvalid    <= 1'b1;
                o_maintr_awaddr     <= p_maint_addr_reqinfo;
                o_maintr_wvalid     <= 1'b1;
                o_maintr_wdata      <= p_maint_wdata_reqinfo;
                o_maintr_bready     <= 1'b1;
            end
            P_ST_WRITE_WAIT: begin
                o_maintr_awvalid    <= 1'b0;
                o_maintr_wvalid     <= 1'b0;
                o_maintr_bready     <= 1'b1;
            end
            P_ST_READ_LOCAL: begin
                o_maintr_arvalid    <= 1'b1;
                o_maintr_araddr     <= p_maint_addr_local;
                o_maintr_rready     <= 1'b1;
            end
            P_ST_WAIT_LOCAL: begin
                o_maintr_arvalid    <= 1'b0;
                o_maintr_rready     <= 1'b1;
                if(i_maintr_rvalid) begin
                    o_rd_data_init  <= i_maintr_rdata;
                end
            end
            P_ST_READ_REMOTE: begin
                o_maintr_arvalid    <= 1'b1;
                o_maintr_araddr     <= p_maint_addr_remote;
                o_maintr_rready     <= 1'b1;
            end
            P_ST_WAIT_REMOTE: begin
                o_maintr_arvalid    <= 1'b0;
                o_maintr_rready     <= 1'b1;
                if(i_maintr_rvalid) begin
                    o_rd_data_back  <= i_maintr_rdata;
                end
            end
            P_ST_DONE: begin
                o_maint_done <= (o_rd_data_init[23:16] == P_EXPECT_LOCAL[7:0]) &&
                                (o_rd_data_back[23:16] == P_EXPECT_REMOTE[7:0]);
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

ila_0 u_ila_maint1 (
    .clk        (i_log_clk),
    .probe0     (r_cur_state),
    .probe1     ({i_port_initialized, i_engine1_start, o_maint_done}),
    .probe2     (o_maintr_araddr),
    .probe3     (o_maintr_awaddr),
    .probe4     ({o_maintr_arvalid, i_maintr_arready, i_maintr_rvalid, o_maintr_rready}),
    .probe5     (i_maintr_rdata),
    .probe6     (i_maintr_rresp),
    .probe7     ({o_maintr_awvalid, i_maintr_awready, o_maintr_wvalid, i_maintr_wready, i_maintr_bvalid, o_maintr_bready}),
    .probe8     (o_maintr_wdata),
    .probe9     (i_maintr_bresp),
    .probe10    (o_rd_data_init),
    .probe11    (o_rd_data_back)
);

endmodule