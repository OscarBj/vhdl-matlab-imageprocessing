input_bin = '../../res/mont-blanc-480.bin';
output_bmp = '../../res/mont-blanc-480-out.bmp';

fid = fopen(input_bin);
%I = fread(fid, Inf);
[I,cnt] = fscanf(fid,'%d',inf);
fclose(fid);
I = bin2dec(string(I));
A = uint8(I);
M = reshape(A,[270 480]);

%imwrite(M,output_bmp);
imshow(M);