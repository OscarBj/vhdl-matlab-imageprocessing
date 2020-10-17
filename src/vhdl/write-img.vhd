library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

use work.Common.all;

entity write_image_VHDL is

  generic (
    IMAGE_FILE_NAME : string :="../../output/ff-out.bin"
  );

  port(
    clock: IN STD_LOGIC;
    rst: IN STD_LOGIC;
    write_sw: IN STD_LOGIC; -- Signal to trigger task
    image_block: IN image_block_type; -- Data structure to read image from
    write_done : OUT STD_LOGIC -- Signal to notify end of task
    );
    
end write_image_VHDL;

architecture behavioral of write_image_VHDL is

begin

-- Process to write image into file
process (write_sw)
  variable bin_line : line;
  variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
  file bin_file : text open write_mode is IMAGE_FILE_NAME;
  begin
    if(write_sw = '1') then

        report("Writing image block");
        for j in 0 to IMAGE_WIDTH-1 loop
            for i in 0 to IMAGE_HEIGHT-1 loop
                temp_bv := to_bitvector(image_block(j,i));
                write(bin_line, temp_bv);
                writeline(bin_file, bin_line); -- Write to file
                --write (OUTPUT, bin_line.all & LF); -- Write to terminal
            end loop;
        end loop;

        write_done <= '1'; -- Signal to flag the process is done
        
    end if;
end process;

end behavioral;