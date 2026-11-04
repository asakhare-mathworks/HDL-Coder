%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB design: Advanced Encryption System (AES-128)
% [1] Advanced Encryption Standard (AES) (FIPS PUB 197)
%
% Key Design pattern covered in this example: 
% (1) This example uses fixed point and integer operators. 
% (2) Bitwise Operator support
%
%
% Note: This design is already in fixed point and suitable for HDL code
% generation. It is not advisable to run floating point to fixed point
% advisor on this design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Copyright 2011-2024 The MathWorks, Inc.

%#codegen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AES-128 Encryption
%
% plaintext:  text to be encrypted
% cipherkey:  key to encrypt plain text
% ciphertext: encrypted text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ciphertext = mlhdlc_aes(plaintext, cipherkey)

    RS = 10;
    k = mlhdlc_aes_getExpandedKeys(cipherkey);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % First round
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    s = bitxor(plaintext, k(:,1));
   

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Second to tenth round
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 2:RS
        s = mainroundstate(s, k(:, i));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Final round
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ciphertext = finalround(s, k(:, RS+1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main round state containing four steps:
% 1. SubBytes
% 2. ShiftRows
% 3. MixColumns
% 4. Xor text with key
%
% input s :  text state from the previous round
% input k_in:  initial key for the first round or 
%          extended round key for the other rounds
% output s: text state to the next round
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = mainroundstate(s, k_in)

    s = SubBytes(s);
    s = ShiftRows(s);
    s = MixColumns(s);
    s = bitxor(s, k_in);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final round state containing only three steps:
% 1. SubBytes
% 2. ShiftRows
% 3. Xor text with key
%
% input s:  text state from the previous round
% input k_in:  extended round key for the last round
% output s: the final cipher text
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = finalround(s, k_in)

    s = SubBytes(s);
    s = ShiftRows(s);
    s = bitxor(s, k_in);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The SubBytes step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = SubBytes(s)
BS = 4;

for i=1:BS
    for j=1:BS
        idx = uint16(s((i-1)*BS + j)) + 1;
        s((i-1)*BS + j) = mlhdlc_aes_getSboxValue(idx);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The ShiftRows step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = ShiftRows(s)

% Row1 is not touched

% Row2 left circular shifted by 1 position
temp = s(2);
s(2) = s(6);
s(6) = s(10);
s(10) = s(14);
s(14) = temp;

%Row3 left circular shifted by 2 positions
temp = s(3);
s(3) = s(11);
s(11) = temp;

temp = s(7);
s(7) = s(15);
s(15) = temp;

% Row4 left circular shifted by 3 positions
temp = s(16);
s(16) = s(12);
s(12) = s(8);
s(8) = s(4);
s(4) = temp;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The MixColumns step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = MixColumns(s)

BS = 4;
for j = 1:4
    offset = (j-1)*BS;
    a = s(offset+1);
    b = s(offset+2);
    c = s(offset+3);
    d = s(offset+4);
    t = bitxor(a,bitxor(b,bitxor(c,d)));
    
    s(offset+1) = bitxor(bitxor(xtime(bitxor(a,b)),a),t);
    s(offset+2) = bitxor(bitxor(xtime(bitxor(b,c)),b),t);
    s(offset+3) = bitxor(bitxor(xtime(bitxor(c,d)),c),t);
    s(offset+4) = bitxor(bitxor(xtime(bitxor(d,a)),d),t);
end
end

function x = xtime(x)
x = bitxor(bitsll(x,1),bitsrl(x,7)*uint8(27));
end
