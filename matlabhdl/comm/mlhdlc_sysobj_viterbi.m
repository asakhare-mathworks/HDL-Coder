%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Viterbi Decoder 
% 
% Key Design pattern covered in this example: 
% (1) Using comm system toolbox ViterbiDecoder object
% (2) The object can be called only once per design iteration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2011-2015 The MathWorks, Inc.

function decodedBits = mlhdlc_sysobj_viterbi(inputSymbol)

persistent hVitDec;

if isempty(hVitDec)
    hVitDec = comm.ViterbiDecoder('InputFormat','Hard', 'OutputDataType', 'Logical');
end

decodedBits = hVitDec(inputSymbol);
