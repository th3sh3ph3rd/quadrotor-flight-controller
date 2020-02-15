#!/usr/bin/python

import sys

FP_FRAC_BITS = 4

OF       = "../src/control_loop/pid_params.vhdl"

#sampling time
Ts       = 0.01 

#try 1, not very responsive (D too high, P too low?)
Kc_roll  = 2 #30
Ti_roll  = 10
Td_roll  = 0.4
Kc_pitch = 2 #30
Ti_pitch = 10
Td_pitch = 0.4
Kc_yaw   = 30
Ti_yaw   = 10
Td_yaw   = 0 #no D necessary for yaw because of rotor drag

#fixed point accuracy might not be good enough!
#try 2
Kc_roll  = 25 #30
Ti_roll  = 0.3
Td_roll  = 0.01
Kc_pitch = 25 #30
Ti_pitch = 0.3
Td_pitch = 0.01
Kc_yaw   = 30
Ti_yaw   = 10
Td_yaw   = 0 #no D necessary for yaw because of rotor drag

#Kc_roll  = 1
#Td_roll  = 0
#Kc_pitch = 1
#Td_pitch = 0
#Kc_yaw   = 0

######PID tuning
###D
#increase D until drone becomes restless and lower again until it runs smooth, set value -25%
###P
#increase P until it overcompensates and set value -50%

#paper
def computeA0_p(Kc, Td):
    a0 = Kc * (1 + Td/Ts)
    return str(int(a0 * (2**FP_FRAC_BITS)))

def computeA1_p(Kc, Ti, Td):
    #a1 = -Kc * (1 + 2*Td/Ts - Ts/Ti)
    a1 = -Kc * (1 + 2*Td/Ts) #w/o integral
    return str(int(a1 * (2**FP_FRAC_BITS)))

def computeA2_p(Kc, Td):
    a2 = Kc * Td/Ts
    return str(int(a2 * (2**FP_FRAC_BITS)))

Kp_pitch = 20 #20-25
#Kp_pitch = 0
Ki_pitch = 0.2
#Ki_pitch = 0
Kd_pitch = 1 #0.25
#Kd_pitch = 0
Kp_roll = 20 #20-25
#Kp_roll = 0
Ki_roll = 0.2
#Ki_roll = 0
Kd_roll = 1 #0.25
#Kd_roll = 0
Kp_yaw = 20
#Kp_yaw = 0
Ki_yaw = 0.1
#Ki_yaw = 0
Kd_yaw = 0 #no D needed

#type A from website
def computeA0_w(Kp, Ki, Kd):
    a0 = Kp + Ki*Ts + Kd/Ts
    return str(int(a0 * (2**FP_FRAC_BITS)))

def computeA1_w(Kp, Kd):
    a1 = -(Kp + 2*Kd/Ts) #w/o integral
    return str(int(a1 * (2**FP_FRAC_BITS)))

def computeA2_w(Kd):
    a2 = Kd/Ts
    return str(int(a2 * (2**FP_FRAC_BITS)))

if __name__ == "__main__":
    fname = ""
    if len(sys.argv) == 2:
        fname = sys.argv[1]
    else:
        fname = OF

    f = open(fname, 'w')

    #compute the PID paramters
    a0_roll = computeA0_p(Kc_roll, Td_roll)
    a1_roll = computeA1_p(Kc_roll, Ti_roll, Td_roll)
    a2_roll = computeA2_p(Kc_roll, Td_roll)
    a0_pitch = computeA0_p(Kc_pitch, Td_pitch)
    a1_pitch = computeA1_p(Kc_pitch, Ti_pitch, Td_pitch)
    a2_pitch = computeA2_p(Kc_pitch, Td_pitch)
    a0_yaw = computeA0_p(Kc_yaw, Td_yaw)
    a1_yaw = computeA1_p(Kc_yaw, Ti_yaw, Td_yaw)
    a2_yaw = computeA2_p(Kc_yaw, Td_yaw)
    
    a0_roll = computeA0_w(Kp_roll, Ki_roll, Kd_roll)
    a1_roll = computeA1_w(Kp_roll, Kd_roll)
    a2_roll = computeA2_w(Kd_roll)
    a0_pitch = computeA0_w(Kp_pitch, Ki_pitch, Kd_pitch)
    a1_pitch = computeA1_w(Kp_pitch, Kd_pitch)
    a2_pitch = computeA2_w(Kd_pitch)
    a0_yaw = computeA0_w(Kp_yaw, Ki_yaw, Kd_yaw)
    a1_yaw = computeA1_w(Kp_yaw, Kd_yaw)
    a2_yaw = computeA2_w(Kd_yaw)

    f.write("\n")
    f.write("library ieee;\n")
    f.write("use work.fp_pkg.all;\n")
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

