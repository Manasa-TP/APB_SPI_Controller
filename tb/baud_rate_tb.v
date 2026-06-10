module baud_rate_tb;

// ---------------- SIGNALS ----------------
reg pclk;
reg preset;
reg spiswait;
reg cpol;
reg cphase;
reg ss;
reg [2:0] sppr;
reg [2:0] spr;
reg [1:0] spi_mode;

wire sclk;
wire miso_receive_sclkp;
wire miso_receive_sclkn;
wire mosi_send_sclkp;
wire mosi_send_sclkn;
wire [11:0] baudrate_divisor;

// ---------------- DUT ----------------
baud_rate dut (
    .pclk(pclk),
    .preset(preset),
    .spiswait(spiswait),
    .cpol(cpol),
    .cphase(cphase),
    .ss(ss),
    .sppr(sppr),
    .spr(spr),
    .spi_mode(spi_mode),
    .sclk(sclk),
    .miso_receive_sclkp(miso_receive_sclkp),
    .miso_receive_sclkn(miso_receive_sclkn),
    .mosi_send_sclkp(mosi_send_sclkp),
    .mosi_send_sclkn(mosi_send_sclkn),
    .baudrate_divisor(baudrate_divisor)
);

// ---------------- CLOCK ----------------
always #5 pclk = ~pclk;

// ---------------- INITIAL ----------------
initial begin
    // init
    pclk = 0;
    preset = 0;
    spiswait = 0;
    cpol = 0;
    cphase = 0;
    ss = 1;
    sppr = 3'b001;
    spr  = 3'b001;
    spi_mode = 2'b00;

    // reset release
    #20 preset = 1;

    // enable SPI
    #20 ss = 0;

    // change mode
    #200 cpol = 1; cphase = 1;

    // wait
    #400;

    $finish;
end

endmodule
