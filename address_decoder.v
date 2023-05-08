`timescale 1ns / 1ps

module address_decoder(
    input we_i, req_i,
    input [31:0] addr_i,
    output reg req_m, we_m, 
    output reg req_d0, req_d1, req_d2, req_d3, req_d4, req_d5, we_d, //d0-светодиоды d1-семсег d2-sw d3-клава d4-rx d5-tx
    output reg [2:0] RDsel_o      //0-mem 1-d0..
    );

  always @(*) begin
  {req_m, we_m, req_d0, req_d1, req_d2, req_d3, req_d4, req_d5, we_d, RDsel_o} = 'b0;
  if (req_i)
    case(addr_i[31:12])
      20'h80000: begin //led
        req_d0 = 1;
        RDsel_o = 3'd1;
        we_d = we_i;
      end
      20'h80001: begin //semseg
        req_d1 = 1;
        RDsel_o = 3'd2;
        we_d = we_i;
      end
      20'h80002: begin //sw
        req_d2 = 1;
        RDsel_o = 3'd3;
        we_d = we_i;
      end
      20'h80003: begin //keyboard
        req_d3 = 1;
        RDsel_o = 3'd4;
        we_d = we_i;
      end
      20'h80004: begin //rx
        req_d4 = 1;
        RDsel_o = 3'd5;
        we_d = we_i;
      end
      20'h80005: begin //tx
        req_d5 = 1;
        RDsel_o = 3'd6;
        we_d = we_i;
      end
      default: begin
        req_m = 1;
        we_m = we_i;
        RDsel_o = 3'b0;
      end
    endcase
  end
    
endmodule
