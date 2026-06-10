   module spi_top(
    input        pclk,
    input        preset_n,
    input  [2:0] paddr,
    input        pwrite,
    input        psel,
    input        penable,
    input  [7:0] pwdata,
    input        miso,
    output [7:0] prdata,
    output       pready,
    output       pslverr,
    output       mosi,
    output       sclk,
    output       ss,
    output       spi_interrupt_request
);

    // Internal Wires
    wire mstr, cpol, cphas, lsbfe, spiswai, receive_data, send_data, tip;
    wire [2:0] sppr, spr;
    wire [1:0] spi_state;
    wire [7:0] data_miso, data_mosi;
    wire [11:0] baudrate_divisor;
    wire miso_receive_sclkp, miso_receive_sclkn, mosi_send_sclkp, mosi_send_sclkn;

    // Line 27: Ensure this instantiation matches the sub-module name exactly
    APB_slave APB_slave_inter (
        .pclk(pclk),
        .preset_n(preset_n),
        .paddr(paddr),        // DO NOT put [2:0] here
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable),
        .pwdata(pwdata),
        .ss(ss),
        .data_miso(data_miso),
        .receive_data(receive_data),
        .tip(tip),
        .prdata(prdata),
        .mstr(mstr),
        .cpol(cpol),
        .cphas(cphas),
        .lsbfe(lsbfe),
        .spiswai(spiswai),
        .sppr(sppr),
        .spr(spr),
        .spi_inter_req(spi_interrupt_request),
        .pready(pready),
        .pslverr(pslverr),
        .send_data(send_data),
        .data_mosi(data_mosi),
        .spi(spi_state)
    );

    baud_rate baudrate_generator (
        .pclk(pclk),
        .preset(preset_n),
        .spiswait(spiswai),
        .cpol(cpol),
        .cphase(cphas),
        .ss(ss),
        .sppr(sppr),
        .spr(spr),
        .spi_mode(spi_state),
        .sclk(sclk),
        .miso_receive_sclkp(miso_receive_sclkp),
        .miso_receive_sclkn(miso_receive_sclkn),
        .mosi_send_sclkp(mosi_send_sclkp),
        .mosi_send_sclkn(mosi_send_sclkn),
        .baudrate_divisor(baudrate_divisor)
    );

    slave_select spi_ss (
        .pclk(pclk),
        .preset_n(preset_n),
        .mstr(mstr),
        .spiswai(spiswai),
        .spi(spi_state),
        .send_data(send_data),
        .baudratedivisor(baudrate_divisor),
        .receive_data(receive_data),
        .ss(ss),
        .tip(tip)
    );

    shift_regi shift_register (
        .pclk(pclk),
        .preset_n(preset_n),
        .ss(ss),
        .send_data(send_data),
        .lsbfe(lsbfe),
        .cpha(cphas),
        .cpol(cpol),
        .miso_receive_sclk(miso_receive_sclkp),
        .miso_receive_sclk1(miso_receive_sclkn),
        .mosi_send_sclk(mosi_send_sclkp),
        .mosi_send_sclk1(mosi_send_sclkn),
        .data_mosi(data_mosi),
        .miso(miso),
        .receive_data(receive_data),
        .mosi(mosi),
        .data_miso(data_miso)
    );

endmodule 

