function mlhdlc_demosaic_tb
%

%   Copyright 2024 The MathWorks, Inc.

I = single(imread('mlhdlc_demosaic.tif'));

[R, G, B] = mlhdlc_demosaic(I);

demosaic_image = uint8(cat(3, R, G, B));

figure(1);
imshow(demosaic_image);
