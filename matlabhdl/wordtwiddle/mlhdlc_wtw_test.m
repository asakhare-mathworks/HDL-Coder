% Basic Word Twiddle Test

a = randi(255, [204,1]);
b = uint8(a);

% uint8(204) ===> ufix6(272)
c = mlhdlc_wtw_BytestoMTuples(b);

% ufix6(272) ===> uint8(204) 
d = mlhdlc_wtw_MTuplesToBytes(c);

assert(isequal(b,d));
