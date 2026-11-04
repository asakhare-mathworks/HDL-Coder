function rand_num = mlhdlc_mt_19937()
%% Mersenne-Twister Random Number Generator

%   Copyright 2025 The MathWorks, Inc.

%#codegen

% Generate uniformly distributed 32-bit pseudorandom unsigned integers
% using the Mersenne-Twister algorithm. This design is implemented in
% fixed-point and does not require fixed-point conversion.

% The state is a vector of 624 32-bit unsigned integers.
persistent mlhdlc_mt_19937_state;
if isempty(mlhdlc_mt_19937_state)
    mlhdlc_mt_19937_state = coder.const(feval('mlhdlc_mt_19937_generate_state'));
end

% State update
highMask = cast(hex2dec('80000000'),'like',mlhdlc_mt_19937_state);
p = bitand((mlhdlc_mt_19937_state(1)),highMask);
lowMask = cast(hex2dec('7FFFFFFF'),'like',mlhdlc_mt_19937_state);
q = bitand(mlhdlc_mt_19937_state(2),lowMask);
r = bitor(p,q);

y1 = bitxor(bitshift(r,-1),mlhdlc_mt_19937_state(398));

a = cast(hex2dec('9908B0DF'),'like',mlhdlc_mt_19937_state);
if bitget(r,1) == 0
    % For even numbers
    y = y1;
else
    % For odd numbers
    y = bitxor(y1,a);
end
mlhdlc_mt_19937_state = vertcat(mlhdlc_mt_19937_state(2:end),y);

% Output tempering
y = bitxor(y,bitshift(y,-11));
y = bitxor(y,bitand(bitshift(y,7),cast(hex2dec('9D2C5680'),'like',mlhdlc_mt_19937_state)));
y = bitxor(y,bitand(bitshift(y,15),cast(hex2dec('EFC60000'),'like',mlhdlc_mt_19937_state)));
y = (bitxor(y,bitshift(y,-18)));

rand_num = y;

end
