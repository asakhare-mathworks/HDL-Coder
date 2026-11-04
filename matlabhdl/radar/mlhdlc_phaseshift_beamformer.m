function [y, weights] = mlhdlc_phaseshift_beamformer(rx, direction, sensorLocations, propagationSpeed, operatingFrequency)
% Phase shift beamforming for a sensor array.

%   Copyright 2024 The MathWorks, Inc.

% Inputs:
%   rx                  - Received signal at each sensor, represented as a row vector of complex values.
%   direction           - A 2-element vector specifying the azimuth and elevation angles, indicating the desired direction of beamforming.
%   sensorLocations     - A 2D matrix specifying the spatial positions (in radians) of the sensors in the array.
%   propagationSpeed    - The speed at which the signal propagates, typically the speed of sound in the medium.
%   operatingFrequency  - The frequency at which the system is operating.

% Outputs:
%   y                   - The beamformed output signal.
%   weights             - The calculated beamforming weights.

% Number of sensors is the number of rows in 'sensorLocations'
validateattributes(sensorLocations, {'numeric'}, {'2d', 'nonempty', 'real', 'ncols', 3}, '', 'SENSOR LOCATIONS');
numSensors = size(sensorLocations, 1);

% Validate the input parameters
validateattributes(rx, {'numeric'}, {'row', 'ncols', numSensors}, '', 'RECEIVED SIGNAL');
validateattributes(direction, {'numeric'}, {'vector', 'real', 'numel', 2}, '', 'DIRECTION');
validateattributes(propagationSpeed, {'numeric'}, {'scalar', 'real', 'positive'}, '', 'PROPAGATION SPEED');
validateattributes(operatingFrequency, {'numeric'}, {'scalar', 'real', 'positive'}, '', 'OPERATING FREQUENCY');

% Wavenumber
k = (2*pi)*operatingFrequency/propagationSpeed;

azimuth = direction(1);
elevation = direction(2);
cosElevation = cos(elevation);
kx = cosElevation * cos(azimuth);
ky = cosElevation * sin(azimuth);
kz = sin(elevation);

% Calculate the steering vector (weights)
weights = coder.nullcopy(zeros(numSensors,1,'like',rx));
for idx = 1:numSensors
    % Calculate the phase shift for each sensor element
    phaseShift = -k * ( ...
        sensorLocations(idx, 1) * kx + ...
        sensorLocations(idx, 2) * ky + ...
        sensorLocations(idx, 3) * kz);

    % Use Euler's formula to compute the complex weight
    weights(idx) = cos(phaseShift) + 1i * sin(phaseShift);
end
% Apply weights to the received signal
y = rx * weights;

end
