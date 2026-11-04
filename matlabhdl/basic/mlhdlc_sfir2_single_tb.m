% Motivation: Hello World Example for HDL Coder
% 
% This design (mlhdlc_sfir2) and the testbench are written to show case how
% to generate code directly from the single precision floating point MATLAB
% code

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for the FIR filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2011-2019 The MathWorks, Inc.
clear mlhdlc_sfir2_single;
T = 2;
dt = 0.001;
N = T/dt+1;
sample_time = 0:dt:T;

df = 1/dt;
sample_freq = linspace(-1/2,1/2,N).*df;

% input signal with noise
x_in = single(cos(2.*pi.*(sample_time).*(1+(sample_time).*75)).');

% filter coefficients
h1 = single(-0.1339); h2 = single(-0.0838); h3 = single(0.2026); h4 = single(0.4064);

len = length(x_in);
y_out = zeros(1,len, 'single');
x_out = zeros(1,len, 'single');

for ii=1:len
    data = x_in(ii);
    % call to the single precision design 'mlhdlc_sfir2' that is targeted for hardware
    [y_out(ii), x_out(ii)] = mlhdlc_sfir2_single(data, h1, h2, h3, h4);
end

figure('Name', [mfilename, '_plot']);
subplot(3,1,1);
plot(1:len,x_in,'-b');
xlabel('Time (ms)')

ylabel('Amplitude')
title('Input Signal (with noise)')
subplot(3,1,2); plot(1:len,y_out,'-b');
xlabel('Time (ms)')
ylabel('Amplitude')
title('Output Signal (filtered)')

freq_fft = @(x) abs(fftshift(fft(x)));

subplot(3,1,3); semilogy(sample_freq,freq_fft(x_in),'-b');
hold on
semilogy(sample_freq,freq_fft(y_out),'-r')
hold off
xlabel('Frequency (Hz)')
ylabel('Amplitude (dB)')
title('Input and Output Signals (Frequency domain)')
legend({'FilterIn', 'FilterOut'}, 'Location','South')
axis([-500 500 1 100])

