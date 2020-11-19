function iimg = normz(I)
        % Normalize to binary through mean
        img = I;
        % Max value
        ma = max(max(I));
        % Mean value
        mi = mean2(img);
        % Set mean as min
        img(img<mi) = mi;
        % Normalize into range [0 1]
        img = (img-mi)/(ma-mi);
        
        % test
        iimg = I;
        [M,N] = size(I);
        mean = 0;
        for i=1:M
            for j=1:N
                mean = mean + iimg(i,j);
            end
        end
        
        mean = mean / (M*N);
        
        for i=1:M
            for j=1:N
                if iimg(i,j)>(mean*1.725)
                    iimg(i,j) = 1;
                else
                    iimg(i,j) = 0;
                end
            end
        end
end