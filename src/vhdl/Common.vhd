library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

package Common is
    
    constant DATA_WIDTH     : integer := 8;     -- Image pixel bit width
    constant IMAGE_SIZE  : integer := 129600;   -- Pixel Count
    constant IMAGE_WIDTH : integer := 480;      -- Width in pixels
    constant IMAGE_HEIGHT : integer := 270;     -- Height in pixels
    constant WINDOW_SIZE : integer := 2;       -- Image filter window size in pixels
    
    -- 8x8 test image
    -- constant IMAGE_SIZE  : integer := 64;   -- Pixel Count
    -- constant IMAGE_WIDTH : integer := 8;      -- Width in pixels
    -- constant IMAGE_HEIGHT : integer := 8;     -- Height in pixels

    -- Define data type for pixel
    SUBTYPE pixel_type is std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
    
    -- Storage block
    TYPE image_block_type is array(0 to IMAGE_WIDTH-1, 0 to IMAGE_HEIGHT-1) of std_logic_vector((DATA_WIDTH-1) DOWNTO 0);
    TYPE image_pointer is access image_block_type;

    TYPE image_vector is array(0 to IMAGE_SIZE-1) of std_logic_vector((DATA_WIDTH-1) DOWNTO 0);

    TYPE image_vector_int is array(0 to IMAGE_SIZE-1) of integer;

    -- Filter window
    TYPE image_window_type is array(0 to WINDOW_SIZE, 0 to WINDOW_SIZE) of std_logic_vector((DATA_WIDTH-1) DOWNTO 0);

end Common;

-- package body Common is
--    -- subprogram bodies here
-- end Common;