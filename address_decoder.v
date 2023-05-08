`timescale 1ns / 1ps

module address_decoder(
    input we_i, req_i,
    input [31:0] addr_i,
    output reg req_m, we_m, 
    output reg [5:0] req, //0-й бит-светодиоды 1-семсег 2-sw 3-клава 4-rx 5-tx
    output reg we_d, 
    output reg [2:0] RDsel_o      //0-mem 1-d0..
    );

  always @(*) begin
  {req_m, we_m, req, we_d, RDsel_o} = 'b0;
  if (req_i)
    case(addr_i[31:12])
      20'h80000: begin //led
        req = 5'h01;
        RDsel_o = 3'd1;
        we_d = we_i;
      end
      20'h80001: begin //semseg
        req = 5'h02;
        RDsel_o = 3'd2;
        we_d = we_i;
      end
      20'h80002: begin //sw
        req = 5'h04;
        RDsel_o = 3'd3;
        we_d = we_i;
      end
      20'h80003: begin //keyboard
        req = 5'h08;
        RDsel_o = 3'd4;
        we_d = we_i;
      end
      20'h80004: begin //rx
        req = 5'h10;
        RDsel_o = 3'd5;
        we_d = we_i;
      end
      20'h80005: begin //tx
        req = 5'h20;
        RDsel_o = 3'd6;
        we_d = we_i;
      end
      default: begin
        req_m = 'b1;
        we_m = we_i;
        RDsel_o = 3'b0;
      end
    endcase
  end
    
endmodule
