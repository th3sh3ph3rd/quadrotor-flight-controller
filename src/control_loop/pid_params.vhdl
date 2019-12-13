
library ieee;
use work.fp_pkg;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pid_params is

	constant A0_ROLL   : FP_T := to_signed(-3624, FP_WIDTH);
	constant A1_ROLL   : FP_T := to_signed(7223, FP_WIDTH);
	constant A2_ROLL   : FP_T := to_signed(-3600, FP_WIDTH);
	constant A0_PITCH  : FP_T := to_signed(3624, FP_WIDTH);
	constant A1_PITCH  : FP_T := to_signed(7224, FP_WIDTH);
	constant A2_PITCH  : FP_T := to_signed(3600, FP_WIDTH);
	constant A0_YAW    : FP_T := to_signed(-8427, FP_WIDTH);
	constant A1_YAW    : FP_T := to_signed(-11016, FP_WIDTH);
	constant A2_YAW    : FP_T := to_signed(-8463, FP_WIDTH);

end package pid_params;

