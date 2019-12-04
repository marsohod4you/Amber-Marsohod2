
INCLUDE_FLAGS += -y ../../../vlog/tb2
INCLUDE_FLAGS += -y ../../
INCLUDE_FLAGS += -y ../../../vlog/lib
INCLUDE_FLAGS += -y ../../../vlog/system
INCLUDE_FLAGS += -y ../../../vlog/amber23
INCLUDE_FLAGS += -y ../../../vlog/sdram/sdr_ctrl/trunk/rtl/core
INCLUDE_FLAGS += -y ../../../vlog/sdram/sdr_ctrl/trunk/rtl/wb2sdrc
INCLUDE_FLAGS += -y ../../../vlog/sdram/sdr_ctrl/trunk/rtl/top
INCLUDE_FLAGS += -y ../../../vlog/sdram/sdr_ctrl/trunk/rtl/lib

SOURCE_FILES += tb.v
SOURCE_FILES += ../../msystem.v
SOURCE_FILES += ../../my_clocks_resets.v
SOURCE_FILES += ../../../vlog/tb/tb_uart2.v
SOURCE_FILES += ../../../vlog/tb/global_defines.v
SOURCE_FILES += ../../../vlog/lib/generic_sram_line_en.v
SOURCE_FILES += ../../../vlog/lib/generic_sram_byte_en.v
SOURCE_FILES += ../../../vlog/lib/generic_iobuf.v
SOURCE_FILES += ../../../vlog/system/wishbone_arbiter.v
SOURCE_FILES += ../../../vlog/system/uart.v
SOURCE_FILES += ../../../vlog/system/timer_module.v
SOURCE_FILES += ../../../vlog/system/test_module.v
SOURCE_FILES += ../../../vlog/system/system_config_defines.v
SOURCE_FILES += ../../../vlog/system/interrupt_controller.v
SOURCE_FILES += ../../../vlog/system/ethmac_wb.v
SOURCE_FILES += ../../../vlog/system/boot_mem128.v
SOURCE_FILES += ../../../vlog/system/boot_mem32.v
SOURCE_FILES += ../../../vlog/system/afifo.v
SOURCE_FILES += ../../../vlog/amber23/a23_wishbone.v
SOURCE_FILES += ../../../vlog/amber23/a23_register_bank.v
SOURCE_FILES += ../../../vlog/amber23/a23_multiply.v
SOURCE_FILES += ../../../vlog/amber23/a23_cache.v
SOURCE_FILES += ../../../vlog/amber23/a23_fetch.v
SOURCE_FILES += ../../../vlog/amber23/a23_execute.v
SOURCE_FILES += ../../../vlog/amber23/a23_decode.v
SOURCE_FILES += ../../../vlog/amber23/a23_core.v
SOURCE_FILES += ../../../vlog/amber23/a23_coprocessor.v
SOURCE_FILES += ../../../vlog/amber23/a23_config_defines.v
SOURCE_FILES += ../../../vlog/amber23/a23_barrel_shift.v
SOURCE_FILES += ../../../vlog/amber23/a23_alu.v

all:
	verilator -CFLAGS -O3 -DICARUS=1 -Wall --trace --cc $(INCLUDE_FLAGS) $(SOURCE_FILES) --top-module tb -Wno-fatal --exe main.cpp && make -C obj_dir -f Vtb.mk

clean:
	rm -rf obj_dir

