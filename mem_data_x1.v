module mem_data_x1(clk,mem_ena,wr_rd,addr,data_in,data_out);
  input  clk,mem_ena,wr_rd;
  input  [10:0] addr;
  input  [15:0] data_in;
  output [15:0] data_out;

  reg    [15:0] data_out;
  reg    [15:0] mem [(2**10)-1:0];

  //read data
  integer file, j, flag;
  real f;
  initial
  begin
    file = $fopen("inputx1.txt","r");
    flag = $fscanf(file, "%f", f);
    j = 0;
    while(j<=1023 && flag!=0)
    begin
      mem[j] = f*512;
      $display("input:%d,j=%d,flag=%d", mem[j],j,flag);
      flag = $fscanf(file, "%f", f);
      j = j + 1;
    end
    $fclose(file);
  end

  always @(posedge clk)
    if(mem_ena)
      if(wr_rd)
      begin
        mem[addr] <= data_in;
      end
      else
        data_out  <= mem[addr];
endmodule
