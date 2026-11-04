function [R,G,B] = hdlFrame_demosaic(I)
% Implement demosaic for bggr pattern

%   Copyright 2023 The MathWorks, Inc.

sz = int32(size(I));
[R,G,B] = hdl.npufun(@demosaic_bilinear, [5 5], ...
                'KernelArg',sz(1), 'KernelArg', sz(2), I);
end

function [R,G,B] = demosaic_bilinear(height, width, im)

persistent row col
if isempty(row)
    row = uint16(1);
    col = uint16(1);
end

isRowOdd = bitget(row, 1);
isColOdd = bitget(col, 1);

R = im(3,3);
G = im(3,3);
B = im(3,3);
if isRowOdd && isColOdd
    % blue section. Compute G and R
    G = -im(1,3) + 2*im(2,3) - im(3,1) + 2*im(3,2) + 4*im(3,3) + ...
         2*im(3,4) - im(3,5) + 2*im(4,3) - im(5,3);
    G = floor(G/8);
    R = -3*im(1,3)/2 + 2*im(2,2) + 2*im(2,4) + -3*im(3,1)/2 + 6*im(3,3) - ...
         3*im(3,5)/2 + 2*im(4,2) + 2*im(4,4) - 3*im(5,3)/2;
    R = floor(R/8);
elseif ~isRowOdd && ~isColOdd
    % red section. Compute G and B
    G = -im(1,3) + 2*im(2,3) - im(3,1) + 2*im(3,2) + 4*im(3,3) + ...
         2*im(3,4) - im(3,5) + 2*im(4,3) - im(5,3);
    G = floor(G/8);
    B = -3*im(1,3)/2 + 2*im(2,2) + 2*im(2,4) + -3*im(3,1)/2 + 6*im(3,3) - ...
         3*im(3,5)/2 + 2*im(4,2) + 2*im(4,4) - 3*im(5,3)/2;
    B = floor(B/8);
else
    % green section
    % compute R and B
    if isRowOdd % Left and right are blue, top and bottom are red
        R = -im(1,3) - im(2,2) + 4*im(2,3) - im(2,4) + im(3,1)/2 + 5*im(3,3) + ...
             im(3,5)/2 - im(4,2) + 4*im(4,3) - im(4,4) - im(5,3);
        R = floor(R/8);
        B = im(1,3)/2 - im(2,2) - im(2,4) - im(3,1) + 4*im(3,2) + 5*im(3,3) + ...
             4*im(3,4) - im(3,5) - im(4,2) - im(4,4) + im(5,3)/2;
        B = floor(B/8);
    else  % Left and right are red, top and bottom are green
        R = im(1,3)/2 - im(2,2) - im(2,4) - im(3,1) + 4*im(3,2) + 5*im(3,3) + ...
             4*im(3,4) - im(3,5) - im(4,2) - im(4,4) + im(5,3)/2;
        R = floor(R/8);
        B = -im(1,3) - im(2,2) + 4*im(2,3) - im(2,4) + im(3,1)/2 + 5*im(3,3) + ...
             im(3,5)/2 - im(4,2) + 4*im(4,3) - im(4,4) - im(5,3);
        B = floor(B/8);
    end
end

% Update the row/column trackers
if row == height && col == width
    row = uint16(1);
    col = uint16(1);
elseif col == width
    row = row + 1;
    col = uint16(1);
else
    col = col + 1;
end
end
