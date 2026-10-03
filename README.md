# TwoSRIO1 - 双通道 SRIO 环回测试工程

基于 Xilinx Kintex-7 FPGA 的两路 SRIO (Serial RapidIO) 通道互联测试工程，用于验证 SRIO 链路的收发通路是否畅通。

## 工程概述

本工程实例化两路独立的 SRIO 通道，通过物理线缆将通道0与通道1对接，每个通道各自运行相同的 SRIO 协议引擎状态机，循环执行 NWRITE → Doorbell → NREAD → Message 四种事务，验证 SRIO 链路的双向数据传输能力。

## 目录结构

```
.
├── rtl/
│   ├── fpgatop.v                # 顶层模块
│   ├── SRIO_Mod.v               # SRIO 模块封装（含两个通道）
│   ├── SRIO_Ch.v                # 单路 SRIO 通道封装（含 IP 核 + 时钟/复位）
│   ├── SRIO_Engine.v            # SRIO 协议引擎（状态机，核心逻辑）
│   ├── rst_gen_module.v         # 复位生成模块
│   ├── si5338.vhd               # SI5338 时钟芯片配置（I2C）
│   └── si5338_i4_50_200_125_125_100.mif  # SI5338 配置参数
└── xdc/
    └── srio_gen2_0.xdc          # 引脚与时序约束
```

## 模块层次

```
fpgatop
├── SRIO_Engine_u0    → 通道0 协议引擎
├── SRIO_Engine_u1    → 通道1 协议引擎
├── SRIO_Mod
│   ├── SRIO_Ch1      → 通道0 SRIO IP 核 (srio_gen2_0) + 时钟/复位
│   └── SRIO_Ch2      → 通道1 SRIO IP 核 (srio_gen2_0) + 时钟/复位
├── rst_gen_module    → 系统复位
└── si5338            → 时钟芯片配置
```

## SRIO_Engine 状态机

每个通道的协议引擎循环执行以下状态：

| 状态 | 操作 | 报文类型 (ftype) | 说明 |
|------|------|------------------|------|
| IDLE | 等待 1000 拍 | - | 初始化延时 |
| WRITE | 发送 33 拍写请求 | 0101 (NWRITE) | 写入 32 拍数据 `{4{r_cnt}}` |
| DB | 发送门铃 | 1010 (Doorbell) | 通知写完成 |
| READ | 发送读请求并接收响应 | 0010 (NREAD) | 验证双向通路 |
| MESSAGE | 发送消息 | 1011 (Message) | 通知操作结束 |
| END | 回到 IDLE | - | 下一轮循环 |

> **注意**：NWRITE 数据在对端不会被存储，引擎仅验证通路畅通性，不做数据回读一致性校验。

## 四个 AXI-Stream 接口

| 接口 | 方向 | 作用 |
|------|------|------|
| m_axis_ireq_* | 本端→IP | 发起请求（NWRITE/NREAD/DB/Message） |
| s_axis_iresp_* | IP→本端 | 接收响应（NREAD 的数据响应） |
| s_axis_treq_* | IP→本端 | 接收对端请求 |
| m_axis_tresp_* | 本端→IP | 回复对端响应（NREAD 响应） |

## 目标器件与工具

- **目标 FPGA**：Xilinx Kintex-7 (xc7k325tffg900-2)
- **开发工具**：Vivado 2019.x
- **SRIO IP**：srio_gen2_0 (Serial RapidIO Gen2)
- **调试 IP**：ila_0 (Integrated Logic Analyzer)

## 使用方法

### 1. 重建工程

由于 IP 核文件未包含在本仓库中，需要在 Vivado 中重新生成：

1. 新建工程，目标器件选择 `xc7k325tffg900-2`
2. 添加 `rtl/` 下所有源文件
3. 添加 `xdc/` 下的约束文件
4. 在 IP Catalog 中添加并配置 **Serial RapidIO Gen2** (srio_gen2_0) 和 **ILA** (ila_0)
5. 综合、实现、生成比特流

### 2. 硬件连接

将 SRIO 通道0 与通道1 通过高速线缆对接（TX↔RX 交叉）。

### 3. 验证链路

- **LED 指示**：`link_initialized` 和 `port_initialized` 拉高表示链路训练完成
- **ILA 调试**：代码中已用 `(* MARK_DEBUG = "TRUE" *)` 标记关键 AXI-Stream 信号

## SRIO 事务格式参考

### NWRITE 报文头（第0拍）
```
ftype = 0101, ttype = 0100
```

### NREAD 报文头（第0拍）
```
ftype = 0010, ttype = 0100
```

### 响应报文头（第0拍，ftype=1101）
```
ttype = 1000  → 带数据响应，DONE（成功）
```

## 许可证

本工程仅供学习与参考使用。

