`default_nettype none

module spi_peripheral (
    input wire clk,
    input wire rst_n,
    input wire COPI,
    input wire nCS,
    input wire SCLK,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

  reg [15:0] shift_reg;
  reg [ 4:0] bit_count;

  reg transaction, copi1, copi2, ncs1, ncs2, sclk1, sclk2, sclk3;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      en_reg_out_7_0 <= 8'b0;
      en_reg_out_15_8 <= 8'b0;
      en_reg_pwm_7_0 <= 8'b0;
      en_reg_pwm_15_8 <= 8'b0;
      pwm_duty_cycle <= 8'b0;
      shift_reg <= 16'b0;
      bit_count <= 5'b0;
      transaction <= 0;
      copi1 <= 0;
      copi2 <= 0;
      ncs1 <= 1;
      ncs2 <= 1;
      sclk1 <= 0;
      sclk2 <= 0;
      sclk3 <= 0;
    end else begin
      copi1 <= COPI;
      copi2 <= copi1;
      ncs1  <= nCS;
      ncs2  <= ncs1;
      sclk1 <= SCLK;
      sclk2 <= sclk1;
      sclk3 <= sclk2;
      if (!ncs2) begin
        transaction <= 1;
        if (sclk2 && !sclk3) begin
          shift_reg <= {shift_reg[14:0], copi2};
          if (bit_count < 5'd17) begin
            bit_count <= bit_count + 1;
          end
        end
      end else if (transaction && ncs2) begin
        if (bit_count == 16) begin
          if (shift_reg[15] == 1) begin
            case (shift_reg[14:8])
              7'd00:   en_reg_out_7_0 <= shift_reg[7:0];
              7'd01:   en_reg_out_15_8 <= shift_reg[7:0];
              7'd02:   en_reg_pwm_7_0 <= shift_reg[7:0];
              7'd03:   en_reg_pwm_15_8 <= shift_reg[7:0];
              7'd04:   pwm_duty_cycle <= shift_reg[7:0];
              default: ;
            endcase
          end
        end
        bit_count   <= 0;
        transaction <= 0;
      end
    end
  end
endmodule
