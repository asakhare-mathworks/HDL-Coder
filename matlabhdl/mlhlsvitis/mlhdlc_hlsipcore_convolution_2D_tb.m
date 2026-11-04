
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for convolution_2D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2025 The MathWorks, Inc.

% Load your image
image = imread('mlhdlc_hlsipcore_convolution_2D_img.png'); 

% Define convolution kernel (filter)
kernel = ones(5,5);

% Reshape kernel to 1D array
kernel_reshape = reshape(kernel,1,5*5);

% Separate color channels
redChannel = image(:, :, 1);
greenChannel = image(:, :, 2);
blueChannel = image(:, :, 3);

convolvedRGBImage_red   = mlhdlc_hlsipcore_convolution_2D(redChannel, kernel_reshape, size(kernel));
convolvedRGBImage_green = mlhdlc_hlsipcore_convolution_2D(greenChannel, kernel_reshape, size(kernel));
convolvedRGBImage_blue  = mlhdlc_hlsipcore_convolution_2D(blueChannel, kernel_reshape, size(kernel));

% Combine the convolved channels
convolvedRGBImage = cat(3, convolvedRGBImage_red, convolvedRGBImage_green, convolvedRGBImage_blue);