module PER_core(clk,rst,control,mem_x1_ena,mem_x1_addr,mem_x1_data,mem_x1_w,mem_x2_ena,mem_x2_addr,mem_x2_data,mem_x2_w,
               mem_label_ena,mem_label_addr,mem_label_data,mem_label_w,mem_w_ena,mem_w_addr,mem_w_data,mem_w_w,mem_w_data_out);
  input clk;
  input rst;

  input [3: 0] control;
  input [15:0] mem_x1_data,mem_x2_data,mem_label_data;
  input [10:0] mem_x1_addr,mem_x2_addr,mem_label_addr;
  output reg   mem_x1_ena ,mem_x2_ena ,mem_label_ena;
  output reg   mem_x1_w   ,mem_x2_w   ,mem_label_w;
  reg signed [15:0] mem_x1_r,mem_x2_r,mem_label_r;
  //reg   [7 :0] mem_x1_addr,mem_x2_addr,mem_label_addr;
  input [15:0] mem_w_data;
  output[15:0] mem_w_data_out;
  output[6 :0] mem_w_addr;
  output reg   mem_w_ena,mem_w_w;
  reg   [6 :0] mem_w_addr;
  reg   [15:0] w1_data_out,w2_data_out,b_data_out,mem_w_data_out;
  reg signed [15:0] w1,w2,b;

  reg end_of_w;
  reg end_of_up;
  reg end_of_rd;
  reg signed [31:0] mult;
  reg signed [31:0] sum;
  reg signed [15:0] differ;
  reg F;
  //reg [7:0] cont;

  //主状态机
  parameter start     = 5'b00001,
            readdata  = 5'b00010,
            calculate = 5'b00100,
            update    = 5'b01000,
            finish    = 5'b10000,
            //读取数据状态机
            rd_idle   = 5'b00001,
            rd_axis1  = 5'b00010,
            rd_axis2  = 5'b00100,
            rd_bias   = 5'b01000,
            rd_end    = 5'b10000,
            //计算向量积状态机
            cal_idle  = 8'b00000001,
            cal_axis1 = 8'b00000010,
            cal_axis2 = 8'b00000100,
            cal_sum   = 8'b00001000,
            cal_bias  = 8'b00010000,
            cal_F     = 8'b00100000,
            cal_differ= 8'b01000000,
            cal_end   = 8'b10000000,
            //更新向量积状态机
            upd_idle  = 6'b000001,
            upd_bias  = 6'b000010,
            upd_axis2 = 6'b000100,
            upd_axis1 = 6'b001000,
            upd_wr    = 6'b010000,
            upd_end   = 6'b100000;

  reg[5:0] state;
  reg[5:0] read_state;
  reg[8:0] calculate_state;
  reg[6:0] update_state;

  always @(posedge clk)
  begin
    if(rst)
    begin
      state          <= start;
      read_state     <= 6'bxxxxxx;
      calculate_state<= 9'bxxxxxxxxx;
      update_state   <= 7'bxxxxxxx;
      end_of_w       <= 0;
      end_of_up      <= 0;
      end_of_rd      <= 0;
      mem_w_addr     <= 0;
      mem_x1_ena     <= 1;
      mem_x2_ena     <= 1;
      mem_label_ena  <= 1;
      mem_w_ena      <= 1;
      mem_x1_w       <= 0;
      mem_x2_w       <= 0;
      mem_label_w    <= 0;
      mem_w_w        <= 0;
      mem_x1_r       <= mem_x1_data;
      mem_x2_r       <= mem_x2_data;
      mem_label_r    <= mem_label_data/512;
    /*mem_x1_addr    <= 0;
      mem_x2_addr    <= 0;
      mem_label_addr <= 0;
      cont           <= 0;*/
    end
    else
    begin
      case(state)
        start: 
               if(control[0]==1)
               begin
                 state <= readdata;
               end
               else
               begin
                 state <= start;
               end
        readdata:
               if(control[1]==1 && end_of_rd)
               begin
                 state <= calculate;
               end
               else
               begin
                 read_state <= rd_idle;
                 reading;
                 state      <= readdata;
               end
        calculate: 
               if(control[2]==1 && end_of_w)
               begin
                 state <= update;
               end
               else
               begin
                 calculate_state <= cal_idle;
                 calculating;
                 state           <= calculate;
               end
        update:
               if(control[3]==1 && end_of_up)
               begin
                 state <= finish;
               end
               else
               begin
                 update_state <= upd_idle;
                 updating;
                 state        <= update;
               end
        finish:
               begin
                 state <= start;
               end
        default:
               state <= start;
      endcase
    end
  end

task reading;
  begin
    case(read_state)
      rd_idle:
        begin
          end_of_rd  <= 0;
          read_state <= rd_axis1;
          mem_w_addr <= mem_w_addr+1;
        end
      rd_axis1:
        begin
          w1         <= mem_w_data;
          mem_w_addr <= mem_w_addr+1;
          read_state <= rd_axis2;
        end
      rd_axis2:
        begin
          w2         <= mem_w_data;
          //mem_w_addr <= mem_w_addr+1;
          read_state <= rd_bias;
        end
      rd_bias:
        begin
          b          <= mem_w_data;
          read_state <= rd_end;
        end
      rd_end:
        begin
          end_of_rd  <= 1;
          read_state <= rd_idle;
        end
      default:
        begin
          read_state <= rd_idle;
        end
    endcase
  end
endtask
                       
task calculating;
  begin
    case(calculate_state)
      cal_idle:
        begin
          sum             <= 32'b0;
          differ          <= 32'b0;
          mult            <= 32'b0;
          end_of_w        <= 0;
          calculate_state <= cal_axis1;
        end
      cal_axis1:
        begin
          mult            <= w1*mem_x1_r;
        //sum             <= sum+mult;
          calculate_state <= cal_axis2;
        end
      cal_axis2:
        begin
          mult            <= w2*mem_x2_r;
          sum             <= sum+mult;
          calculate_state <= cal_sum;
        end
      cal_sum:
        begin
          sum             <= sum+mult;
          calculate_state <= cal_bias;
        end
      cal_bias:
        begin
          sum             <= sum+b;
          calculate_state <= cal_F;
        end
      cal_F:
        begin
          F               <= (sum>=0)? 1 : 0;
          calculate_state <= cal_differ;
        end
      cal_differ:
        begin
          differ          <= mem_label_r-F;
          calculate_state <= cal_end;
        end
      cal_end:
        begin
          end_of_w        <= 1;
          calculate_state <= cal_idle;
        end
      default:
        begin
          calculate_state <= cal_idle;
        end
    endcase
  end
endtask

task updating;
  begin
    case(update_state)
      upd_idle:
        begin
          update_state   <= upd_bias;
          end_of_up      <= 0;
          mem_w_w        <= 1;
        end
      upd_bias:
        begin
          b_data_out     <= b+differ*512;
        //mem_w_w        <= 1;
        //mem_w_data_out <= b_data_out;
        //mem_w_addr     <= mem_w_addr-1;
          update_state   <= upd_axis2;
        end
      upd_axis2:
        begin
          w2_data_out    <= w2+differ*mem_x2_r;
          mem_w_data_out <= b_data_out;
        //mem_w_addr     <= mem_w_addr-1;
          update_state   <= upd_axis1;
        end
      upd_axis1:
        begin
          w1_data_out    <= w1+differ*mem_x1_r;
          mem_w_addr     <= mem_w_addr-1;
          mem_w_data_out <= w2_data_out;
          update_state   <= upd_wr;
        end
      upd_wr:
        begin
          mem_w_data_out <= w1_data_out;
          mem_w_addr     <= mem_w_addr-1;
          update_state   <= upd_end;
        end
      upd_end:
        begin
          end_of_up      <= 1;
          mem_w_w        <= 0;
          update_state   <= upd_idle;
        end
      default:
        begin
          update_state <= upd_idle;
        end
    endcase
  end
endtask

endmodule
