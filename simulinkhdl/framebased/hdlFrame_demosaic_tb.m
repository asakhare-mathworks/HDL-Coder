%   Copyright 2023 The MathWorks, Inc.

Iinput = imread("hdlFrame_demosaic.tif"); % input image

clear hdlFrame_demosaic; % Clear persistent variables
[R,G,B] = hdlFrame_demosaic(single(Iinput));

% demosaic_ipt_out = demosaic(Ismall,"bggr");

imshow(uint8(cat(3,R,G,B)));
