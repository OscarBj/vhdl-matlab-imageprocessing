library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.Common.all;

entity img_processor is
end img_processor;

architecture behaviour of img_processor is


    -- Read & Write Components
COMPONENT read_image_VHDL
    PORT(
         clock : IN  std_logic;
         rst : IN std_logic;
         image_block : OUT image_block_type;
         read_done : OUT std_logic
        );
END COMPONENT;

COMPONENT write_image_VHDL
    PORT(
         clock : IN  std_logic;
         rst : IN std_logic;
         write_sw: IN std_logic;
         image_block: IN image_block_type;
         write_done : OUT std_logic
        );
END COMPONENT;

    -- Image containers
    signal image_block_in : image_block_type;
    signal image_block_out : image_block_type;

    -- Inputs
    signal clock : std_logic := '0';
    signal write_sw : std_logic := '0';

    -- Outputs
    signal rst : std_logic := '0';
    signal read_done : std_logic := '0';
    signal write_done : std_logic := '0';

    -- Clock period definitions
    constant clock_period : time := 10 ns;

begin

    -- DUT's

    -- Read Image
    dut1: read_image_VHDL PORT MAP (
        clock => clock,
        rst => rst,
        image_block => image_block_in,
        read_done => read_done
    );

    -- Write Image
    dut2: write_image_VHDL PORT MAP (
        clock => clock,
        rst => rst,
        write_sw => write_sw,
        image_block => image_block_out,
        write_done => write_done
    );

    -- Moving Average Filter Process
    process(read_done)
        -- Define window parameters
        -- Image edge padding
        variable edgeX          : integer := WINDOW_SIZE/2;
        variable edgeY          : integer := WINDOW_SIZE/2;
        -- Window to use as intermediate storage
        variable window         : image_window_type;
        variable avg            : integer := 0;
        variable ws             : integer := 4;
        begin
            
            if(read_done = '1') then -- Start process when image read task is done

                image_block_out <= image_block_in; -- Copy Image. Creates an unfiltered instead of black outer edge.
                
                report("Begin processing");
                report("Filtering..");

                -- Loop trough image with window radius as offset from edge
                for x in edgeX to IMAGE_WIDTH-edgeX loop
                    for y in edgeY to IMAGE_HEIGHT-edgeY loop

                        for fx in 0 to WINDOW_SIZE-1 loop
                            for fy in 0 to WINDOW_SIZE-1 loop
                                window(fx,fy) := image_block_in(x + fx - edgeX,y + fy - edgeY);
                                avg := avg + to_integer(unsigned(window(fx,fy)));
                            end loop;
                        end loop;
                        avg := avg/ws; -- Window average
                        image_block_out(x,y) <= std_logic_vector(to_unsigned(avg, DATA_WIDTH));
                        avg := 0;
                        end loop;
                end loop;
                report("Normalizing");
                -- TODO
                report("Labeling");
                -- TODO
                report("Processing done");

                -- Enable writer process to start
                write_sw <= '1';

            end if;
            
    end process;

    -- Clock process
    process
        begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
   end process;
    
end behaviour;
