# 
# Copyright (C) 2018-2019 ETH Zurich and University of Bologna
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

mkfile_path := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
gui ?= 0
P_STALL ?= 0.0
BUILD_DIR ?= build
TEST_SRCS ?= sw/tb_hwpe.c

# Bender stuff
BENDER_VERSION = 0.23.2
BENDER_INSTALL_DIR = hw

# Setup toolchain (from SDK) and options
CC=$(PULP_RISCV_GCC_TOOLCHAIN)/bin/riscv32-unknown-elf-gcc
LD=$(PULP_RISCV_GCC_TOOLCHAIN)/bin/riscv32-unknown-elf-gcc
CC_OPTS=-march=rv32imc -D__riscv__ -O2 -g -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wundef -fdata-sections -ffunction-sections -MMD -MP
LD_OPTS=-march=rv32imc -D__riscv__ -MMD -MP -nostartfiles -nostdlib -Wl,--gc-sections

# Setup build object dirs
CRT=$(BUILD_DIR)/crt0.o
OBJ=$(BUILD_DIR)/$(TEST_SRCS)/verif.o
BIN=$(BUILD_DIR)/$(TEST_SRCS)/verif
STIM_INSTR=$(BUILD_DIR)/$(TEST_SRCS)/stim_instr.txt
STIM_DATA=$(BUILD_DIR)/$(TEST_SRCS)/stim_data.txt
VSIM_INI=$(BUILD_DIR)/$(TEST_SRCS)/modelsim.ini
VSIM_LIBS=$(BUILD_DIR)/$(TEST_SRCS)/work
VERI_LIBS=$(BUILD_DIR)/$(TEST_SRCS)/verilated

# Build implicit rules
$(STIM_INSTR) $(STIM_DATA): $(BIN)
	objcopy --srec-len 1 --output-target=srec $(BIN) $(BIN).s19
	sw/parse_s19.pl $(BIN).s19 > $(BIN).txt
	python sw/s19tomem.py $(BIN).txt $(STIM_INSTR) $(STIM_DATA)
	ln -sfn $(mkfile_path)/hw/modelsim.ini $(VSIM_INI)
	ln -sfn $(mkfile_path)/hw/work $(VSIM_LIBS)
	ln -sfn $(mkfile_path)/hw/veri/verilated $(VERI_LIBS)

$(BIN): $(CRT) $(OBJ) sw/link.ld
	$(LD) $(LD_OPTS) -o $(BIN) $(CRT) $(OBJ) -Tsw/link.ld

$(CRT): $(BUILD_DIR) sw/crt0.S
	$(CC) $(CC_OPTS) -c sw/crt0.S -o $(CRT)

$(OBJ): $(TEST_SRCS) $(BUILD_DIR)/$(TEST_SRCS)
	$(CC) $(CC_OPTS) -c $(TEST_SRCS) -Isw -o $(OBJ)
	
$(BUILD_DIR)/$(TEST_SRCS):
	mkdir -p $(BUILD_DIR)/$(TEST_SRCS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Build explicit rules
run: $(CRT)
ifeq ($(gui), 0)
	cd $(BUILD_DIR)/$(TEST_SRCS); vsim -c vopt_tb -do "run -a" -gSTIM_INSTR=stim_instr.txt -gSTIM_DATA=stim_data.txt -gPROB_STALL=$(P_STALL)
else
	cd $(BUILD_DIR)/$(TEST_SRCS); vsim vopt_tb -gSTIM_INSTR=stim_instr.txt -gSTIM_DATA=stim_data.txt -gPROB_STALL=$(P_STALL)
endif

run-verilator: $(CRT)
	cd $(BUILD_DIR)/$(TEST_SRCS); HWPE_TB_STIM_INSTR=./stim_instr.txt HWPE_TB_STIM_DATA=./stim_data.txt verilated/Vsim_hwpe

all: $(STIM_INSTR) $(STIM_DATA)

update-ips: bender
	git submodule update --init --recursive
	$(MAKE) -C hw scripts veri-scripts

build-hw:
	$(MAKE) -C hw lib build opt

build-hw-verilator:
	$(MAKE) -C hw/veri clean-hard all

clean-hw:
	$(MAKE) -C hw clean-env
	
clean:
	rm -rf $(BUILD_DIR)/$(TEST_SRCS)

# Download bender
bender: hw/bender

hw/bender:
	mkdir -p $(BENDER_INSTALL_DIR)
	cd $(BENDER_INSTALL_DIR);      \
	curl --proto '=https'  \
	--tlsv1.2 https://pulp-platform.github.io/bender/init -sSf | sh -s -- 0.27.1

