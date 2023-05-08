`timescale 1ns / 1ps

module regs_sw(
    input req_i, CLK100, resetn,
    input [31:0] addr_i,
    input [15:0] SW,
    input BTNU, BTNL, BTNC, BTNR, BTND,
    output reg [31:0] out
    );
  `define addr_sw  12'h000 //адрес значений переключателей
  `define addr_btn 12'h004 //адрес значений кнопок
  
  always @(posedge CLK100) begin
    if(!resetn) 
      out <= 'b0;
    else begin
      if(req_i) begin
        if(addr_i[11:0] == `addr_sw)
          out <= 'b0 | SW;
        if(addr_i[11:0] == `addr_btn)
          out <= 'b0 | {BTNU, BTNL, BTNC, BTNR, BTND};
      end
    end
  end
endmodule
