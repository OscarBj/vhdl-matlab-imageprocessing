% Contains algorithm from extract_stars in photometry.cpp

input_bmp = '../../res/ff.bmp';

I = imread(input_bmp);
%J = I;
J = I(:,:,3); % Extract 1 channel
X = J;

% Bilateral filtering
%J = imbilatfilt(J,3);
J = box_filt(J);

% Natural logarithm
J = log(double(J+1)); % +1 to avoid log(0) -> Inf

% Normalization
J = normz(J);

% Threshold for binary transformation
J(J<0.8) = 0;
J(J>0) = 1;

% Box filter - Two options
J = box_filt(J);
%J = imboxfilt(J,3);

% Set to range & invert for CCL (1 -> object)
%J(J<1) = 1;
%J(J>1) = 0;

% CCL
[c,o] = ccl(J);
%imshowpair(X,c,'montage');
image(c);