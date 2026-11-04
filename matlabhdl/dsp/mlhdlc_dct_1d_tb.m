%% Testbench for 1D Discrete Cosine Transform (Type II)

%   Copyright 2025 The MathWorks, Inc.

% Initialize random number generator
rng(0);

% Generate 100 random samples as input
x = rand(1,100);

% MATLAB DCT implementation
y_expected = dct(x);

% Hardware DCT implementation
y_actual = mlhdlc_dct_1d(x);

% Plot expected and actual outputs
figure;
plot(y_expected);
hold on;
plot(y_actual,'ro');
hold off;
grid on;
legend('MATLAB DCT','Hardware DCT');

disp('==== Test completed ====');
