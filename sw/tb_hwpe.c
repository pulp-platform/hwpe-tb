/*
 * Copyright (C) 2019 ETH Zurich and University of Bologna
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

#include <stdint.h>
#include "archi_hwpe.h"
#include "hal_hwpe.h"
#include "tinyprintf.h"

#include "inc/hwpe_stimuli_a.h"
#include "inc/hwpe_stimuli_b.h"
#include "inc/hwpe_stimuli_c.h"
#include "inc/hwpe_stimuli_d.h"

int main() {

  uint8_t *a = stim_a;
  uint8_t *b = stim_b;
  uint8_t *c = stim_c;
  uint8_t *d = stim_d;

  volatile int errors = 0;
  int gold_sum = 0, check_sum = 0;
  int i,j;
  
  int offload_id_tmp, offload_id;

  /* convolution-accumulation - HW */

  // enable hwpe
  hwpe_cg_enable();

  tfp_printf("H\n");
  // *(int *) 0x80000004 = 'H';
  while((offload_id_tmp = hwpe_acquire_job()) < 0);

  // set up bytecode
  hwpe_bytecode_set(HWPE_LOOPS1_OFFS,           0x00000000);
  hwpe_bytecode_set(HWPE_BYTECODE5_LOOPS0_OFFS, 0x00040000);
  hwpe_bytecode_set(HWPE_BYTECODE4_OFFS,        0x00000000);
  hwpe_bytecode_set(HWPE_BYTECODE3_OFFS,        0x00000000);
  hwpe_bytecode_set(HWPE_BYTECODE2_OFFS,        0x00000000);
  hwpe_bytecode_set(HWPE_BYTECODE1_OFFS,        0x000008cd);
  hwpe_bytecode_set(HWPE_BYTECODE0_OFFS,        0x11a12c05);
  
  // job-dependent registers
  hwpe_a_addr_set((unsigned int) a);
  hwpe_b_addr_set((unsigned int) b);
  hwpe_c_addr_set((unsigned int) c);
  hwpe_d_addr_set((unsigned int) d);
  hwpe_nb_iter_set(4);
  hwpe_len_iter_set(32-1);
  hwpe_vectstride_set(32*4);
  hwpe_shift_simplemul_set(hwpe_shift_simplemul_value(0, 0));

  // start hwpe operation
  hwpe_trigger_job();

  // wait for end of computation
  asm volatile ("wfi" ::: "memory");

  // disable hwpe
  hwpe_cg_disable();
  
  // check
  if(((uint32_t *) d)[0] != 0x7f228fd6) errors++;
  if(((uint32_t *) d)[1] != 0x23a7d5c2) errors++;
  if(((uint32_t *) d)[2] != 0x7f281848) errors++;
  if(((uint32_t *) d)[3] != 0x6127d834) errors++;

  // return errors
  *(int *) 0x80000000 = errors;
  return errors;
}
