%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% heq.m 
% Histogram Equalization Algorithm
% (Demonstrates RAM access in conditional regions)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x_out, y_out, pixel_out] = ...
    mlhdlc_heq_24a(x_in, y_in, pixel_in, width, height)

%   Copyright 2011-2015 The MathWorks, Inc.

persistent histogram
persistent transferFunc
persistent histInd
persistent cumSum

if isempty(histogram)
    histogram = zeros(1, 2^14);
    transferFunc = zeros(1, 2^14);
    histInd = 0;
    cumSum = 0;
end

% Figure out indexes based on where we are in the frame
if y_in < height && x_in < width % valid pixel data
    histInd = pixel_in + 1;
    cumSum = 0;
    histogram(histInd) = histogram(histInd) + 1;
    pixel_out = transferFunc(histInd);
elseif y_in >= height
    if(y_in == height && x_in == 0)
        % first column of height+1
        histInd = 1;
    else
        % vertical blanking period
        histInd = min(histInd + 1, 2^14);
    end
    cumSum = cumSum + histogram(histInd);
    pixel_out = transferFunc(histInd);
    histogram(histInd) = 0;
    transferFunc(histInd) = cumSum;
else %if y_in < height % horizontal blanking - do nothing
    histInd = 1;
    pixel_out = transferFunc(histInd);
end

x_out = x_in;
y_out = y_in;
