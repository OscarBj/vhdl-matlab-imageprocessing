library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

use work.Common.all;

entity read_image_VHDL is
  
  generic (
    IMAGE_FILE_NAME : string :="../../res/ff-out.bin";
    IMAGE_FILE_NAME_TEST : string :="../../res/ff-8px-out.bin"
  );

  port(
    clock: IN STD_LOGIC;
    rst : IN STD_LOGIC;
    image_block: OUT image_block_type; -- Data structure to read image into
    read_done : OUT STD_LOGIC -- Signal to notify end of task
  );

end read_image_VHDL;

architecture behavioral of read_image_VHDL is

begin

-- Process to read image file into memeory block
process
  variable bin_line : line;
  variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
  file bin_file : text open read_mode is IMAGE_FILE_NAME;
  begin

    for j in 0 to IMAGE_WIDTH-1 loop
      for i in 0 to IMAGE_HEIGHT-1 loop
          readline(bin_file, bin_line);
          read(bin_line, temp_bv);

          --write (OUTPUT, bin_line.all & LF); -- Write to terminal
          
          image_block(j,i) <= to_stdlogicvector(temp_bv); -- Write to memory
        end loop;
    
    end loop;
    report("Read done");
    
    read_done <= '1'; -- Signal to flag the process is done
    
    wait; -- Wait indefinitely

end process;


end behavioral;