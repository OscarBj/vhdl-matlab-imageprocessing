input_bmp = '../../res/mont-blanc-480.bmp';
output_bin = '../../res/mont-blanc-480.bin';
output_bmp = '../../res/mont-blanc-480-out.bmp';

I = imread(input_bmp);
I = I(:,:,3);
%info = imfinfo(input_bmp);
%info.BitDepth
J = uint8(I);
K = double(J);

M = reshape(K,[480*270 1]);
M = dec2bin(M,8);
imshow(M);
fid = fopen(output_bin,'wb');

%fprintf(fid,'%s \n',M');
fprintf(fid, [repmat('%c',1,size(M,2)) '\r\n'], M.');
fclose(fid);