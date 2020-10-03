input_bin = '../../res/mont-blanc-480.bin';

% TODO find method for 1D array operations

fid = fopen(input_bin);
%I = fread(fid, Inf);
[I,cnt] = fscanf(fid,'%d',inf);
fclose(fid);
I = bin2dec(string(I));
A = uint8(I);

%ww=10;
%eX = 5;
%eY = 5;
%d = 0;
out = uint8(zeros(270,480));
%window = uint8(zeros(10));
%A = reshape(A,[270 480]);

%for i=1:129600
    
 %   x = mod(i,479)+1;
    
  %  y = int16(i/479)+1;
   % out(y,x) = A(i);
%end
d = 1;
for i=1:480
    for j=1:270
        out(j,i) = A(d);
        d = d +1;
    end
end

imshow(out);