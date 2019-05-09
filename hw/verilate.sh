rm -rf obj_dir
verilator -O3 -cc -Wno-fatal --exe sim_main.cpp --trace --trace-structs --trace-params \
        --x-assign 0 --x-initial 0 --autoflush \
        --top-module sim_hwpe -Wno-BLKANDNBLK \
        -Iips/zero-riscy/include -Iips/zero-riscy \
        ips/zero-riscy/include/*.sv \
        ips/tech_cells_generic/src/cluster_clock_gating.sv \
        ips/hwpe-ctrl/rtl/hwpe_ctrl_package.sv\
        ips/hwpe-ctrl/rtl/hwpe_ctrl_interfaces.sv\
        ips/hwpe-ctrl/rtl/hwpe_ctrl_regfile.sv\
        ips/hwpe-ctrl/rtl/hwpe_ctrl_regfile_latch.sv\
        ips/hwpe-ctrl/rtl/hwpe_ctrl_regfile_latch_test_wrap.sv\
        ips/hwpe-ctrl/rtl/hwpe_ctrl_slave.sv\
        ips/hwpe-ctrl/rtl/hwpe_ctrl_seq_mult.sv\
        ips/hwpe-ctrl/rtl/hwpe_ctrl_ucode.sv \
        ips/hwpe-stream/rtl/hwpe_stream_package.sv\
        ips/hwpe-stream/rtl/hwpe_stream_interfaces.sv\
        ips/hwpe-stream/rtl/basic/hwpe_stream_mux_static.sv\
        ips/hwpe-stream/rtl/basic/hwpe_stream_demux_static.sv\
        ips/hwpe-stream/rtl/basic/hwpe_stream_buffer.sv\
        ips/hwpe-stream/rtl/basic/hwpe_stream_merge.sv\
        ips/hwpe-stream/rtl/basic/hwpe_stream_fence.sv\
        ips/hwpe-stream/rtl/basic/hwpe_stream_split.sv\
        ips/hwpe-stream/rtl/fifo/hwpe_stream_fifo_earlystall_sidech.sv\
        ips/hwpe-stream/rtl/fifo/hwpe_stream_fifo_earlystall.sv\
        ips/hwpe-stream/rtl/fifo/hwpe_stream_fifo_scm.sv\
        ips/hwpe-stream/rtl/fifo/hwpe_stream_fifo_scm_test_wrap.sv\
        ips/hwpe-stream/rtl/fifo/hwpe_stream_fifo_sidech.sv\
        ips/hwpe-stream/rtl/fifo/hwpe_stream_fifo.sv\
        ips/hwpe-stream/rtl/fifo/hwpe_stream_fifo_ctrl.sv\
        ips/hwpe-stream/rtl/streamer/hwpe_stream_addressgen.sv\
        ips/hwpe-stream/rtl/streamer/hwpe_stream_strbgen.sv\
        ips/hwpe-stream/rtl/streamer/hwpe_stream_sink.sv\
        ips/hwpe-stream/rtl/streamer/hwpe_stream_sink_realign.sv\
        ips/hwpe-stream/rtl/streamer/hwpe_stream_source.sv\
        ips/hwpe-stream/rtl/streamer/hwpe_stream_source_realign.sv\
        ips/hwpe-stream/rtl/tcdm/hwpe_stream_tcdm_fifo_load.sv\
        ips/hwpe-stream/rtl/tcdm/hwpe_stream_tcdm_fifo_load_sidech.sv\
        ips/hwpe-stream/rtl/tcdm/hwpe_stream_tcdm_fifo_store.sv\
        ips/hwpe-stream/rtl/tcdm/hwpe_stream_tcdm_mux.sv\
        ips/hwpe-stream/rtl/tcdm/hwpe_stream_tcdm_mux_static.sv\
        ips/hwpe-stream/rtl/tcdm/hwpe_stream_tcdm_reorder.sv\
        ips/hwpe-stream/rtl/tcdm/hwpe_stream_tcdm_reorder_static.sv\
        ips/hwpe-mac-engine/rtl/mac_package.sv\
        ips/hwpe-mac-engine/rtl/mac_fsm.sv\
        ips/hwpe-mac-engine/rtl/mac_ctrl.sv\
        ips/hwpe-mac-engine/rtl/mac_streamer.sv\
        ips/hwpe-mac-engine/rtl/mac_engine.sv\
        ips/hwpe-mac-engine/rtl/mac_top.sv\
        ips/hwpe-mac-engine/wrap/mac_top_wrap.sv\
        ips/zero-riscy/zeroriscy_register_file_ff.sv\
        ips/zero-riscy/zeroriscy_alu.sv\
        ips/zero-riscy/zeroriscy_compressed_decoder.sv\
        ips/zero-riscy/zeroriscy_controller.sv\
        ips/zero-riscy/zeroriscy_cs_registers.sv\
        ips/zero-riscy/zeroriscy_debug_unit.sv\
        ips/zero-riscy/zeroriscy_decoder.sv\
        ips/zero-riscy/zeroriscy_int_controller.sv\
        ips/zero-riscy/zeroriscy_ex_block.sv\
        ips/zero-riscy/zeroriscy_id_stage.sv\
        ips/zero-riscy/zeroriscy_if_stage.sv\
        ips/zero-riscy/zeroriscy_load_store_unit.sv\
        ips/zero-riscy/zeroriscy_multdiv_slow.sv\
        ips/zero-riscy/zeroriscy_multdiv_fast.sv\
        ips/zero-riscy/zeroriscy_prefetch_buffer.sv\
        ips/zero-riscy/zeroriscy_fetch_fifo.sv\
        ips/zero-riscy/zeroriscy_core.sv\
        rtl/tb_dummy_memory.sv\
        rtl/sim_hwpe.sv
make OPT_FAST="-O3 -fno-stack-protector" OPT_SLOW="-O2 -fno-stack-protector" -C obj_dir -f Vsim_hwpe.mk Vsim_hwpe


