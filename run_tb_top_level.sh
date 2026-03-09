#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

ghdl -a --std=08 \
  add_four.vhd \
  add_imm.vhd \
  ALU_32_bits.vhd \
  Decode.vhd \
  File_de_registres.vhd \
  FSM_control.vhd \
  gen_imm.vhd \
  Memoire_data.vhd \
  Memoire_instructions.vhd \
  mux_pc.vhd \
  mux_post_alu.vhd \
  mux_pre_alu.vhd \
  Program_counter.vhd \
  Top_level.vhd \
  tb_Top_level.vhd

ghdl -e --std=08 tb_Top_level
ghdl -r --std=08 tb_Top_level --stop-time=65us --wave=tb_Top_level.ghw

gtkwave tb_Top_level.ghw
