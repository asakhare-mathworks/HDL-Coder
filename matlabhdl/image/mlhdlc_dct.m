function output = mlhdlc_dct(input)
%The provided code implements the Discrete Cosine Transform (DCT) operation using a predefined DCT matrix.
%operation performed is
% OUTPUT = dct_matrix*input*dct_matrix'
%These below operations are performed to reduce the computations in matrix
%multiplication.
%from the DCT matrix, which is "dct_matrix", it can be observed that the
%matrix is mirrored from the center. The first row has all the same elements
% and the other rows are mirrors. Also, the positive rows are negatively
%mirrored, and the odd rows are positively mirrored.
%The code computes the forward DCT transformation of a given input matrix 'input' by applying the DCT
% matrix 'dct_matrix' and producing an output matrix output representing the transformed coefficients in the frequency domain.
% This type of transformation is commonly used in applications such as image compression, data compression, and feature extraction in signal processing.

%   Copyright 2023 The MathWorks, Inc.

coder.extrinsic('dctmtx');
dct_matrix = coder.const(dctmtx(8)); %The DCT matrix, holds coefficients required for the transformation.
output = zeros(8);
temp_matrix = zeros(8);% temp_matrix matrices are used to store intermediate results during computation.
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
