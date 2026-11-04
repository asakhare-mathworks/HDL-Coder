function initial_state = mlhdlc_mt_19937_generate_state()
%% Initial state generator for Mersenne-Twister Random Number Generator

%   Copyright 2024 The MathWorks, Inc.

% The state is a vector of 624 32-bit unsigned integers.
stream = RandStream('twister','Seed',1303);
initial_state = fi(stream.randi(1e6,624,1),numerictype(0,32,0));
