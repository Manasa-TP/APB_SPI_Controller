module APB_slave__tb;

reg pclk;
reg preset_n;
reg [2:0] paddr;
reg pwrite;
reg psel;
reg penable;
reg [7:0] pwdata;
reg ss;
reg [7:0] data_miso;
reg receive_data;
reg tip;

wire [7:0] prdata;
wire mstr;
wire cpol;
wire cphas;
wire lsbfe;
wire spiswai;
wire [2:0] sppr;
wire [2:0] spr;
wire spi_inter_req;
wire pready;
wire pslverr;
wire send_data;
wire [7:0] data_mosi;
wire [1:0] spi;

APB_slave uut (
.pclk(pclk),
.preset_n(preset_n),
.paddr(paddr),
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
.spi_inter_req(spi_inter_req),
.pready(pready),
.pslverr(pslverr),
.send_data(send_data),
.data_mosi(data_mosi),
.spi(spi)
);

task initialize;
begin
pclk = 0;
preset_n = 0;
paddr = 0;
pwrite = 0;
psel = 0;
penable = 0;
pwdata = 0;
ss = 1;
data_miso = 0;
receive_data = 0;
tip = 0;
end
endtask

always #5 pclk=~pclk;

task presetn;
begin
@(negedge pclk)
preset_n=1'b0;
@(negedge pclk)
preset_n=1'b1;
end
endtask

task cr1_write;
begin
@(negedge pclk)
paddr=3'b000;
pwrite=1'b1;
psel=1'b1;
penable=1'b0;
pwdata=8'b00110011;
@(negedge pclk)
penable=1'b1;
@(negedge pclk)
penable=1'b0;
psel=1'b0;
end
endtask

task cr2_write;
begin
@(negedge pclk)
paddr=3'b001;
pwrite=1'b1;
psel=1'b1;
penable=1'b0;
pwdata=8'b00110001;
@(negedge pclk)
penable=1'b1;
@(negedge pclk)
penable=1'b0;
psel=1'b0;
end
endtask

task br_write;
begin
@(negedge pclk)
paddr=3'b010;
pwrite=1'b1;
psel=1'b1;
penable=1'b0;
pwdata=8'b00110000;
@(negedge pclk)
penable=1'b1;
@(negedge pclk)
penable=1'b0;
psel=1'b0;
end
endtask

task dr_write;
begin
@(negedge pclk)
paddr=3'b101;
pwrite=1'b1;
psel=1'b1;
penable=1'b0;
pwdata=8'b00111111;
@(negedge pclk)
penable=1'b1;
@(negedge pclk)
penable=1'b0;
psel=1'b0;
end
endtask

task sr_read;
begin
@(negedge pclk)
paddr=3'b011;
pwrite=1'b0;
psel=1'b1;
penable=1'b0;
@(negedge pclk)
penable=1'b1;
@(negedge pclk)
penable=1'b0;
psel=1'b0;
end
endtask

task cr1_read;
begin
@(negedge pclk)
paddr=3'b000;
pwrite=1'b0;
psel=1'b1;
penable=1'b0;
@(negedge pclk)
penable=1'b1;
@(negedge pclk)
penable=1'b0;
psel=1'b0;
end
endtask

task cr2_read;
begin
@(negedge pclk)
paddr=3'b010;
pwrite=1'b0;
psel=1'b1;
penable=1'b0;
@(negedge pclk)
penable=1'b1;
@(negedge pclk)
penable=1'b0;
psel=1'b0;
end
endtask

task spi_receive_byte;
input [7:0] incoming_data;
begin
@(negedge pclk)
data_miso = incoming_data;
receive_data = 1'b1;
@(negedge pclk)
receive_data = 1'b0;
end
endtask

initial begin
initialize;
presetn;
cr1_write;
cr2_write;
br_write;
dr_write;
spi_receive_byte(8'b10101010);
cr1_read;
cr2_read;
sr_read;
end

initial
$monitor("preset_n=%b paddr=%b pwrite=%b penable=%b psel=%b pwdata=%b ss=%b miso_data=%b receive_data=%b tip=%b prdata=%b mstr=%b  cpol=%b cpha=%b lsbfe=%b spiswai=%b sppr=%b spr=%b spi_inter_req=%b pready=%b pslverr=%b send_data=%b mosi_data=%b spi=%b",
preset_n,paddr,pwrite,penable,psel,pwdata,ss,data_miso,receive_data,tip,prdata,mstr,cpol,cphas,lsbfe,spiswai,sppr,spr,spi_inter_req,pready,pslverr,send_data,data_mosi,spi);

initial
#300 $finish;

endmodule
