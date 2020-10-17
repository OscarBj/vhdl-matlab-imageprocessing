function img = box_filt(I)
% Image size
    [M,N] = size(I);
    
% Window Config
    ww=2; % no touchy
    eX = 1;
    eY = 1;
    
    img = I;
    window = zeros(ww);

    for w=eX:N-eX
        for h=eY:M-eY
            j=1;
            ss = 0;
            for fx=1:ww
                i=1;
                for fy=1:ww
                    
                    window(i,j) = I(h + fy - eY,w + fx - eX);
                    ss = ss + window(i,j);
                    i = i+1;
                end
                j = j+1;
            end

            %window = sort(window,'ascend');

            %img(h,w) = window(5,5); % Pick center

            img(h,w) = ss/(ww*ww); % Pick window average
            
        end
    end
end