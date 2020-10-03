library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

use work.Common.all;

entity read_image_VHDL is
  
  generic (
    IMAGE_FILE_NAME : string :="../../res/mont-blanc-480.bin"
  );

  port(
    clock: IN STD_LOGIC;
    rst : IN STD_LOGIC;
    image_block: OUT image_block_type;
    read_done : OUT STD_LOGIC;
    q: OUT std_logic_vector ((DATA_WIDTH-1) DOWNTO 0)
  );

end read_image_VHDL;

architecture behavioral of read_image_VHDL is

begin

process
  variable bin_line : line;
  variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
  file bin_file : text open read_mode is IMAGE_FILE_NAME;
  begin

    for j in 0 to IMAGE_WIDTH-1 loop
      for i in 0 to IMAGE_HEIGHT-1 loop
          readline(bin_file, bin_line);
          read(bin_line, temp_bv);
          --write (OUTPUT, bin_line.all & LF);
          
          image_block(j,i) <= to_stdlogicvector(temp_bv);
        end loop;
    
    end loop;
    report("Read done");
    read_done <= '1';
    wait;
end process;


end behavioral;