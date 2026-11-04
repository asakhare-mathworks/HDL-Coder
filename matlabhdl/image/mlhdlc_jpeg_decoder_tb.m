%

%   Copyright 2023 The MathWorks, Inc.

[X,cmap] = imread('cameraman.tif');

X = double(X);

last_row = length(X(:,1));
last_column = length(X(1,:));
r2 = mod(length(X(:,1)),8);
r = length(X(:,1)) - r2;
c2 = mod(length(X(1,:)),8);
c = length(X(1,:)) - c2;
if(r2&&c2>0)
    X(((last_row+1):last_row+(8-r2)),(last_column+1:last_column+(8-c2))) = zeros(8-r2,8-c2);
elseif(c2>0)
    X(1:last_column,(last_column+1:last_column+(8-c2))) = zeros(last_column,8-c2);
elseif(r2>0)
    X((last_row+1:last_row+(8-r2)),1:last_column) = zeros(8-r2,last_column);
else
    X = X;
end
[lr, lc] = size(X);
output = zeros(1, 64 * ceil(lr/8) * ceil(lc/8));
y = 1;

% Encoding
for i = 1:8:lr
    for j = 1:8:lc
        submatrix = X(i:min(i+7, lr), j:min(j+7, lc));
        output(y:y+63) = mlhdlc_jpeg_encoding(submatrix);
        y = y + 64;
    end
end

% Decoding and verification
decoded_X = zeros(lr, lc);
y = 1;

for i = 1:8:lr
    for j = 1:8:lc
        decoded_block = mlhdlc_jpeg_decoder(output(y:y+63));
        decoded_X(i:min(i+7, lr), j:min(j+7, lc)) = decoded_block;
        y = y + 64;
    end
end

% Verify the decoded X against the original X
error = norm(X - decoded_X);
if error < 1e-6
    disp('Decoding successful! The error is within a tolerance.');
else
    disp('Decoding failed! The error is significant.');
end

figure(1)
subplot(1,2,1); imshow(X, [0,255]);
title('Original Image');
subplot(1,2,2); imshow(decoded_X, [0,255]);
title('Decoded Image');
