module sign;
  input  X;
  output f;

  reg[7:0] w,b;
 
  assign f = (w*X+b<0)? -1 : 1;
endmodule
