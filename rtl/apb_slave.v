module APB_slave( 
input pclk,
    input preset_n,
    input [2:0] paddr,
    input pwrite,
    input psel,
    input penable,
    input [7:0] pwdata,
    input ss,
    input [7:0]data_miso,
    input receive_data,
    input tip,
    output reg [7:0] prdata,
    output reg mstr,
    output reg cpol,
    output reg cphas,
    output reg lsbfe,
    output reg spiswai,
output reg [2:0] sppr,
    output reg [2:0] spr,
    output reg spi_inter_req,
    output pready,
    output pslverr,
    output reg send_data,
    output reg [7:0]data_mosi,
    output [1:0]spi
    );
 reg [7:0]cr1,cr2,br,dr;
 wire [7:0]sr;
 wire wr_en,rd_en;
 reg [1:0]state,next_state,state1,next_state1;
 wire spif,sptef,modf;
 reg modfen,sptie,ssoe,spie,spe;

parameter idle=2'b00,
          setup=2'b01,
enable=2'b10;

parameter spi_run=2'b00,
          spi_wait=2'b01,
spi_stop=2'b10;

parameter cr2_mask=8'b00011011,
          br_mask=8'b01110111;
assign spi=state1;
//apb states
always@(posedge pclk or negedge preset_n)
begin
if(!preset_n)
state<=idle;
else
state<=next_state;
end
always@(*)
begin
next_state=state;	
case(state)
2'b00:if(psel)
        next_state=setup;
 else
 next_state=idle;
2'b01:if(psel && !penable)
        next_state=setup;
       else if(psel && penable)
next_state=enable;
else next_state=idle;
2'b10:if(psel)
       next_state=setup;
else
next_state=idle;
default:next_state=idle;
endcase
end


//spi_modes
always@(posedge pclk or negedge preset_n)
begin
if(!preset_n)
state1<=spi_run;
else
state1<=next_state1;
end
always@(*)
begin
next_state1=state1;	
case(state1)
2'b00:if(!spe)
        next_state1=spi_wait;
 else
 next_state1=spi_run;
2'b01:if(!spe)
       next_state1 = spi_wait;
else if(spe)
next_state1=spi_run;
       else if(spiswai)
       next_state1 = spi_stop;
       else
        next_state1 = spi_wait;
2'b10:if(!spiswai)
       next_state1=spi_wait;
else if(spe)
next_state1=spi_run;
else
next_state1=spi_stop;
default:next_state1=spi_stop;
endcase
end


assign rd_en=(!pwrite && (state==enable))?1'b1:1'b0; //rd_enable

assign wr_en=(pwrite && (state==enable))?1'b1:1'b0; //wr_enable

assign pslverr=(state==enable)?(~tip):1'b0; //pslverr

assign pready=(state==enable)?1'b1:1'b0; //pready


//spicr1 //spicr2 //spibr
always@(posedge pclk or negedge preset_n)
begin
if(!preset_n)
begin
cr1<=8'h04;
cr2<=8'h00;
br<=8'h00;
end
else if(wr_en)
 begin
    case(paddr)
   3'b000:cr1<=pwdata;
3'b001:cr2<=(pwdata & cr2_mask);
3'b010:br<=(pwdata & br_mask);
endcase
end
else if (!((paddr==3'b000) | (paddr==3'b001) | (paddr==3'b010)))
begin
 cr1<=cr1;
 cr2<=cr2;
 br<=br;
end
/*else
begin
cr1<=8'h04;
cr2<=8'h00;
br<=8'h00;
end*/
end

//spi sr
assign sr=(preset_n)?8'b00100000:{spif,1'b0,sptef,modf,4'b0}; //spi_sr



//spi_dr
always@(posedge pclk or negedge preset_n)
begin
if(!preset_n)
dr<=8'b0;
else if(wr_en)
begin
if(paddr==3'b101)
dr<=pwdata;
else
dr<=dr;
end
else
begin
if(pwdata==((dr==pwdata) && (dr !=data_miso) && ((spi == spi_run) || (spi == spi_wait))))
dr<=8'b0;
else
begin
if(receive_data & ((spi == spi_run) || (spi == spi_wait)))
dr<=data_miso;
else
dr<=dr;
end
end
end


// PRDATA
always @(*)
begin
    if (!rd_en)
        prdata <= 8'b0;
    else
    begin
        case (paddr)
            3'b000: prdata <= cr1;
            3'b001: prdata <= cr2;
            3'b010: prdata <= br;
            3'b011: prdata <= sr;
3'b101: prdata <= dr;
            3'b100: prdata <= 8'b0;
            3'b110: prdata <= 8'b0;
            3'b111: prdata <= 8'b0;
default:prdata<=8'b0;
        endcase
    end
end

//reg pins
always@(*)
begin
 mstr=cr1[4];//mstr
 cpol=cr1[3];//cpol
 cphas=cr1[2];//cpha
 lsbfe=cr1[0];//lsbfe
 spie=cr1[7];//spie
 spe=cr1[6];//spe
 sptie=cr1[5];//sptie
 modfen=cr2[4];//modfen
 spiswai=cr2[1];//spiswai
 sppr=br[6:4];//sppr
 spr=br[2:0];//spr
 ssoe=cr1[1];//ssoe
end

assign sptef=(dr==8'b00000000)?1'b1:1'b0;//sptef
assign spif=(dr!=8'b00000000)?1'b1:1'b0;//spif
assign modf=(!ss & mstr & modfen & !ssoe);//modf


//spi_interrupt_request
always@(*)
begin
  if(!spie & !sptie)
    spi_inter_req=1'b0;
 else if (!(!sptie & spie))
 begin
  if(!spie & sptie)
   spi_inter_req=sptef;
  else
   spi_inter_req=(spif | modf | sptef);
 end
 else
  spi_inter_req=(spif | modf);
end



//send_data
always@(posedge pclk or negedge preset_n)
begin
 if(!preset_n)
      send_data<=0;
else if(wr_en && (paddr == 3'b101))
   send_data <= 1'b1;              
else
   send_data <= 1'b0;
end


//data_mosi
always@(posedge pclk or negedge preset_n)
begin
    if(!preset_n)
        data_mosi <= 8'b0;
    else if(wr_en && (paddr == 3'b101))
        data_mosi <= pwdata;
    else
        data_mosi <= data_mosi;
end

 
endmodule
