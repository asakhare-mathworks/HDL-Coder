function rand_num = mlhdlc_lcg()
%% Linear Congruential Random Number Generator

%   Copyright 2025 The MathWorks, Inc.

%#codegen

%%-----------------------------------------------------------------------%%
% Algorithm parameters (from glibc)
modulus = pow2(31);         % must be > 0
multiplier = 1103515245;    % must be > 0  && < modulus
increment = 12345;          % must be >= 0 && < modulus
initialState = 0;           % must be >= 0 && < modulus
%%-----------------------------------------------------------------------%%

% Initialize internal state
persistent state;
if isempty(state)
    state = initialState;
end

% Compute new pseudorandom value
state = mod(multiplier*state+increment,modulus);
rand_num = state;

end
