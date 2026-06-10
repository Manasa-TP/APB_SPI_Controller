module spi_top_tb();
    // Inputs to Top Module
    reg pclk;
    reg preset_n;
    reg [2:0] paddr;
    reg pwrite;
    reg psel;
    reg penable;
    reg [7:0] pwdata;
    reg miso;

    // Outputs from Top Module
    wire [7:0] prdata;
    wire pready;
    wire pslverr;
    wire mosi;
    wire sclk;
    wire ss;
    wire spi_interrupt_request;

    // Instantiate the Top Module
    spi_top uut (
        .pclk(pclk),
        .preset_n(preset_n),
        .paddr(paddr),
        .pwrite(pwrite),
        .psel(psel),
        .penable(penable),
        .pwdata(pwdata),
        .miso(miso),
        .prdata(prdata),
        .pready(pready),
        .pslverr(pslverr),
        .mosi(mosi),
        .sclk(sclk),
        .ss(ss),
        .spi_interrupt_request(spi_interrupt_request)
    );

    // Generate Clock: 100MHz (10ns period)
    initial pclk = 0;
    always #5 pclk = ~pclk;

    initial begin
        // --- Step 1: Initialize and Reset ---
        preset_n = 0;
        psel = 0;
        penable = 0;
        pwrite = 0;
        paddr = 0;
        pwdata = 0;
        miso = 0; // Simulate slave sending 0
        
        #20 preset_n = 1;
        #20;

        // --- Step 2: Configure SPI (Write to CR1) ---
        // Address 3'b000: Enable SPI (bit 6) and Master Mode (bit 4)
        // Value 8'h50 = 01010000
        apb_write(3'b000, 8'h50);

        // --- Step 3: Set Baud Rate (Write to BR) ---
        // Address 3'b010: Set SPPR and SPR
        apb_write(3'b010, 8'h11); 

        // --- Step 4: Start Transmission (Write 8'hA5 to DR) ---
        // Address 3'b101: Data Register [cite: 35]
        apb_write(3'b101, 8'hA5);

        // Wait for transmission to complete (8 clock cycles minimum)
        // Based on baudrate, this takes time. We wait for SS to go high.
        wait(ss == 0); 
        wait(ss == 1);
        
        #100;
        $display("Simulation Finished. Check MOSI for 10100101 pattern.");
        $finish;
    end

    // Task for APB Write Cycle
    task apb_write(input [2:0] addr, input [7:0] data);
        begin
            @(posedge pclk);
            psel = 1;
            pwrite = 1;
            paddr = addr;
            pwdata = data;
            @(posedge pclk);
            penable = 1;
            wait(pready); // Wait for peripheral to be ready [cite: 32]
            @(posedge pclk);
            psel = 0;
            penable = 0;
        end
    endtask

endmodule
