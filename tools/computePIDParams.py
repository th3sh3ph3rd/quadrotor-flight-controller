#!/usr/bin/python

import sys

FP_FRAC_BITS = 4

OF       = "pid_params.vhdl"

Ts       = 0.01 
Kc_roll  = -1.5
Ti_roll  = 1.5
Td_roll  = 1.5
Kc_pitch = 1.5
Ti_pitch = -1.5
Td_pitch = 1.5
Kc_yaw   = 2.3
Ti_yaw   = 2.3
Td_yaw   = -2.3

def computeA0(Kc, Td):
    a0 = Kc * (1 + Td/Ts)
    return str(int(a0 * (2**FP_FRAC_BITS)))

def computeA1(Kc, Ti, Td):
    a1 = -Kc_roll * (1 + 2*Td/Ts - Ts/Ti)
    return str(int(a1 * (2**FP_FRAC_BITS)))

def computeA2(Kc, Td):
    a2 = Kc * Td/Ts
    return str(int(a2 * (2**FP_FRAC_BITS)))

if __name__ == "__main__":
    fname = ""
    if len(sys.argv) == 2:
        fname = sys.argv[1]
    else:
        fname = OF

    f = open(fname, 'w')

    #compute the PID paramters
    a0_roll = computeA0(Kc_roll, Td_roll)
    a1_roll = computeA1(Kc_roll, Ti_roll, Td_roll)
    a2_roll = computeA2(Kc_roll, Td_roll)
    a0_pitch = computeA0(Kc_pitch, Td_pitch)
    a1_pitch = computeA1(Kc_pitch, Ti_pitch, Td_pitch)
    a2_pitch = computeA2(Kc_pitch, Td_pitch)
    a0_yaw = computeA0(Kc_yaw, Td_yaw)
    a1_yaw = computeA1(Kc_yaw, Ti_yaw, Td_yaw)
    a2_yaw = computeA2(Kc_yaw, Td_yaw)

    f.write("\n")
    f.write("library ieee;\n")
    f.write("use work.fp_pkg;\n")
    f.write("use ieee.std_logic_1164.all;\n")
    f.write("use ieee.numeric_std.all;\n")
    f.write("\n")
    f.write("package pid_params is\n")
    f.write("\n")
    f.write("\tconstant A0_ROLL   : FP_T := to_signed(" + a0_roll + ", FP_WIDTH);\n")
    f.write("\tconstant A1_ROLL   : FP_T := to_signed(" + a1_roll + ", FP_WIDTH);\n")
    f.write("\tconstant A2_ROLL   : FP_T := to_signed(" + a2_roll + ", FP_WIDTH);\n")
    f.write("\tconstant A0_PITCH  : FP_T := to_signed(" + a0_pitch + ", FP_WIDTH);\n")
    f.write("\tconstant A1_PITCH  : FP_T := to_signed(" + a1_pitch + ", FP_WIDTH);\n")
    f.write("\tconstant A2_PITCH  : FP_T := to_signed(" + a2_pitch + ", FP_WIDTH);\n")
    f.write("\tconstant A0_YAW    : FP_T := to_signed(" + a0_yaw + ", FP_WIDTH);\n")
    f.write("\tconstant A1_YAW    : FP_T := to_signed(" + a1_yaw + ", FP_WIDTH);\n")
    f.write("\tconstant A2_YAW    : FP_T := to_signed(" + a2_yaw + ", FP_WIDTH);\n")
    f.write("\n")
    f.write("end package pid_params;\n")
    f.write("\n")

    f.close()

