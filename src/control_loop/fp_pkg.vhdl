--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 04.10.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fp_pkg is

    constant ADC_WIDTH          : natural := 12;
    constant FP_INT_BITS        : natural := 12;
    constant FP_FRAC_BITS       : natural := 4;
    constant FP_SIGN_BITS       : natural := 1;

    -- fixed point type
    constant FP_WIDTH           : natural := FP_SIGN_BITS+FP_INT_BITS+FP_FRAC_BITS;
    subtype FP_T                is signed(FP_WIDTH-1 downto 0);

    -- multiplication result type
    constant FP_MULRES_WIDTH    : natural := 2*FP_WIDTH;
    subtype FP_MULRES_T         is signed(FP_MULRES_WIDTH-1 downto 0);

    function int2fp (i : integer) return FP_T;
    
    function fp2int (f : FP_T) return integer;

    -- this function only works correctly for vectors with width <= FP_FRAC_BITS
    function slv2fp (v : std_logic_vector) return FP_T;

    function fp_mulres2fp(f : FP_MULRES_T) return FP_T;

end package fp_pkg;

package body fp_pkg is
    
    function int2fp (i : integer)
    return FP_T is
    begin
        return to_signed(i*(2**FP_FRAC_BITS), FP_WIDTH);
    end function;
    
    function fp2int (f : FP_T)
    return integer is
    begin
        return to_integer(f(FP_WIDTH-1 downto FP_FRAC_BITS));
    end function;
    
    function slv2fp (v : std_logic_vector)
    return FP_T is
    begin -- sign-extend the vector and add fractional part
        return shift_left(resize(signed(v), FP_WIDTH), FP_FRAC_BITS);
    end function;

    function fp_mulres2fp(f : FP_MULRES_T)
    return FP_T is
    begin
        return f(FP_MULRES_WIDTH-2) & f(FP_INT_BITS+2*FP_FRAC_BITS-1 downto 2*FP_FRAC_BITS) & f(2*FP_FRAC_BITS-1 downto FP_FRAC_BITS);
    end function;

end package body fp_pkg;

