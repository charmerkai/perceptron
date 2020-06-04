module PER_top();
  reg  clk;
  reg  rst;
  reg  [3:0] control;
  wire mem_x1_w,mem_x2_w,mem_label_w,mem_w_w;
  wire mem_x1_ena,mem_x2_ena,mem_label_ena,mem_w_ena;
  wire [15:0] mem_x1_data,mem_x2_data,mem_label_data,mem_w_data,mem_w_data_out;
  reg  [10:0] mem_x1_addr,mem_x2_addr,mem_label_addr;
  wire [6 :0] mem_w_addr;
  reg  [15:0] mem_x1_data_in,mem_x2_data_in,mem_label_data_in;

  PER_core core(clk,rst,control,mem_x1_ena,mem_x1_addr,mem_x1_data,mem_x1_w,mem_x2_ena,mem_x2_addr,mem_x2_data,mem_x2_w,
               mem_label_ena,mem_label_addr,mem_label_data,mem_label_w,mem_w_ena,mem_w_addr,mem_w_data,mem_w_w,mem_w_data_out);

  mem_data_x1 x1(clk,mem_x1_ena,mem_x1_w,mem_x1_addr,mem_x1_data_in,mem_x1_data);

  mem_data_x2 x2(clk,mem_x2_ena,mem_x2_w,mem_x2_addr,mem_x2_data_in,mem_x2_data);

  mem_data_label label(clk,mem_label_ena,mem_label_w,mem_label_addr,mem_label_data_in,mem_label_data);

  mem_w weight(clk,mem_w_ena,mem_w_w,mem_w_addr,mem_w_data_out,mem_w_data);

  always
    begin
      clk=1; #5; clk=0; #5;
    end

  initial 
    begin
      rst            <= 0;
      control        <= 0;
      #10;
      rst            <= 1;
      mem_x1_addr    <= 0;
      mem_x2_addr    <= 0;
      mem_label_addr <= 0;
      #50;
      rst            <= 0;
      control        <= 4'b1111;
      #300;
      repeat(500) begin
      rst            <= 0;
      control        <= 0;
      #10;
      rst            <= 1;
      mem_x1_addr    <= mem_x1_addr+1;
      mem_x2_addr    <= mem_x2_addr+1;
      mem_label_addr <= mem_label_addr+1;
      #50;
      rst            <= 0;
      control        <= 4'b1111;
      #300;
      end
      $finish;
    end

  initial 
    begin
      $dumpfile("PER.vcd");
      $dumpvars(0,PER_top);
    end

endmodule
