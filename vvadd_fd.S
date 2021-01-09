#*****************************************************************************
# vvadd_fd.S
#-----------------------------------------------------------------------------
#
# Test vvadd fd.
#

#include "riscv_test.h" # TODO not found yet
#include "test_macros.h" # found in esp-tests/isa/macros/vector

RVTEST_RV64UV
RVTEST_CODE_BEGIN

  vsetcfg 32,1 # process determines max vector length it can provide with on-chip resources
  # format: vsetcfg [4 imms] ==> 32 bit register, 1 needed here
  li a3,4 
  vsetvl a3,a3 # instr sets vector length to min(HW limit, a3)

  la a3,src1 # def at bottom, series of doubles 0.1-0.4 for testing; loads value from label into shared reg
  vmca va2,a3 # vector memory c? a? loading (??) mem addr into vector address reg 2
  la a4,src2 # ditto with src2; 0.4-0.1
  vmca va3,a4 # into vec addr reg 3
  la a5,dest # ditto with dest label
  vmca va1,a5 # into vec addr reg 1
1:auipc a0,%pcrel_hi(vtcode) # TODO CONFIRM; loads upper at whatever pc-rel hi (what is this) position from vtcode into a0; vt_code is def below as well
  vf %pcrel_lo(1b)(a0) # TODO where are pcrel_lo/hi defined?
  fence
  la a6,result
  ld a1,0(a5)
  ld a2,0(a6)
  li TESTNUM,2
  bne a1,a2,fail
  ld a1,8(a5)
  li TESTNUM,3
  bne a1,a2,fail
  ld a1,16(a5)
  li TESTNUM,4
  bne a1,a2,fail
  ld a1,24(a5)
  li TESTNUM,5
  bne a1,a2,fail
  j pass

.align 3
vtcode:
  vpset vp0
  vld vv2,va2
  vld vv3,va3
  vfadd.d.vv vv2,vv2,vv3
  vsd vv2,va1
  vstop

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

src1:
  .double 0.1
  .double 0.2
  .double 0.3
  .double 0.4
src2:
  .double 0.4
  .double 0.3
  .double 0.2
  .double 0.1
dest:
  .dword 0xdeadbeefcafebabe
  .dword 0xdeadbeefcafebabe
  .dword 0xdeadbeefcafebabe
  .dword 0xdeadbeefcafebabe
result:
  .double 0.5
  .double 0.5
  .double 0.5
  .double 0.5

RVTEST_DATA_END
