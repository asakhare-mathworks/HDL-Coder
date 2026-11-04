function x = mlhdlc_jpeg_encoding(in)
%

%   Copyright 2023 The MathWorks, Inc.

d = dct(in);
q = quantization(d);
x = zigzag(q);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = dct(input)
% The provided code implements the Discrete Cosine Transform (DCT) operation using a predefined DCT matrix.
% operation performed is
% OUTPUT = dct_matrix*input*dct_matrix' 
% These below operations are performed to reduce the computations in matrix
% multiplication.
% from the DCT matrix, which is "dct_matrix", it can be observed that the
% matrix is mirrored from the center. The first row has all the same elements
% and the other rows are mirrors. Also, the positive rows are negatively
% mirrored, and the odd rows are positively mirrored.
% The code computes the forward DCT transformation of a given input matrix 'input' by applying the DCT 
% matrix 'dct_matrix' and producing an output matrix output representing the transformed coefficients in the frequency domain. 
% This type of transformation is commonly used in applications such as image compression, data compression, and feature extraction in signal processing.
coder.extrinsic('dctmtx');
dct_matrix = coder.const(dctmtx(8)); %The DCT matrix, holds coefficients required for the transformation.
output = zeros(8);
temp_matrix = zeros(8);% These matrices are used to store intermediate results during computation. 
for i = 1:8
    temp_matrix(1,i) = dct_matrix(1,1)*sum(input(:,i));
end

for i = 1:8
    temp_1 = (input([1 3;2 4], i) - input([8 6;7 5], i)) ;
    temp_2 = (input([1 3;2 4], i) + input([8 6;7 5], i)) ;
    for j = 2:2:7
    
    temp_matrix(j,i) = sum(temp_1' .* dct_matrix(j,1:4));
    temp_matrix(j+1,i) = sum(temp_2' .* dct_matrix(j+1,1:4));
    end
     temp_matrix(8,i) = sum(temp_1' .* dct_matrix(8,1:4));
end

for i = 1:8
    output(i,1) = dct_matrix(1,1)*sum(temp_matrix(i,:));
    temp_3 = (temp_matrix(i,[1 3;2 4]) - temp_matrix(i,[8 6;7 5])) ;
    temp_4 = (temp_matrix(i,[1 3;2 4]) + temp_matrix(i,[8 6;7 5])) ;
    for j = 2:2:7
    
    output(i,j) = sum(temp_3 .* dct_matrix(j,1:4));
    output(i,j+1) = sum(temp_4 .* dct_matrix(j+1,1:4));
    end
     output(i,8) = sum(temp_3 .* dct_matrix(8,1:4));
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function q = quantization(dct_matrix)

% The baseMatrix is an 8x8 matrix representing the default quantization 
% values for each block in JPEG compression. The quantization process divides the transformed image data by these values, resulting in 
% lower precision and reduced file size.
% The quality variable is used to determine the desired image quality, 
% typically ranging from 1 to 100. The code calculates a scale factor based on the quality value. If the quality is less than 50, 
% the scale is determined by dividing 5000 by the quality. If the quality is 50 or higher, the scale is calculated using a linear equation.
% The scaling factor affects the quantization step and consequently impacts the compression ratio and image quality.

quality = 50;% Desired quality (adjust as needed)

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
q = (dct_matrix./quantizationMatrix);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function zigzag_result = zigzag(matrix)

   zigzag_result = (zeros(1, 64));
    index = 1;

    for j = 1:15
        if bitand(j, 1) == 1
            for i = max(1, j - 7):min(8, j)
                zigzag_result(index) = matrix(i, j - i + 1);
                index = index + 1;
            end
        else
            for i = min(8, j):-1:max(1, j - 7)
                zigzag_result(index) = matrix(i, j - i + 1);
                index = index + 1;
            end
        end
    end
end
