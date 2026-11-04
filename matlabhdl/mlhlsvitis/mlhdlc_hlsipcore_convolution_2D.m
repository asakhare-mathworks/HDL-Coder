
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: 2D convolution
% 
% Introduction: This function implements a 2D convolution filter algorithm on 
% an image using a specified kernel (filter coefficients), enabling operations 
% such as blurring ,edge detection etc.. with optimizations for 
% hardware implementation.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input:  rgbImage    - the RGB Image
%                       2D array
%         kernel      - coefficients to specify the type of filtering
%                       1D array
%         kernel_size - size of kernel
%                       1D array (compile time constant)
%
% Output: result      - convolved image
%                       2D array

%   Copyright 2025 The MathWorks, Inc.
function result = mlhdlc_hlsipcore_convolution_2D(rgbImage, kernel, kernel_size)

[image_height, image_width]     = size(rgbImage);

filter_height = kernel_size(1);
filter_width = kernel_size(2);
% Reshape the kernel from 1D to 2D
kernel_reshape = reshape(kernel, filter_height, filter_width);

factor = 1.0/(filter_height*filter_width);
bias = 0;
kernel1 = coder.nullcopy(kernel_reshape);

for i = 1:filter_height
    for j = 1:filter_width
        coder.hdl.literaltext("#pragma HLS pipeline II=1")
        kernel1(i,j) = kernel_reshape(i,j);
    end
end

result = coder.nullcopy(rgbImage);
for y = 1:image_height
    for x = 1:image_width
        coder.hdl.literaltext("#pragma HLS pipeline II=1")
        coder.hdl.literaltext("#pragma HLS array_stencil variable=rgbImage")
        sum = zeros(1,1,'int32');
        for row = 1:filter_height
            for col = 1:filter_width
                xoffset = (x+col-floor(filter_width/2));
                yoffset = (y+row-floor(filter_height/2));                
                if ~(xoffset<1 || xoffset>image_width || yoffset<1 || yoffset>image_height)
                    % clamp pixels to 0 when outside of image
                    pixel = rgbImage(yoffset,xoffset);
                    sum = cast(pixel*kernel1(row,col),'like',sum) + sum;
                end
            end
        end
        outPixel = cast(min(max(factor*sum + bias, 0),255),'like',result);
        result(y,x) = outPixel;
    end
end
end
