#
# Copyright (c) 2020, Kainan Wang
# All rights reserved.
#


SIMULATOR = iverilog
RTLS      = PER_core.v PER_top.v mem_data_label.v mem_data_x1.v mem_data_x2.v mem_w.v
SIMS      = perceptron
VCDS      = perceptron.vcd

all: $(VCDS)
	echo simulation is done.
	
clean:
	rm $(VCDS) $(SIMS)
	
$(VCDS): $(SIMS)
	./$(SIMS)
	
$(SIMS): $(RTLS)
	$(SIMULATOR) -o $(SIMS) $(RTLS)