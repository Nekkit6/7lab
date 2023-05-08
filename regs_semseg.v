`timescale 1ns / 1ps

module regs_semseg(
    input req_i, we_i, CLK100, resetn,
    input [31:0] wdata_i, addr_i,
    output reg [31:0] out, //////////// ??
    output CA, CB, CC, CD, CE, CF, CG, 
    output [7:0] AN
  );
  
  `define addr_seg0 12'h000 //адрес значения 0сег
  `define addr_seg1 12'h004 //адрес значения 1сег
  `define addr_seg2 12'h008 //адрес значения 2сег
  `define addr_seg3 12'h00C //адрес значения 3сег
  `define addr_seg4 12'h010 //адрес значения 4сег
  `define addr_seg5 12'h014 //адрес значения 5сег
  `define addr_seg6 12'h018 //адрес значения 6сег
  `define addr_seg7 12'h01C //адрес значения 7сег
  `define addr_sel  12'h020 //адрес активации семсег
  `define addr_strb 12'h024 //адрес режима выбора
  `define addr_res  12'h028 //адрес сброса
  `define delay_seg 10**8   //задержка мигания
  `define pwm       1000    //шим сегментов
  
  reg [9:0] counter;
  reg [7:0] semseg;
  reg [7:0] ANreg;
  reg CAr, CBr, CCr, CDr, CEr, CFr, CGr;
  reg [31:0] wdata_seg;
  reg [7:0]  select_seg;
  reg        clk_strb;
  reg [31:0] strb_buf;
 // reg [7:0]  data_strb;
  reg [7:0]  strb_sel;
  
  assign AN = ANreg | ~(select_seg | (strb_sel & {8{clk_strb}}));
  assign {CA, CB, CC, CD, CE, CF, CG} = {CAr, CBr, CCr, CDr, CEr, CFr, CGr};
  
  always @(posedge CLK100) begin
    if (!resetn) begin
      counter <= 'b0;
      ANreg[7:0] <= 8'b11111111;
      {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b1111111;
      select_seg <= 'b0;
      clk_strb <= 'b0;
      strb_buf <= 'b0;
      strb_sel <= 'b0;
      out      <= 'b0;
     // data_strb <= 'b0;
    end
    else begin
      if(req_i)
        case (addr_i[11:0])
          `addr_seg0: begin
            if(we_i) wdata_seg[3:0] <= wdata_i[31:4]? wdata_seg[3:0]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_seg1: begin
            if(we_i) wdata_seg[7:4] <= wdata_i[31:4]? wdata_seg[7:4]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_seg2: begin
            if(we_i) wdata_seg[11:8] <= wdata_i[31:4]? wdata_seg[11:8]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_seg3: begin
            if(we_i) wdata_seg[15:12] <= wdata_i[31:4]? wdata_seg[15:12]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_seg4: begin
            if(we_i) wdata_seg[19:16] <= wdata_i[31:4]? wdata_seg[19:16]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_seg5: begin
            if(we_i) wdata_seg[23:20] <= wdata_i[31:4]? wdata_seg[23:20]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_seg6: begin
            if(we_i) wdata_seg[27:24] <= wdata_i[31:4]? wdata_seg[27:24]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_seg7: begin
            if(we_i) wdata_seg[31:28] <= wdata_i[31:4]? wdata_seg[31:28]: wdata_i[3:0];
            out <= wdata_seg;
          end
          `addr_sel: begin
            if(we_i) select_seg <= wdata_i[31:8]? select_seg: wdata_i[7:0];
            out <= 'b0 | select_seg;
          end
          `addr_strb: begin
            if(we_i) 
              if (&wdata_i[7:0]) //если пришло FF
                strb_sel <= 'b0; //режим не используется
              else if (&(~wdata_i[7:4])) //если 0х0?
                  strb_sel <= 8'b1 << wdata_i[3:0];
            out <= 'b0 | strb_sel;
          end
          `addr_res: begin
            if(we_i) begin
              wdata_seg <= 'b0;
              select_seg <= 8'hFF;
              strb_sel <= 'b0;
            end
            out <= 'b0;
          end
          default: out <= 'b0;
        endcase
      
      if (strb_buf == `delay_seg) begin 
        clk_strb <= ~clk_strb;
        strb_buf <= 'b0;
      end else 
        strb_buf <= strb_buf + 1'b1;
      if (counter < `pwm) counter <= counter + 'b1;
      else begin
        counter <= 'b0;
        ANreg[1] <= ANreg[0];
        ANreg[2] <= ANreg[1];
        ANreg[3] <= ANreg[2];
        ANreg[4] <= ANreg[3];
        ANreg[5] <= ANreg[4];
        ANreg[6] <= ANreg[5];
        ANreg[7] <= ANreg[6];
        ANreg[0] <= !(ANreg[6:0] == 7'b1111111);
      end
      case (1'b0)
        ANreg[0]: semseg <= wdata_seg[3 : 0];
        ANreg[1]: semseg <= wdata_seg[7 : 4];
        ANreg[2]: semseg <= wdata_seg[11: 8];
        ANreg[3]: semseg <= wdata_seg[15:12];
        ANreg[4]: semseg <= wdata_seg[19:16];
        ANreg[5]: semseg <= wdata_seg[23:20];
        ANreg[6]: semseg <= wdata_seg[27:24];
        ANreg[7]: semseg <= wdata_seg[31:28];
      endcase
      case (semseg)
          4'h0: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0000001;
          4'h1: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b1001111;
          4'h2: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0010010;
          4'h3: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0000110;
          4'h4: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b1001100;
          4'h5: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0100100;
          4'h6: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0100000;
          4'h7: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0001111;
          4'h8: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0000000;
          4'h9: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0000100;
          4'hA: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0001000;
          4'hB: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b1100000;
          4'hC: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0110001;
          4'hD: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b1000010;
          4'hE: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0110000;
          4'hF: {CAr, CBr, CCr, CDr, CEr, CFr, CGr} <= 7'b0111000;
          default: {CAr,CBr,CCr,CDr, CEr, CFr, CGr} <= 7'b1111111;
      endcase
    end
  end
endmodule
