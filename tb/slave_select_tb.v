module slave_select_tb;

// Inputs
reg pclk;
reg preset_n;
reg mstr;
reg spiswai;
reg [1:0] spi;
reg send_data;
reg [11:0]baudratedivisor;

// Outputs
wire receive_data;
wire ss;
wire tip;

// Instantiate the Unit Under Test (UUT)
slave_select uut (
.pclk(pclk),
.preset_n(preset_n),
.mstr(mstr),
.spiswai(spiswai),
.spi(spi),
.send_data(send_data),
.baudratedivisor(baudratedivisor),
.receive_data(receive_data),
.ss(ss),
.tip(tip)
);

task initialize;
begin// Initialize Inputs
pclk = 0;
preset_n = 0;
mstr = 0;
spiswai = 0;
spi = 0;
send_data = 0;
baudratedivisor = 4;
end
endtask

always #5pclk=~pclk;
task reset;
begin
@(negedge pclk)
preset_n=1'b0;
@(negedge pclk)
preset_n=1'b1;
end
endtask

task inputs(input i,j,k, input [1:0]l,[11:0]m);
begin
@(negedge pclk)
mstr=i;
spiswai=j;
send_data=k;
spi=l;
baudratedivisor=m;
end
endtask

initial begin
initialize;
reset;
inputs(1,0,1,2'b01,12'd4);
inputs(1,0,0,2'b01,12'd4);

end

initial
$monitor("preset_n=%b mstr=%b spiswai=%b spi=%b send_data=%b baudratediv=%b receive_data=%b ss=%b tip=%b",preset_n,mstr,spiswai,spi,send_data,baudratedivisor,receive_data,ss,tip);

initial
#400$finish;

     
endmodule
