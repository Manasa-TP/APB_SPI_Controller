module baud_rate(
    input        pclk,
    input        preset,     // Note: internal logic uses 'preset'
    input        spiswait,
    input        cpol,
    input        cphase,
    input        ss,
    input  [2:0] sppr,
    input  [2:0] spr,
    input  [1:0] spi_mode,

    output reg sclk,
    output reg miso_receive_sclkp,
    output reg miso_receive_sclkn,
    output reg mosi_send_sclkp,
    output reg mosi_send_sclkn,
    output [11:0] baudrate_divisor
);

// Your logic (Internal wires, Always blocks) remains exactly as it was below this point...
// ---------------- INTERNAL ----------------
wire pre_sclk;
reg  [11:0] count;

// synthesis-safe
assign baudrate_divisor = (sppr + 1) << (spr + 1);
assign pre_sclk = cpol;

// ---------------- COUNT + SCLK ----------------
always @(posedge pclk or negedge preset) begin
    if (!preset) begin
        count <= 0;
        sclk  <= pre_sclk;
    end
    else if (!ss && !spiswait && (spi_mode == 2'b00 || spi_mode == 2'b01)) begin
        if (count == ((baudrate_divisor >> 1) - 1)) begin
            count <= 0;
            sclk  <= ~sclk;
        end
        else begin
            count <= count + 1;
        end
    end
    else begin
        count <= 0;
        sclk  <= pre_sclk;
    end
end

// ---------------- MISO RECEIVE ----------------
always @(posedge pclk or negedge preset) begin
    if (!preset) begin
        miso_receive_sclkp <= 0;
        miso_receive_sclkn <= 0;
    end
    else if ((~cpol && cphase) || (~cphase && cpol)) begin
        if (sclk && count == ((baudrate_divisor >> 1) - 1))
            miso_receive_sclkn <= 1;
        else
            miso_receive_sclkn <= 0;

        miso_receive_sclkp <= 0;
    end
    else begin
        if (!sclk && count == ((baudrate_divisor >> 1) - 1))
            miso_receive_sclkp <= 1;
        else
            miso_receive_sclkp <= 0;

        miso_receive_sclkn <= 0;
    end
end

// ---------------- MOSI SEND ----------------
always @(posedge pclk or negedge preset) begin
    if (!preset) begin
        mosi_send_sclkp <= 0;
        mosi_send_sclkn <= 0;
    end
    else if ((!cpol && cphase) || (!cphase && cpol)) begin
        if (sclk && count == ((baudrate_divisor >> 1) - 2))
            mosi_send_sclkn <= 1;
        else
            mosi_send_sclkn <= 0;

        mosi_send_sclkp <= 0;
    end
    else begin
        if (!sclk && count == ((baudrate_divisor >> 1) - 2))
            mosi_send_sclkp <= 1;
        else
            mosi_send_sclkp <= 0;

        mosi_send_sclkn <= 0;
    end
end

endmodule
