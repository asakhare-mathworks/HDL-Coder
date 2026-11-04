% This testbench demonstrates the use of the design to convert between different custom floating-point types.
%   Copyright 2025 The MathWorks, Inc.

clc;
clear;
num_normals   = 20;   % Number of normal random values
num_denormals = 3;    % Number of denormal random values

cfType = CustomFloatType(16, 10);   % target type:half-precision: 16 bits, 10 mantissa bits
inType = CustomFloatType(32, 23);   % input type:single-precision: 32 bits, 23 mantissa bits

% Generate normal numbers: random values in [-100, 100]
normal_values = -100 + 200 * rand(1, num_normals);

% Generate denormal numbers: random values between 0 and realmin('single')
single_min = realmin('single');
denormal_values = single_min * rand(1, num_denormals);

% Special values: NaN, +Inf, -Inf
special_values = [NaN, Inf, -Inf];

% Combine all test values
float_values = [normal_values, denormal_values, special_values];

fprintf('Input Value\t\tOutput Value\n');
fprintf('-------------------------------\n');

for i = 1:length(float_values)
    % Get the current test value
    float_value = float_values(i);
    
    % Cast the value to single precision
    a = single(float_value);
    
    % Convert the single value to its raw uint32 representation
    a_fi = fi(typecast(a, 'uint32'), 0, 32, 0);
    
    % Extract sign, exponent, and mantissa bits from the single-precision value
    inSign     = bitget(a_fi, 32);
    inExponent = bitsliceget(a_fi, 31, 24);
    inMantissa = bitsliceget(a_fi, 23, 1);
    
    % Call the custom float conversion function
    [Sign, Exponent, Mantissa] = mlhdlc_cf2cf(cfType, inSign, inExponent, inMantissa, inType);
    
    % Concatenate the output bits to form the target floating-point representation
    y_bits = bitconcat(Sign, Exponent, bitsliceget(Mantissa, 10, 1));
    
    % Get the stored integer value from the output bits
    y_raw = storedInteger(y_bits);
    
    % Cast the raw bits back to half-precision floating point
    y = typecast(y_raw, 'half');
    
    % Print the input and output values
    fprintf('%12.7g\t%12.7g\n', float_value, y);
end