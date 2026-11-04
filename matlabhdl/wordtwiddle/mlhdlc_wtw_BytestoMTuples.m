function y = mlhdlc_wtw_BytestoMTuples(u)
% convert Bytes to M tuples

% This particular example uses bitwise slice and concat operations 
% to convert a frame of words 204x8 (bytes) to 272x6 (6bit tuples).

% The following algorithm works on 3 bytes at a time 

symbolWL    = 6; % Number of bits per M-ary symbol (word length), M = 64
inpFrameLen = length(u);
outFrameLen = 8*inpFrameLen / symbolWL;

% Initialize output index counter, dimensions, and data type
% ----------------------------------------------------------
out_idx = int32(1);
y       = fi(zeros(outFrameLen,1),0,6,0);

% Do the byte to m-tuple conversion
% ---------------------------------
nt = numerictype(0, 8, 0); % FI equivalent to uint8 (for bitwise ops below)
for inp_idx = int32(1:3:inpFrameLen)
    % Get next three (uint8) input words
    a = fi(u(inp_idx),   nt);
    b = fi(u(inp_idx+1), nt);
    c = fi(u(inp_idx+2), nt);
    
    % Form next four (ufix6) output words
    % starting with the MSB of the first word
    y(out_idx)   = bitsliceget(a, 8, 3);
    y(out_idx+1) = bitconcat(bitsliceget(a, 2, 1), bitsliceget(b, 8, 5));
    y(out_idx+2) = bitconcat(bitsliceget(b, 4, 1), bitsliceget(c, 8, 7));
    y(out_idx+3) = bitsliceget(c, 6, 1);
    
    % Increment out_idx for next time through loop
    out_idx = out_idx + 4;
end
