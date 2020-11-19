input_bin = '../../output/ff-out.bin'; % Output of VHDL algorithm
%input_bin = '../../output/ff-8px-out.bin'; % Output of VHDL algorithm
output_bmp = '../../res/ff-480-out.bmp'; % Output of this function 

fid = fopen(input_bin);
%I = fread(fid, Inf);
[I,cnt] = fscanf(fid,'%d',inf);
fclose(fid);
I = bin2dec(string(I));
A = uint8(I);
M = reshape(A,[270 480]);

%imwrite(M,output_bmp); % Uncomment this to save to file
image(M);