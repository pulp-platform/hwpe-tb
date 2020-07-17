# Introduction

PULP systems support integration of hardware accelerators (Hardware
Processing Engines) that share memory with the RISC-V core and are programmed
through memory-mapped load/store accesses.
The `hw/ips/hwpe-stream` and `hw/ips/hwpe-ctrl` folders contain the IPs
necessary to plug streaming accelerators into a PULP system on the data and
control plane.
For further information on how to design and integrate such accelerators,
see `hw/ips/hwpe-stream/doc`, https://arxiv.org/abs/1612.05974,
https://arxiv.org/abs/1807.03010 .

This testbench provides an example "almost standalone" environment to test
an example HWPE, performing multiply-accumulate on a
vector of fixed-point values (in `hw/ips/hwpe-mac-engine` after
updating the IPs: see below in the Getting Started section).
The testbench makes use of dummy memories and of a simple zero-riscy core
to execute tests written directly in C, essentially in the same way
one would write a test running on a real PULP system.
The C testbench is located in `sw/tb_hwpe.c`, along with the boot script
(`crt0.S` and `vectors.S`), the linker script (`link.ld`) and the headers
(`archi_hwpe.h` and `hal_hwpe.h`).
The top RTL testbench is located in `hw/rtl/tb_hwpe.sv`.

# Getting Started

## Prerequisites
This testbench has a loose dependency on the PULP sdk. To install it,
follow the same instructions as reported in PULPissimo.
Start by installing the system dependencies indicated here:
https://github.com/pulp-platform/pulp-sdk#linux-dependencies

This testbench requires also the installation of the following packages:
```
sudo pip3 install numpy
sudo pip install numpy
```

Before the PULP sdk build, you need to provide via environmental variable the RISC-V installation path:
```
$ export PULP_RISCV_GCC_TOOLCHAIN=<path to the folder containing the bin folder of the toolchain>
```

Otherwise, you can build it following the commands indicated here:
https://github.com/pulp-platform/pulp-riscv-gnu-toolchain

### Install from pulp-sdk sources
If you have access to it, you can install a recent version of the SDK
from `pulp-sdk`:
https://github.com/pulp-platform/pulp-sdk

Then you can execute the following commands:
```
export PULP_GITHUB_SSH=1
git clone https://github.com/pulp-platform/pulp-sdk.git
cd pulp-sdk
git submodule update --init --recursive
source configs/pulpissimo.sh
source configs/platform-rtl.sh
make all env
```
From now on, to set up the built environment you only need to source the generated script as follow:
```
source pulp-sdk/sourceme.sh
```

The testbench has been tested with version 2019.02.06 configured for
PULPissimo RTL simulation, but it should work in most other configurations
as well.

## Building the RTL simulation platform
To build the RTL simulation platform, start by getting the latest version of the
IPs composing the PULP system:
```
make update-ips
```
This will download all the required IPs, solve dependencies and generate the
simulation scripts. 

After having access to the SDK, you can build the simulation platform by doing
the following:
```
make build-hw
```

## Running the testbench
Once built, the SW test can be built by using the command:
```
make clean all
```
Then, it is run in command-line mode by using:
```
make run
```
and in GUI mode by using
```
make run gui=1
```

All Makefile commands can be combined together as usual.
Two flags can be set to alter the way that the test runs:
 - `P_STALL` (default 0.0, max 1.0) is the probability of a fake contention
   in the dummy memory.
 - `TEST_SRCS` (default is `sw/tb_hwpe.c`) is the C file containing the
   `main` function of the SW testbench.
For example,
```
make build-hw clean all run P_STALL=0.1 gui=1
```
builds the HW platform, rebuilds the SW and runs the test in GUI mode,
with 10% probability of a contention (i.e. a stall) being generated
on each memory interface.

# HWPE interface specifications
[![Documentation Status](https://readthedocs.org/projects/hwpe-doc/badge/?version=latest)](https://hwpe-doc.readthedocs.io/en/latest/?badge=latest)

See documentation on https://hwpe-doc.readthedocs.io.
