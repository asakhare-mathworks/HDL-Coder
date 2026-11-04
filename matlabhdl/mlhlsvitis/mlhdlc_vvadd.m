
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: vector-vector addition (vvadd)
% 
% Introduction:
% The "Hello World"-level program for high-performance computing
%
% This example demonstrates the usage of pipeline loop pragma
% for the MATLAB to HLS flow

%   Copyright 2023 The MathWorks, Inc.
%#codegen
function res = mlhdlc_vvadd(a, b)
% [Placeholder] Uncomment for interface optimization before release
% coder.hdl.interface('a','AXI4-Stream');
% coder.hdl.interface('b','AXI4-Stream');
% coder.hdl.interface('res','AXI4-Stream');
    n = size(a,2);
    res = coder.nullcopy(zeros(size(a), 'like', a));

    coder.hdl.loopspec('pipeline');
    for i = 1:n
        res(i) = a(i) + b(i);
    end    
end
