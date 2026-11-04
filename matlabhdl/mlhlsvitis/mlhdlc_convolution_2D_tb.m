
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for convolution_2D
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load your image

%   Copyright 2025 The MathWorks, Inc.
image = imread('mlhdlc_convolution_2D_img.png'); 

% Define convolution kernel (filter)
kernel = ones(15, 15);

match_golden_c = true;

if match_golden_c
    % Resize the image to 1000x30
    resizedImage = imresize(image, [30 1000]);
    % Display the resized image
    imwrite(resizedImage, 'resizedImage.jpg'); 
    [NimageHeight, NimageWidth, NnumChannels] = size(resizedImage);
    fprintf('New Width: %d pixels\n', NimageWidth);
    fprintf('New Height: %d pixels\n', NimageHeight);
    fprintf('New Number of Channels: %d\n', NnumChannels);
else
    resizedImage = image;
    [imageHeight, imageWidth, numChannels] = size(image);
   % Display the size information
    fprintf('Image Size:\n');
    fprintf('Width: %d pixels\n', imageWidth);
    fprintf('Height: %d pixels\n', imageHeight);
    fprintf('Number of Channels: %d\n', numChannels);
end

% Separate color channels
redChannel = resizedImage(:, :, 1);
greenChannel = resizedImage(:, :, 2);
blueChannel = resizedImage(:, :, 3);

disp(['calling the mlhdlc_convolution_2D hw ']);

convolvedRGBImage_red   = mlhdlc_convolution_2D(redChannel, kernel);
convolvedRGBImage_green = mlhdlc_convolution_2D(greenChannel, kernel);
convolvedRGBImage_blue  = mlhdlc_convolution_2D(blueChannel, kernel);
% Combine the convolved channels
convolvedRGBImage = cat(3, convolvedRGBImage_red, convolvedRGBImage_green, convolvedRGBImage_blue);

disp(['finished hw processing of mlhdlc_convolution_2D ']);


imwrite(convolvedRGBImage, 'convolved_image.jpg'); 
