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
    signal image_block_tmp : image_block_type;
    signal connected : image_block_type;

    -- Inputs
    signal clock : std_logic := '0';
    signal write_sw : std_logic := '0';

    -- Outputs
    signal rst : std_logic := '0';
    signal read_done : std_logic := '0';
    signal write_done : std_logic := '0';

    -- Clock period definitions
    constant clock_period : time := 10 ns;

    -- Signal flags for process
    signal filtering_done : std_logic := '0';
    signal mean_done : std_logic := '0';
    signal normalization_done : std_logic := '0';

    -- Other
    signal mean : integer := 0;

    -- Calculate X coordinate
    function getImgX(index: in integer) return integer is
        variable done: boolean;
        variable temp: integer;
        variable x : integer;
    begin
        
        done := false;
        temp := index;
        x := 0;
        -- Determine x coordinate by counting how many times index fits into image height
        while(not done) loop
            if(temp >= IMAGE_HEIGHT) then
                temp := temp - IMAGE_HEIGHT;
                 x := x + 1;
            else 
                done := true;
            end if; 
           
        end loop;
        
        return x;
    end function;
    
    -- Calculate Y coordinate
    function getImgY(index: integer := 0) return integer is
    begin
        return ((index) mod (IMAGE_HEIGHT));
    end function;

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
        -- image_block => image_block_out,
        image_block => connected,
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
        variable ws             : integer := 4; -- obs hardcoded

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
                                window(fx,fy) := image_block_in(x + fx - edgeX,y + fy - edgeY); -- optimize by removing this intermediate storage
                                avg := avg + to_integer(unsigned(window(fx,fy)));
                            end loop;
                        end loop;
                        avg := avg/ws; -- Window average
                        image_block_out(x,y) <= std_logic_vector(to_unsigned(avg, DATA_WIDTH));
                        avg := 0; -- reset
                        end loop;
                end loop;

                -- Enable filter process to start
                filtering_done <= '1';
            end if;
            
    end process;

    process(filtering_done)
            -- Normalization variables
        variable maximum        : integer := 0;
        variable minimum        : integer := 255;
        variable mean_var       : integer := 0;
        variable index          : std_logic_vector((DATA_WIDTH-1) DOWNTO 0) := "00000000";

    begin
        if(filtering_done = '1') then -- Start process when image read task is done
                report("Calculateing treshold...");
                
                -- Find min & max pixel values
                for i in 0 to IMAGE_WIDTH-1 loop
                    for j in 0 to IMAGE_HEIGHT-1 loop
                        index := image_block_out(i,j);
                        
                        if(to_integer(unsigned(index))>maximum) then
                            maximum := to_integer(unsigned(index));
                        end if;

                        if(to_integer(unsigned(index))<minimum) then
                            minimum := to_integer(unsigned(index));
                        end if;

                        mean_var := mean_var + to_integer(unsigned(index));

                    end loop;
                end loop;

                mean <= mean_var / IMAGE_SIZE; -- obs loss & big int?

                -- Enable normalization process to start
                mean_done <= '1';

        end if;
    end process;

    process(mean_done)
        variable index : std_logic_vector((DATA_WIDTH-1) DOWNTO 0) := "00000000";
        variable up : integer := 1;
        variable down : integer := 0;
        variable tmp : std_logic_vector((DATA_WIDTH-1) DOWNTO 0) := "00000000";
    begin
        if(mean_done = '1') then

            report("Normalizing..");

            -- Binary transformation using mean as treshold
            for i in 0 to IMAGE_WIDTH-1 loop
                for j in 0 to IMAGE_HEIGHT-1 loop
                    index := image_block_out(i,j);
                    if(to_integer(unsigned(index))>mean) then
                        -- image_block_out(i,j) <= "11111111";
                        -- image_block_out(i,j) <= index;
                        tmp := std_logic_vector(to_unsigned(up, DATA_WIDTH));
                    else
                        -- image_block_out(i,j) <= "00000000";
                        -- image_block_out(i,j) <= 
                        tmp := std_logic_vector(to_unsigned(down, DATA_WIDTH));
                    end if;
                    image_block_tmp(i,j) <= tmp;
                end loop;
            end loop;

            -- Enable labeling process to start
            normalization_done <= '1';

        end if;
    end process;
    
    process(normalization_done)
        -- CCL helpers
        variable mark           : integer := 10;
        variable n_obj          : integer := 0;
        variable difference     : integer := 1;
        
        variable neighbors      : image_vector_int;
        variable neighbors_tmp  : image_vector_int;
        variable index          : image_vector_int;
        
        variable neighbors_tmp_len      : integer := 0;
        variable index_len      : integer := 0;        
        variable index_neighbors      : integer := 0;

        variable empty          : std_logic := '0';
        variable found          : std_logic := '0';
        
        variable x : integer;
        variable y : integer;

        variable n1 : integer;
        variable n2 : integer;
        variable n3 : integer;
        variable n4 : integer;

        variable image_block_g : image_block_type;

    begin
        if(normalization_done = '1') then
                
            report("Labeling..");
            
            image_block_g := image_block_tmp;
            n_obj := 0;
            empty := '0';

            for m in 0 to IMAGE_WIDTH -1 loop
                for n in 0 to IMAGE_HEIGHT -1 loop
                    
                    if(image_block_g(m,n) = std_logic_vector(to_unsigned(1, DATA_WIDTH))) then

                        index(0) := m * IMAGE_HEIGHT + n; -- Initialize with index of cursor
                        index_len := 1;
                        
                        n_obj := n_obj + 1; -- Increment number of labeled components
                        
                        x := getImgX(index(0));
                        y := getImgY(index(0));
                        
                        connected(x,y) <= std_logic_vector(to_unsigned(mark, DATA_WIDTH));

                        empty := '0';
                        while (empty /= '1') loop
                            
                            index_neighbors := 0;
                            neighbors_tmp_len := 0;

                            for i in 0 to index_len-1 loop
                                
                                x := getImgX(index(i));
                                y := getImgY(index(i));
                                image_block_g(x,y) := "00000000";
                                
                                n1 := index(i) - 1;
                                n2 := index(i) + IMAGE_HEIGHT;
                                n3 := index(i) + 1;
                                n4 := index(i) - IMAGE_HEIGHT;

                                -- UP
                                if y > 0 then
                                    neighbors(index_neighbors) := n1;
                                    index_neighbors := index_neighbors + 1;
                                end if;
                                
                                -- RIGHT
                                if x < IMAGE_HEIGHT-1 then
                                    neighbors(index_neighbors) := n2;
                                    index_neighbors := index_neighbors + 1;
                                end if;
                                
                                -- DOWN
                                if y < IMAGE_HEIGHT-1 then
                                    neighbors(index_neighbors) := n3;
                                    index_neighbors := index_neighbors + 1;
                                end if;

                                -- LEFT
                                if x > 0 then
                                    neighbors(index_neighbors) := n4;
                                    index_neighbors := index_neighbors + 1;
                                end if;

                            end loop;

                            -- Filter duplicates
                            for g in 0 to index_neighbors-1 loop

                                found := '0';
                                for gg in 0 to neighbors_tmp_len-1 loop
                                    
                                    if neighbors(g) = neighbors_tmp(gg) then
                           
                                        found := '1';
                                    end if;

                                end loop;

                                if found = '0' then
                                
                                    neighbors_tmp(neighbors_tmp_len) := neighbors(g);
                                    neighbors_tmp_len := neighbors_tmp_len + 1;
                                end if;

                            end loop;

                            neighbors := neighbors_tmp;
                            index_neighbors := 0;

                            -- Filter zeros
                            for g in 0 to neighbors_tmp_len-1 loop
                                
                                x := getImgX(neighbors(g));
                                y := getImgY(neighbors(g));

                                if image_block_g(x,y) /= "00000000" then
                                    neighbors_tmp(index_neighbors) := neighbors(g);
                                    index_neighbors := index_neighbors + 1;
                                end if;

                            end loop;

                            index := neighbors_tmp;

                            -- Assign marker
                            for g in 0 to index_neighbors-1 loop
                                x := getImgX(index(g));
                                y := getImgY(index(g));
                                connected(x,y) <= std_logic_vector(to_unsigned(mark, DATA_WIDTH));
                            end loop;
                            
                            index_len := index_neighbors;

                            if index_len = 0 then
                                empty := '1';
                            end if;

                        end loop;
                        
                        mark := mark + difference;
                    end if;
                
                end loop;
            end loop;

            report "Components found: " & integer'image(n_obj);

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
