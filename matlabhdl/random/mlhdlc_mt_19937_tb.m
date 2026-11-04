%% Testbench for Mersenne-Twister Random Number Generator

%   Copyright 2023-2024 The MathWorks, Inc.

rand_num = zeros(1,2000);

% Hardware implementation
for i = 1:numel(rand_num)
    rand_num(i) = mlhdlc_mt_19937();
end

% Plot histogram of the pseudorandom samples normalized to [0,1)
figure;
histogram(double(rand_num)./double(intmax('uint32')));
grid on;
title('Histogram of pseudorandom samples');

disp('==== Test completed ====');
