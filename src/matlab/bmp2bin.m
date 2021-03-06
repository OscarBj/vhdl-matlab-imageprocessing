input_bmp = '../../res/ff.bmp'; % Conversion input
output_bin = '../../res/ff-out.bin'; % Conversion output

I = imread(input_bmp);
I = I(:,:,3);
%info = imfinfo(input_bmp);
%info.BitDepth
J = uint8(I);
K = double(J);
[M,N] = size(J);
M = reshape(J,[M*N 1]);
M = dec2bin(M,8);
fid = fopen(output_bin,'wb');

%fprintf(fid,'%s \n',M');
fprintf(fid, [repmat('%c',1,size(M,2)) '\r\n'], M.');
fclose(fid);