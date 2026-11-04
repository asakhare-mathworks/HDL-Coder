function peak = mlhdlc_basic_peak(u)
%#codegen
% Pipelined peak detector using hdl.Delay

persistent delay1 delay2 delay3 currentPeak;

if isempty(delay1)
    delay1 = hdl.Delay('Length', 1);
    delay2 = hdl.Delay('Length', 1);
    delay3 = hdl.Delay('Length', 1);
    currentPeak = 0;
end

% Pipeline the input signal
x1 = delay1(u);
x2 = delay2(x1);
x3 = delay3(x2);

% Compare delayed samples to find peak
if x3 > currentPeak
    currentPeak = x3;
end

peak = currentPeak;
