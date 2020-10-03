input_bin = '../../res/mont-blanc-480.bin';

% TODO find method for 1D array operations

fid = fopen(input_bin);
%I = fread(fid, Inf);
[I,cnt] = fscanf(fid,'%d',inf);
fclose(fid);
I = bin2dec(string(I));
A = uint8(I);

ww=10;
eX = 5;
eY = 5;
d = 0;
out = uint8(zeros(270,480));
window = uint8(zeros(10));
A = reshape(A,[270 480]);
ss = 0;
for w=eX:480-eX
    for h=eY:270-eY
        i=1;
        j=1;
        ss = 0;
        for fx=1:ww
            i=1;
            for fy=1:ww
                %window(i,j) = A((h + fy - eY)*(w + fx - eX));
                window(i,j) = A(h + fy - eY,w + fx - eX);
                ss = ss + uint16(window(i,j));
                i = i+1;
            end
            j = j+1;
        end
        
        window = sort(window,'ascend');
        %tw = mean(window);
        %out(h,w) = window(5);
        out(h,w) = ss/100;
        
    end
end
imshow(out);