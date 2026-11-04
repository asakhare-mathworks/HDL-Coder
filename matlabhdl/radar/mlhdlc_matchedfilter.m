function [output,matchedFilterGain] = mlhdlc_matchedfilter(rx, coefficients)
% Custom matched filter implementation with gain calculation using loops.
% Inputs:
%   rx:                    The input signal to be filtered .
%   coefficients:          The precomputed matched filter coefficients (complex-valued column vector).
% Outputs:
%   output:                The result of the matched filtering operation .
%   gainMatchedFilterGain: The gain of the matched filter (scalar).

%   Copyright 2024 The MathWorks, Inc.

validateattributes(rx,{'numeric','embedded.fi'},{'scalar'},'','rx');
validateattributes(coefficients,{'numeric','embedded.fi'},{'row'},'','coefficients');

persistent buffer;
if isempty(buffer)
    buffer = zeros(length(coefficients),1,'like',rx);
end

buffer = [rx; buffer(1:end-1)];
output = coefficients*buffer;

% Calculate the gain of the matched filter
matchedFilterGain = sum(real(coefficients).^2 + imag(coefficients).^2);
