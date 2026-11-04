function [y, valid_out] = mlhdlc_decimate2(x, valid_in)
% Decimate input x by a factor of 2

% This example shows how to mock multi-rate in MATLAB for hardware design
% using valid and ready signals.

coeffs = coder.const(fir1(35,0.4)); % Decimation filter coefficients
coeffs1 = coeffs(1:2:end);          % Polyphase filter 1
coeffs2 = coeffs(2:2:end);          % Polyphase filter 2

persistent tap_delay1 tap_delay2 cnt out1 out2;

if isempty(tap_delay1)
    tap_delay1 = zeros(size(coeffs1));
    tap_delay2 = zeros(size(coeffs1));
    cnt = 0;
    out1 = 0;
    out2 = 0;
end

if valid_in
    % Based on phase, choose which coefficients and taps to use for filter
    if cnt == 0
        coeffs = coeffs1;
        tap_delay = tap_delay1;
    else
        coeffs = coeffs2;
        tap_delay = tap_delay2;
    end
    out = mlhdlc_fir(coeffs, tap_delay); % Share one filter for 2 phases
    % Based on phase, update tapped delay and set output
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

function outdatabuf = mlhdlc_fir(coeff, tap_delay)

% Filter
outdatabuf = tap_delay * coeff(end:-1:1)';

end
