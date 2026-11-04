% Testbench: Phase shift beamforming for a sensor array.

%   Copyright 2024 The MathWorks, Inc.

% Number of time steps
numTimeSteps = 1000;
% Number of sensors in the array
numSensors = 7;
operatingFrequency = 300e6;
% Speed of light
propagationSpeed = 3e8;

% Half-wavelength spacing
elementSpacing = propagationSpeed / (2 * operatingFrequency);
sensorArrayPos = [(0:numSensors-1)' * elementSpacing, zeros(numSensors, 2)];

% Azimuth and elevation angles in radians
direction = deg2rad([45; 0]);

for i = 1:numTimeSteps
    phase = 2 * pi * i / numTimeSteps;  % Create a varying phase for each sample
    rx = cos(phase) * ones(1, numSensors) + 1i * sin(phase) * ones(1, numSensors);  % Sine wave with complex components

    % Store the input signal for comparison (taking the first sensor's
    % signal)
    inputSignal(i) = rx(1); %#ok<SAGROW>

    % Apply phase shift beamforming
    [y(i), w] = mlhdlc_phaseshift_beamformer(single(rx), single(direction), single(sensorArrayPos), single(propagationSpeed), single(operatingFrequency)); %#ok<SAGROW>
end


% Plot the results for beamformer
figure;

subplot(2,1,1);
plot(1:numTimeSteps, real(inputSignal), 'b');
grid on
xlabel('Sample Index');
ylabel('Amplitude');
title('Input Signal (Real Part)');

subplot(2,1,2);
plot(1:numTimeSteps, real(y), 'r');
grid on
xlabel('Sample Index');
ylabel('Amplitude');
title('Custom Beamformed Output (Real Part)');
