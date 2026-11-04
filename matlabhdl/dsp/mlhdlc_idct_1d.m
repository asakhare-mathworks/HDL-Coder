function y = mlhdlc_idct_1d(x)
%% 1D Inverse Discrete Cosine Transform (Type II)

%   Copyright 2025 The MathWorks, Inc.
%#codegen

narginchk(1,1);

% Input validations
validateattributes(x,{'numeric','embedded.fi'},{'vector'},mfilename);

% Algorithm constants
numX = numel(x);
scaling0 = sqrt(1/numX);
scalingk = sqrt(2/numX);
alpha = pi/numX;

y = coder.nullcopy(x);
% Kernel function
for k = 1:numX
    for n = 1:numX
        if k == 1
            y(n) = scaling0*x(1);
        else
            y(n) = y(n) + scalingk*x(k)*cos(alpha*(k-1)*(n-0.5));
        end
    end
end

end
