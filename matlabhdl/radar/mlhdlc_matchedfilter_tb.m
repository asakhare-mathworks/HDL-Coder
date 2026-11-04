% Define Parameters

%   Copyright 2024 The MathWorks, Inc.

t = 0:0.01:20;          % Time vector
f = t;                  % Frequency varying with time
z = complex(sin(2*pi*f.*t));     % Non-linear signal

% Define Matched Filter Impulse Response
pulseWidth = 1;         % Example pulse width for filter
t_filter = 0:0.01:pulseWidth;  % Time vector for the filter
f_filter = t_filter;   % Frequency varying with time for the filter
coefficients = sin(2*pi*f_filter.*t_filter);  % Matched filter impulse response

% Apply the Manual Matched Filter Function
for i = 1:length(z)
[z_manual_filtered(i), gainManual] = mlhdlc_matchedfilter(z(i), coefficients);
end
% Adjust length for manual filter result to match time vector length
t_filtered = (0:length(z_manual_filtered)-1) * 0.01;

% Plot the Results
figure;
subplot(2,1,1);
plot(t, real(z));
title('Original Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t_filtered, real(z_manual_filtered));
title('Filtered Signal using Matched Filter');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;