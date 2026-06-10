module shift_reg_tb;

// Inputs
reg pclk;
reg preset_n;
reg ss;
reg send_data;
reg lsbfe;
reg cpha;
reg cpol;
reg miso_receive_sclk;
reg miso_receive_sclk1;
reg mosi_send_sclk;
reg mosi_send_sclk1;
reg [7:0] data_mosi;
reg miso;
reg receive_data;

// Outputs
wire mosi;
wire [7:0] data_miso;

// Instantiate the Unit Under Test (UUT)
shift_reg uut (
.pclk(pclk),
.preset_n(preset_n),
.ss(ss),
.send_data(send_data),
.lsbfe(lsbfe),
.cpha(cpha),
.cpol(cpol),
.miso_receive_sclk(miso_receive_sclk),
.miso_receive_sclk1(miso_receive_sclk1),
.mosi_send_sclk(mosi_send_sclk),
.mosi_send_sclk1(mosi_send_sclk1),
.data_mosi(data_mosi),
.miso(miso),
.receive_data(receive_data),
.mosi(mosi),
.data_miso(data_miso)
);

task initialize;
begin
// Initialize Inputs
pclk = 0;
preset_n = 0;
ss = 1;
send_data = 0;
lsbfe = 0;
cpha = 0;
cpol = 0;
miso_receive_sclk = 0;
miso_receive_sclk1 = 0;
mosi_send_sclk = 0;
mosi_send_sclk1 = 0;
data_mosi = 0;
miso = 0;
receive_data = 0;
end
endtask

always #5pclk=~pclk;

task send(input [7:0]data,lsb);
begin
@(negedge pclk)
send_data=1;
data_mosi=data;
lsbfe=lsb;
#10;
send_data=0;
end
endtask

task flags(input r_sclk,r_sclk1,s_sclk,s_sclk1,i);
begin
miso_receive_sclk = r_sclk;
miso_receive_sclk1 = r_sclk1;
mosi_send_sclk = s_sclk;
mosi_send_sclk1 = s_sclk1;
ss=i;
end
endtask

task receive(input d,pol,phase);
begin
receive_data=1;
miso=d;
cpol=pol;
cpha=phase;
#10;
receive_data=0;
end
endtask


initial begin
initialize;
#10;
preset_n=1;
send(8'b11100011,1);
flags(1,0,1,0,0);
receive(1,1,1);
end

initial
$monitor("presetn=%b ss=%b senddata=%b lsbfe=%b cpol=%b cpha=%b receivedata=%b misoreceivesclk=%b misoreceivesclk1=%b mosisendsclk=%b mosisendsclk1=%b miso=%b datamosi=%b mosi=%b datamiso=%b",
   preset_n,ss,send_data,lsbfe,cpol,cpha,receive_data,miso_receive_sclk,miso_receive_sclk1,mosi_send_sclk,mosi_send_sclk1,miso,data_mosi,mosi,data_miso);

initial
#300$finish;
     
endmodule
