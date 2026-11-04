
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB test bench for Digital Up Converter (DUC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2025 The MathWorks, Inc.
function mlhdlc_duc_tb()

    nofset = 2;
    L_INPUT = 200;
    L_OUTPUT = 16 * L_INPUT;
    
    din_i = zeros(nofset,L_INPUT);
    din_q = zeros(nofset,L_INPUT);
    dout  = zeros(nofset,L_OUTPUT);    
    incr = 303.33333 * pow2(-11);
    
    jj = 0;
    for i = 1:nofset
        for k = 1:L_INPUT 
            tmp = cos(2 * pi * (0.5 + jj * 33) / 1024);
            din_i(i,k) = tmp;
            tmp = sin(2 * pi * (0.5 + jj * 33) / 1024);
            din_q(i,k) = tmp;
            jj = jj+1;
        end  
        dout(i,:) = mlhdlc_duc(din_i(i,:),din_q(i,:), incr);
    end
end


