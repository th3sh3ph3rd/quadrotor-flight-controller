--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 17.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;

package pid_model is

    function pid(adc : FP_T,
                 P_GAIN : FP_T, 
                 I_GAIN : FP_T,
                 D_GAIN : FP_T) return FP_T; 

end package pid_model;

package body pid_model is
    
    function pid(adc : FP_T,
                 P_GAIN : FP_T, 
                 I_GAIN : FP_T,
                 D_GAIN : FP_T) 
    return FP_T is
        variable err, err_prev,p, i, d : FP_T;
    begin

    end function;

end package body pid_model;

