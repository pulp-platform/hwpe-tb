/*
 * Copyright (C) 2018-2019 ETH Zurich and University of Bologna
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* 
 * Authors:  Francesco Conti <fconti@iis.ee.ethz.ch>
 */

#ifndef __HAL_HWPE_H__
#define __HAL_HWPE_H__

/*
 * Control and generic configuration register layout
 * ================================================================================
 *  # reg |  offset  |  bits   |   bitmask    ||  content
 * -------+----------+---------+--------------++-----------------------------------
 *     0  |  0x0000  |  31: 0  |  0xffffffff  ||  TRIGGER
 *     1  |  0x0004  |  31: 0  |  0xffffffff  ||  ACQUIRE
 *     2  |  0x0008  |  31: 0  |  0xffffffff  ||  EVT_ENABLE
 *     3  |  0x000c  |  31: 0  |  0xffffffff  ||  STATUS
 *     4  |  0x0010  |  31: 0  |  0xffffffff  ||  RUNNING_JOB
 *     5  |  0x0014  |  31: 0  |  0xffffffff  ||  SOFT_CLEAR
 *   6-7  |          |         |              ||  Reserved
 *     8  |  0x0020  |  31: 0  |  0xffffffff  ||  BYTECODE0 [31:0]
 *     9  |  0x0024  |  31: 0  |  0xffffffff  ||  BYTECODE1 [63:32]
 *    10  |  0x0028  |  31: 0  |  0xffffffff  ||  BYTECODE2 [95:64]
 *    11  |  0x002c  |  31: 0  |  0xffffffff  ||  BYTECODE3 [127:96]
 *    12  |  0x0030  |  31: 0  |  0xffffffff  ||  BYTECODE4 [159:128]
 *    13  |  0x0034  |  31:16  |  0xffff0000  ||  LOOPS0    [15:0]
 *        |          |  15: 0  |  0x0000ffff  ||  BYTECODE5 [175:160]
 *    14  |  0x0038  |  31: 0  |  0xffffffff  ||  LOOPS1    [47:16]
 *    15  |          |  31: 0  |  0xffffffff  ||  Reserved
 * ================================================================================
 *
 * Job-dependent registers layout
 * ================================================================================
 *  # reg |  offset  |  bits   |   bitmask    ||  content
 * -------+----------+---------+--------------++-----------------------------------
 *     0  |  0x0040  |  31: 0  |  0xffffffff  ||  A_ADDR
 *     1  |  0x0044  |  31: 0  |  0xffffffff  ||  B_ADDR
 *     2  |  0x0048  |  31: 0  |  0xffffffff  ||  C_ADDR
 *     3  |  0x004c  |  31: 0  |  0xffffffff  ||  D_ADDR
 *     4  |  0x0050  |  31: 0  |  0xffffffff  ||  NB_ITER
 *     5  |  0x0054  |  31: 0  |  0xffffffff  ||  LEN_ITER
 *     6  |  0x0058  |  31:16  |  0xffff0000  ||  SHIFT
 *        |          |   0: 0  |  0x00000001  ||  SIMPLEMUL
 *     7  |  0x005c  |  31: 0  |  0xffffffff  ||  VECTSTRIDE
 *     8  |  0x0060  |  31: 0  |  0xffffffff  ||  VECTSTRIDE2
 * ================================================================================
 *
 */

/* LOW-LEVEL HAL */
#define HWPE_ADDR_BASE ARCHI_FC_HWPE_ADDR
#define HWPE_ADDR_SPACE 0x00000100

// For all the following functions we use __builtin_pulp_OffsetedWrite and __builtin_pulp_OffsetedRead
// instead of classic load/store because otherwise the compiler is not able to correctly factorize
// the HWPE base in case several accesses are done, ending up with twice more code

#define HWPE_WRITE(value, offset) *(int *)(ARCHI_HWPE_ADDR_BASE + offset) = value
#define HWPE_READ(offset) *(int *)(ARCHI_HWPE_ADDR_BASE + offset)

static inline void hwpe_bytecode_set(unsigned int offs, unsigned int value) {
  HWPE_WRITE(value, HWPE_BYTECODE+offs);
}

static inline void hwpe_a_addr_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_A_ADDR);
}

static inline void hwpe_b_addr_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_B_ADDR);
}

static inline void hwpe_c_addr_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_C_ADDR);
}

static inline void hwpe_d_addr_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_D_ADDR);
}

static inline void hwpe_nb_iter_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_NB_ITER);
}

static inline void hwpe_len_iter_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_LEN_ITER);
}

static inline void hwpe_shift_simplemul_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_SHIFT_SIMPLEMUL);
}

static inline void hwpe_vectstride_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_VECTSTRIDE);
}

static inline void hwpe_vectstride2_set(unsigned int value) {
  HWPE_WRITE(value, HWPE_VECTSTRIDE2);
}

static inline unsigned int hwpe_shift_simplemul_value(
  unsigned short shift,
  unsigned       simplemul
) {
  unsigned int res = 0;
#if defined(__riscv__) && !defined(RV_ISA_RV32)
  res = __builtin_bitinsert(0,   shift,     16, 16);
  res = __builtin_bitinsert(res, simplemul,  8,  0);
#else
  res |= ((shift     & 0xffff) << 16) |
         ((simplemul & 0xff));
#endif
  return res;
}

static inline void hwpe_trigger_job() {
  HWPE_WRITE(0, HWPE_TRIGGER);
}

static inline int hwpe_acquire_job() {
  return HWPE_READ(HWPE_ACQUIRE);
}

static inline unsigned int hwpe_get_status() {
  return HWPE_READ(HWPE_STATUS);
}

static inline void hwpe_soft_clear() {
  volatile int i;
  HWPE_WRITE(0, HWPE_SOFT_CLEAR);
}

static inline void hwpe_cg_enable() {
  return;
}

static inline void hwpe_cg_disable() {
  return;
}

#endif /* __HAL_HWPE_H__ */

