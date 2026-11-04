function RoundKey = mlhdlc_aes_getExpandedKeys(Key)
% Key extension
% Computes the keys required for each round.
%
% Input: Key : the given cypherkey  
%Output: RoundKey: each column stores the key for corresponding round.
%#codegen

%   Copyright 2024 The MathWorks, Inc.

f = @hex2dec;
Rcon = uint8([f('01') f('02')  f('04') f('08'), f('10') f('20') ...
    f('40') f('80')  f('1b') f('36')]);
NR = uint8(10);
NK = uint8(4); % four 32 bit words
NB = uint8(4); % block size is four 32 bit works
RoundKey = zeros(NK*NK,NR+1,'uint8');
RoundKey(:,1) = Key;
temp = zeros(4,1,'uint8');
id = 0;
for i = NK:NB*(NR+1) - 1
   k = (i-1)*4;
   temp(1) = RoundKey(k+1);
   temp(2) = RoundKey(k+2);
   temp(3) = RoundKey(k+3);
   temp(4) = RoundKey(k+4);
   if mod(i,NK) == 0
       id = id + 1;
       t1 = temp(1);
       temp(1) = temp(2);
       temp(2) = temp(3);
       temp(3) = temp(4);
       temp(4) = t1;
       temp(1) = mlhdlc_aes_getSboxValue(uint16(temp(1))+1);
       temp(2) = mlhdlc_aes_getSboxValue(uint16(temp(2))+1);
       temp(3) = mlhdlc_aes_getSboxValue(uint16(temp(3))+1);
       temp(4) = mlhdlc_aes_getSboxValue(uint16(temp(4))+1);

       temp(1) = bitxor(temp(1),Rcon(id));
   end
   
   j = 4*i; k = (i-NK)*4;
   RoundKey(j+1) = bitxor(RoundKey(k+1),temp(1));
   RoundKey(j+2) = bitxor(RoundKey(k+2),temp(2));
   RoundKey(j+3) = bitxor(RoundKey(k+3),temp(3));
   RoundKey(j+4) = bitxor(RoundKey(k+4),temp(4));   
end
end
