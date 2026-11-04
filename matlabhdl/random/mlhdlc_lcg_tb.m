%% Testbench for Linear Congruential Random Number Generator

%   Copyright 2025 The MathWorks, Inc.

rand_num = zeros(1,1000);

% Hardware LCG implementation
for i = 1:numel(rand_num)
    rand_num(i) = mlhdlc_lcg();
end

% Plot histogram of the pseudorandom samples
figure;
histogram(rand_num);
grid on;
title('Histogram of pseudorandom samples');

disp('==== Test completed ====');
