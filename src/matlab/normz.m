function img = normz(I)
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
end