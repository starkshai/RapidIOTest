# RapidIO Maintenance Test

## Overview

This repository contains a RapidIO maintenance transaction test design for the Xilinx Serial RapidIO Gen2 IP core. The design uses the AXI4-Lite maintenance port to access the configuration space of both the local endpoint and a remote endpoint. The test reads the Base Device ID CSR from both endpoints and verifies the returned values.

The repository is intended for hardware bring-up, simulation, and debugging of RapidIO maintenance transactions.

## Features

- AXI4-Lite maintenance read and write transactions
- Local and remote configuration space access
- Remote destination ID configuration through the Maintenance Request Information Register
- Link and port initialization monitoring
- ILA-based debug support
- Simple pass/fail indication
- Independent I/O engine test path

## Repository Structure

| File | Description |
|------|-------------|
| `fpgatop.v` | Top-level module. Instantiates SRIO channels, I/O engines, maintenance engines, and LED/status logic. |
| `SRIO_Ch1.v` | SRIO channel 1 wrapper. Contains the SRIO Gen2 IP core instance and exposes AXI4-Lite maintenance and AXI4-Stream I/O interfaces. |
| `SRIO_Ch2.v` | SRIO channel 2 wrapper. Same structure as channel 1. |
| `SRIO_Mod.v` | SRIO module wrapper. Instantiates both SRIO channels. |
| `SRIO_Engine1.v` | Initiator engine. Generates I/O transactions such as Doorbell, NWRITE, NREAD, and Message. |
| `SRIO_Engine2.v` | Target/responder engine. Responds to I/O transactions from engine 1. |
| `maintengine1.v` | Maintenance initiator engine. Configures the remote destination ID, reads the local Base Device ID CSR, reads the remote Base Device ID CSR, and compares the results. |
| `maintengine2.v` | Maintenance polling engine. Reads the local Base Device ID CSR and checks the returned value. |

Additional constraint files, simulation files, or board-specific files may be present depending on the project setup.

## Module Description

### `maintengine1.v`

The maintenance engine 1 is the core test module. It uses a state machine to perform the following sequence:

1. Wait for port/link initialization and a start signal.
2. Write the Maintenance Request Information Register at offset `0x10100` to set the remote destination ID.
3. Wait for the write response.
4. Issue a local maintenance read to the Base Device ID CSR at offset `0x60`.
5. Capture the local read data.
6. Issue a remote maintenance read to the Base Device ID CSR at offset `0x60`.
7. Capture the remote read data.
8. Compare the returned Device ID fields and assert a done flag.

Key address definitions used in the design:

```verilog
// Local read: hop = 0, offset = 0x60
wire [31:0] p_maint_addr_local  = {8'h00, 24'h000060};

// Remote read: hop count + 1 = 1, offset = 0x60
wire [31:0] p_maint_addr_remote = {8'h01, 24'h000060};

// Maintenance Request Information Register: offset 0x10100
wire [31:0] p_maint_addr_reqinfo  = {8'h00, 24'h10100};
wire [31:0] p_maint_wdata_reqinfo = {8'h00, 8'h00, 16'h00FE};
```

### `maintengine2.v`

The maintenance engine 2 periodically reads the local Base Device ID CSR at offset `0x60`. It extracts the Device ID field from the read data and compares it with the expected value. When the values match, it asserts a received flag.

### `SRIO_Engine1.v` and `SRIO_Engine2.v`

These modules exercise the RapidIO I/O path through AXI4-Stream Initiator/Target interfaces. Engine 1 generates request transactions, and engine 2 returns responses. This path is independent of the maintenance path and is useful for verifying the data movement capabilities of the SRIO Gen2 IP core.

## Maintenance Read Flow

The intended maintenance read flow is:

1. Wait until `port_initialized` and `link_initialized` are asserted.
2. Write the Maintenance Request Information Register at offset `0x10100` with the target Device ID in bits `[15:0]`.
3. Wait for the write response (`BVALID`).
4. Issue a local maintenance read:
   - Address: `{8'h00, 24'h000060}`
   - Expect `RRESP = 2'b00` and valid `RDATA`.
5. Issue a remote maintenance read:
   - Address: `{8'h01, 24'h000060}`
   - Expect `RRESP = 2'b00` and valid `RDATA`.
6. Extract the Device ID from the returned data.
7. Compare local and remote Device IDs with expected values.

## Address Format

The AXI4-Lite maintenance port uses the following address format:

| Bits | Meaning |
|------|---------|
| `[31:24]` | Hop count + 1. Use `8'h00` for local access. |
| `[23:0]` | Configuration register byte offset. |

The remote destination ID is not encoded in the address. It must be written to the Maintenance Request Information Register before issuing a remote maintenance request.

## Base Device ID CSR

The Base Device ID CSR is located at configuration offset `0x60`.

| Bits | Field | Description |
|------|-------|-------------|
| `[31:24]` | Reserved | |
| `[23:16]` | Base_deviceID | 8-bit Device ID for small transport systems |
| `[15:0]` | Large_base_deviceID | 16-bit Device ID for large transport systems |

For an 8-bit Device ID configuration, the Device ID is read from bits `[23:16]`.

## IP Core Configuration

The SRIO Gen2 IP core should be configured as follows for this test:

- **Maintenance Style**: AXI4-Lite Maintenance Port
- **I/O Style**: Initiator/Target
- **Device ID Width**: 8-bit
- **Component Device ID**: Channel 1 = `0xFF`, Channel 2 = `0xFE` (or as required by the test setup)

## Hardware Setup

- Two SRIO channels connected through GT transceivers, either in loopback or back-to-back.
- Reference clock supplied according to the IP core configuration.
- Reset and clock inputs connected according to the board design.
- Ensure both endpoints are released from reset together to maintain ackID alignment.

## LED Indicators

| LED | Signal | Meaning |
|-----|--------|---------|
| `led[0]` | Channel 1 link initialized | SRIO channel 1 link is up |
| `led[1]` | Channel 1 port initialized | SRIO channel 1 port is initialized |
| `led[2]` | Channel 2 link initialized | SRIO channel 2 link is up |
| `led[3]` | Channel 2 port initialized | SRIO channel 2 port is initialized |

## ILA Debug

`maintengine1.v` instantiates an ILA for hardware debugging. Useful signals to observe include:

- Current state of the maintenance state machine
- `ARADDR` and `AWADDR`
- `ARVALID`, `ARREADY`, `RVALID`, `RREADY`
- `RDATA` and `RRESP`
- `AWVALID`, `AWREADY`, `WVALID`, `WREADY`
- `BVALID`, `BREADY`, `BRESP`
- Captured local and remote read data
- Maintenance done flag

## Notes

- The AXI4-Lite maintenance port allows only one outstanding read and one outstanding write at a time.
- The LOG checks the response TID. Responses with mismatched TIDs are silently dropped.
- The remote endpoint’s Register Manager automatically responds to maintenance requests. No additional user logic is required on the remote side.
- Ensure `link_initialized` is asserted before starting maintenance transactions.
- If a maintenance request times out or becomes stuck, use the maintenance reset to clear outstanding packets.
- Writes to reserved register offsets terminate normally and do not cause an error.
- Writes to read-only capability registers terminate normally and do not cause an error.
