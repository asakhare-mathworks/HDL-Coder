function y = mlhdlc_dct_1d(x)
%% 1D Discrete Cosine Transform (Type II)

%   Copyright 2025 The MathWorks, Inc.
%#codegen

narginchk(1,1);

% Input validations
validateattributes(x,{'numeric','embedded.fi'},{'vector'},mfilename);

% Algorithm constants
numX = numel(x);
sizeX = size(x);
scaling0 = sqrt(1/numX);
scalingk = sqrt(2/numX);
alpha = pi/numX;

% Must initialize y to 0s
y = zeros(sizeX,'like',x);

% Kernel function
for n = 1:numX
    for k = 1:numX
        if k == 1
            y(k) = y(k) + scaling0*x(n)*cos(alpha*(n-0.5)*(k-1));
        else
            y(k) = y(k) + scalingk*x(n)*cos(alpha*(n-0.5)*(k-1));
        end
    end
end

end
