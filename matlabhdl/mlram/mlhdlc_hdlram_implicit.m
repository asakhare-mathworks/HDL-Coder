%#codegen
function [ringBufferOut] = mlhdlc_hdlram_implicit(data_in)
% Example showing usage of ram inference when using large persistent matrix
% or vector greater than RAM threshold

%   Copyright 2012-2015 The MathWorks, Inc.

persistent hRam;
if isempty(hRam)
    hRam = zeros(256,1,'like',data_in);
end

% read address counter
persistent rdAddrCtr;
if isempty(rdAddrCtr)
    rdAddrCtr = 0;
end

ringCtrLength = 10;
ramWriteAddr = rdAddrCtr + ringCtrLength;
ramReadAddr = rdAddrCtr;

% This read before write to the same hRam variable gets mapped to RAM
ringBufferOut = hRam(ramReadAddr+1); % 1-based indexing
hRam(ramWriteAddr+1) = data_in;

rdAddrCtr = rdAddrCtr + 1;
