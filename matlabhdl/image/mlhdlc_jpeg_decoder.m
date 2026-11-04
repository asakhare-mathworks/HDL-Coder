function x = mlhdlc_jpeg_decoder(in)
%

%   Copyright 2023 The MathWorks, Inc.

J=inverse_zigzag(in);
q_1 = quantization(J);
x=idct(q_1);
end

% Inverse Discrete Cosine Transform (IDCT) is a mathematical operation used in signal processing, 
% particularly in image and video compression standards like JPEG and MPEG. It reconstructs 
% original pixel values from frequency domain coefficients obtained after applying the DCT.
% IDCT essentially transforms frequency-domain information back into the spatial domain, 
% enabling the recovery of compressed images or videos. It plays a vital role in maintaining 
% image quality during decompression. Various algorithms, like the fast cosine transform, 
% efficiently compute the IDCT, contributing to the efficiency and accuracy of multimedia 
% compression and decompression processes.
% The operation performed was  OUTPUT = (dct_matrix-1)*input*(dct_matrix-1)' 
function [p] = idct(z)
coder.extrinsic('dctmtx')
a = coder.const(inv(dctmtx(8)));
p = (a)*z*(a)';
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function q = quantization(dct_matrix)
% Desired quality (adjust as needed)

% Quantization is the process of approximating continuous values with a limited 
% set of discrete values. De-quantization, conversely, involves restoring continuous-like 
% information from these discrete representations. This is crucial in various fields, like
% digital signal processing and image compression. De-quantization methods aim to minimize the 
% loss of information caused by quantization, often utilizing techniques like interpolation or
% noise modeling to recreate original data. Balancing fidelity and efficiency is essential in 
% de-quantization to ensure accurate reconstruction while controlling computational complexity. 


quality = 50;

% Define base quantization matrix
baseMatrix = [16, 11, 10, 16, 24, 40, 51, 61;
    12, 12, 14, 19, 26, 58, 60, 55;
    14, 13, 16, 24, 40, 57, 69, 56;
    14, 17, 22, 29, 51, 87, 80, 62;
    18, 22, 37, 56, 68, 109, 103, 77;
    24, 35, 55, 64, 81, 104, 113, 92;
    49, 64, 78, 87, 103, 121, 120, 101;
    72, 92, 95, 98, 112, 100, 103, 99];

% Calculate scaling factor based on quality
if quality < 50
    scale = floor(5000 / quality);
else
    scale = 200 - 2 * quality;
end

% Scale the base quantization matrix
quantizationMatrix = round((baseMatrix * scale + 50) / 100);

q = dct_matrix.*quantizationMatrix;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function original_matrix = inverse_zigzag(zigzag_result)

    original_matrix = zeros(8,8);
    index = 1;

    for j = 1:15
        if bitand(j, 1) == 1
            for i = max(1, j - 7):min(8, j)
                original_matrix(i, j - i + 1) = zigzag_result(index);
                index = index + 1;
            end
        else
            for i = min(8, j):-1:max(1, j - 7)
                original_matrix(i, j - i + 1) = zigzag_result(index);
                index = index + 1;
            end
        end
    end
end
