function [connected,n_obj] = ccl2(I)
% CCL 2 - simplify ccl algorithm to VHDL
% TODO: Implement indexing, unique & find
%   indexing:   done
%   unique:     
%   find:       

    %%% Read Image %%%

    %I = imread(input_bmp);
    %I = I(:,:,3);
    %I = imgaussfilt(I); % Apply gaussian filter for better results
    %J = uint8(I);
    %JJ = uint8(I);
    %bitdep = 255;       % Uint8 image


    %%% Create 8x8 test matrix %%%

    I = zeros(8);
    I(2:3,2:3) = 1;
    I(5:7,5:7) = 1;
    I(4,6)=1;
    %bitdep = 1;        % Binary image

    J = uint8(I);

%    treshold = bitdep;          % Assign treshold
    [M,N] = size(J);            % Image dimensions
    connected = zeros(M,N);     % Components image
    mark = 15;                   % Label
    difference = 50;           % Label increment
    index = [];                 % Index of cursor
    n_obj = 0;                  % Nr of components found
    neighbors = [];             % Index neighbors (4-connectivity)



    % One pass Connected component labeling
    % https://en.wikipedia.org/wiki/Connected-component_labeling

    for i=1:M % Y
        for j=1:N % X
            if J(i,j) == 1
                n_obj = n_obj +1; % Increment found components
                index(1) = (j-1) * M + i;
                
                x = floor(index/M)+1;
                y = mod(index,M);
                connected(y,x) = mark;
                %connected(index) = mark;
                
                while length(index) ~= 0

                    J(index) = 0;
                    
                    for s=1:length(index)
                        J(index(s)) = 0;
                        % Initialize current index neighbors
                        n1 = index(s)-1;
                        n2 = index(s)+M;
                        n3 = index(s)+1;
                        n4 = index(s)-M;

                        % Validate & push neighbors
                        % UP
                        if index(s) > 1 && mod(index(s)+1,M+1) ~= 0
                            %disp("n1");
                            neighbors = [neighbors;n1];
                        end
                        % RIGHT
                        if index(s)<(N-1)*M % exclude right most array indexes
                            %disp("n2");
                            neighbors = [neighbors;n2];
                        end
                        % DOWN
                        if mod(index(s),M) ~= 0
                            %disp("n3");
                            neighbors = [neighbors;n3];
                        end
                        % LEFT
                        if index(s)>M
                            %disp("n4");
                            neighbors = [neighbors;n4];
                        end

                    end

                    % Find non zero neighbors and set marker
                    %neighbors = unique(neighbors(:));
                    %f = find(J(neighbors));
                    %index = neighbors(f); % Neighbors to use on next loop
                    %connected(index) = mark;
                    
                    % Re implementation of above code
                    
                    % Unique
                    tmp = [];
 
                    for g=1:length(neighbors)
                        found = 0;
                        for gg=1:length(tmp)
                            
                            if neighbors(g) == tmp(gg)
                                found = 1;
                            end
                            
                        end
                        
                        if found == 0
                            tmp = [tmp; neighbors(g)];
                        end 
                        
                    end
                    
                    neighbors = tmp;
                    
                    % Find non zero - return indexes in J
                    tmp = [];
                    for g=1:length(neighbors)
                        
                        x = floor(neighbors(g)/M)+1; % +1 for m
                        y = mod(neighbors(g),M);
                        if x>=1 && y>=1 &&  J(y,x) ~= 0
                            tmp = [tmp; neighbors(g)];
                        end
                        
                    end

                    index = tmp; % Neighbors to use on next loop
                    
                    % Assign marker to object
                    for g=1:length(index)
                        x = floor(index(g)/M)+1; % +1 for m
                        y = mod(index(g),M); % not -1 for m
                        connected(y,x) = mark;
                     
                    end
                    
                end
                mark = mark + difference;
                neighbors = [];
            end
        end
    end
    
    figure
    image(connected)
    %imshow(connected)
    %figure
    %image(I)
    %imshow(I)
    
end