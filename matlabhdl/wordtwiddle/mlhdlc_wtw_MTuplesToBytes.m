function y = mlhdlc_wtw_MTuplesToBytes(u)
% convert M tuples to Bytes

% This particular example uses bitwise slice and concat operations 
% to convert a frame of words 272x6 (6bit tuples) to 204x8 (bytes).

% The following algorithm works on 4 tuples at a time 

inpFrameLen = length(u);
symbolWL    = 6; % Number of bits per M-ary symbol (word length), M = 64
outFrameLen = symbolWL*inpFrameLen / 8;

% Initialize output index counter, dimensions, and data type
% ----------------------------------------------------------
out_idx = int32(1);
% Use the FI equivalent to uint8 (for bitwise ops below)
yt = fi(zeros(outFrameLen,1), 0, 8, 0);

% Do the byte to m-tuple conversion
% ---------------------------------
for inp_idx = int32(1:4:inpFrameLen)
    % Get next four (ufix6) input words
    i1 = u(inp_idx);
    i2 = u(inp_idx+1);
    i3 = u(inp_idx+2);
    i4 = u(inp_idx+3);
    
    % Form next three (uint8) output words
    % starting with the MSB of the first word
    yt(out_idx)   = bitconcat(i1,                    bitsliceget(i2, 6, 5));
    yt(out_idx+1) = bitconcat(bitsliceget(i2, 4, 1), bitsliceget(i3, 6, 3));
    yt(out_idx+2) = bitconcat(bitsliceget(i3, 2, 1), i4);
    
    % Increment out_idx for next time through loop
    out_idx = out_idx + 3;
end

y = uint8(yt);
