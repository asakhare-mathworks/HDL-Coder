function [y, valid_out] = mlhdlc_multirate(x, valid_in)
% Decimate input x by a factor of 2 and interpolate by 4

%   Copyright 2025 The MathWorks, Inc.

% This example shows how to mock multi-rate in MATLAB for hardware design
% using valid signals.

[xdecim, valid_decim] = mlhdlc_decimate2(x, valid_in);
[y, valid_out] = mlhdlc_interpolate4(xdecim, valid_decim);

end

function [y, valid_out] = mlhdlc_decimate2(x, valid_in)
% Decimate input x by a factor of 2

coeffs = coder.const(fir1(35,0.4));
coeffs1 = coeffs(1:2:end);
coeffs2 = coeffs(2:2:end);

persistent tap_delay1 tap_delay2 cnt out1 out2;

if isempty(tap_delay1)
    tap_delay1 = zeros(size(coeffs1));
    tap_delay2 = zeros(size(coeffs1));
    cnt = 0;
    out1 = 0;
    out2 = 0;
end

if valid_in
    if cnt == 0
        coeffs = coeffs1;
        tap_delay = tap_delay1;
    else
        coeffs = coeffs2;
        tap_delay = tap_delay2;
    end
    out = fir(coeffs, tap_delay);
    if cnt == 0
        out1 = out;
        tap_delay1 = [tap_delay1(2:length(coeffs1)) x];
        y = out1 + out2;
        valid_out = true;
    else
        out2 = out;
        tap_delay2 = [tap_delay2(2:length(coeffs2)) x];
        y = 0;
        valid_out = false;
    end
    cnt = cnt + 1;
    if cnt >= 2
        cnt = 0;
    end
else
    y = 0;
    valid_out = false;
end

end

function [y, valid_out] = mlhdlc_interpolate4(x, valid_in)
% Interpolate input x by a factor of 4

coeffs = coder.const(designMultirateFIR(4,1));
coeffs1 = coeffs(1:4:end);
coeffs2 = coeffs(2:4:end);
coeffs3 = coeffs(3:4:end);
coeffs4 = coeffs(4:4:end);

persistent tap_delay outbuf cnt

if isempty(tap_delay)
    tap_delay = zeros(size(coeffs1));
    cnt = 1;
    outbuf = zeros(4, 1);
end

if valid_in && cnt == 1
    % 4-polyphase filters to produce 4 outputs
    outbuf(1) = fir(coeffs1, tap_delay);
    outbuf(2) = fir(coeffs2, tap_delay);
    outbuf(3) = fir(coeffs3, tap_delay);
    outbuf(4) = fir(coeffs4, tap_delay);

    % Update delay line
    tap_delay = [tap_delay(2:length(coeffs1)) x];

    y = outbuf(cnt); % Send first output
    cnt = cnt + 1;
    valid_out = true;
elseif cnt ~= 1
    % Send outputs from buffer
    y = outbuf(cnt);
    cnt = cnt + 1;
    valid_out = true;
    if cnt > 4
        cnt = 1;
    end
else
    % Input is not valid
    y = 0;
    valid_out = false;
end

end

function outdatabuf = fir(coeff, tap_delay)

% Filter
out = 0;
for ii=coder.unroll(1:numel(coeff))
    out = out + tap_delay(ii) * coeff(end-ii+1);
end
outdatabuf = out;

end
