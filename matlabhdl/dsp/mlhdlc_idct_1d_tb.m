%% Testbench for 1D Inverse Discrete Cosine Transform (Type II)

%   Copyright 2025 The MathWorks, Inc.

% Initialize random number generator
rng(0);

% Generate 100 random samples as input
x = rand(1,100);

% MATLAB Inverse DCT implementation
y_expected = idct(x);

% Hardware Inverse DCT implementation
y_actual = mlhdlc_idct_1d(x);

% Plot expected and actual outputs
figure;
plot(y_expected);
hold on;
plot(y_actual,'ro');
hold off;
grid on;
legend('MATLAB IDCT','Hardware IDCT');

disp('==== Test completed ====');
