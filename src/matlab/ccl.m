function [connected,n_obj] = ccl(I)

    %%% Read Image %%%

    %I = imread(input_bmp);
    %I = I(:,:,3);
    %I = imgaussfilt(I); % Apply gaussian filter for better results
    %J = uint8(I);
    %JJ = uint8(I);
    %bitdep = 255;       % Uint8 image


    %%% Create 8x8 test matrix %%%

    %I = zeros(8);
    %I(2:3,2:3) = 1;
    %I(5:7,5:7) = 1;
    %I(4,6)=1;
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

    for i=1:M
        for j=1:N
            if J(i,j) == 1
                n_obj = n_obj +1; % Increment found components
                index = [(j-1) * M + i];
                connected(index) = mark;
                while ~isempty(index)

                    J(index) = 0;

                    for s=1:length(index)
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

                    neighbors = unique(neighbors(:));

                    index = neighbors(find(J(neighbors)));
                    connected(index) = mark;
                end
                mark = mark + difference;
                neighbors = [];
            end
        end
    end
    
    %figure
    %image(connected)
    %imshow(connected)
    %figure
    %image(I)
    %imshow(I)
    
end