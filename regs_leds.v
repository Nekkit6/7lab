`timescale 1ns / 1ps

module regs_leds(
    input req_i, we_i, CLK100, resetn,
    input [31:0] wdata, addr_i,
    output reg [31:0] out,
    output [15:0] LED
  );
  `define addr_led       12'h800 //адрес значений светодиодов
  `define addr_strb_led  12'hf00 //адрес мигания  светодиодов
  `define delay_LED      10**8   //задержка мигания

  reg        clk_strb;
  reg [31:0] strb_buf;
  reg [15:0] data_strb;
  reg [15:0] LED_reg;
  assign LED = clk_strb? LED_reg | data_strb: LED_reg & ~data_strb;
 // assign out = LED;

  always @(posedge CLK100) begin
    if(!resetn) begin
      strb_buf  <= 'b0;
      clk_strb  <= 'b0;
      data_strb <= 'b0;
      LED_reg   <= 'b0;
      out       <= 'b0;
    end else begin
      if (strb_buf == `delay_LED) begin 
        clk_strb = ~clk_strb;
        strb_buf <= 'b0;
      end else 
        strb_buf <= strb_buf + 1'b1;
      if(req_i) begin
        if(addr_i[11:0] == `addr_led) begin
          if(we_i) LED_reg <= wdata[31:16]? LED_reg: wdata[15:0];
          out <= 'b0 | LED_reg;
        end
        if(addr_i[11:0] == `addr_strb_led) begin
          if(we_i) data_strb <= wdata[31:16]? data_strb: wdata[15:0];
          out <= 'b0 | data_strb;
        end
      end
    end
  end
endmodule
