%#codegen


%%% Casting CustomFloat of inType to CustomFloat of cfType
function [Sign, Exponent, Mantissa] = mlhdlc_cf2cf(cfType, inSign, inExponent, inMantissa, inType)
%

%   Copyright 2025 The MathWorks, Inc.


Sign = inSign;

if (cfType == inType)
    % same type
    Exponent = inExponent;
    Mantissa = inMantissa;
elseif (inExponent == inType.Exponent_Inf_or_NaN)
    % Passing Inf or NaN
    Exponent = cfType.Exponent_Inf_or_NaN;

    if (inType.MantissaLength <= cfType.MantissaLength)
        Mantissa = fi(inMantissa, 0, cfType.MantissaLength, 0);
    else
        Mantissa = bitsliceget(inMantissa, cfType.MantissaLength, 1);
        if (inMantissa ~= 0)
            Mantissa = bitset(Mantissa, cfType.MantissaLength, 1);
        end
    end
elseif (inExponent == 0) && (inMantissa == 0)
    % Passing 0
    Exponent = fi(0, 0, cfType.ExponentLength, 0);
    Mantissa = fi(0, 0, cfType.MantissaLength, 0);
else
    [ExpCorrected_x, MantAppended_x] = appendMantissaAndCorrectExponent(inType, inExponent, inMantissa);

    e = int32(storedInteger(ExpCorrected_x)) - inType.ExponentBias + cfType.ExponentBias;

    % Normalize exponent
    pos = findFirst1(MantAppended_x);
    shift_length = uint8(MantAppended_x.WordLength) - pos;
    e(:) = e - int32(shift_length);
    if (shift_length >= MantAppended_x.WordLength)
        MantAppended_x(:) = 0;
    else
        MantAppended_x = bitsll(MantAppended_x, shift_length);
    end

    InfExponent = bitsll(int32(1), cfType.ExponentLength) - 1;

    if (e >= InfExponent)
        % Overflow -> Inf
        Exponent = fi(InfExponent, 0, cfType.ExponentLength, 0);
        Mantissa = fi(0, 0, cfType.MantissaLength, 0);
    elseif (e > -(cfType.MantissaLength + 2))
        % Add zeros to the appended mantissa if the target mantissa
        % length is not smaller.  The extra bit is used as the round
        % bit for rounding.
        if (inType.MantissaLength <= cfType.MantissaLength)
            MantExtended_x = bitconcat(MantAppended_x, fi(0, 0, cfType.MantissaLength ...
                - inType.MantissaLength + 1, 0));
        else
            MantExtended_x = MantAppended_x;
        end

        sticky = false;

        if (e > 0)
            Exponent = fi(e, 0, cfType.ExponentLength, 0);
        else
            % Shifting mantissa is needed
            shift_length1 = 1 - e;

            if (shift_length1 > 0)
                if (shift_length >= MantExtended_x.WordLength)
                    sticky = true; % MantExtended is guaranteed to be non-zero
                else
                    sticky = (bitsll(MantExtended_x, MantExtended_x.WordLength ...
                        - shift_length1) ~= 0);
                end
            end

            MantExtended_x(:) = bitsrl(MantExtended_x, shift_length1);
            Exponent = fi(0, 0, cfType.ExponentLength, 0);
        end

        if (inType.MantissaLength > cfType.MantissaLength + 1)
            sticky = (sticky || (bitsll(MantExtended_x, MantExtended_x.WordLength ...
                - (inType.MantissaLength - cfType.MantissaLength - 1)) ~= 0));
        end

        [Exponent, Mantissa] = rounding(Exponent, bitsliceget(MantExtended_x, ...
            MantExtended_x.WordLength - 1, MantExtended_x.WordLength - cfType.MantissaLength - 1), sticky);
    else
        % Way underflow, return 0
        Exponent = fi(0, 0, cfType.ExponentLength, 0);
        Mantissa = fi(0, 0, cfType.MantissaLength, 0);
    end
end

end

%%% Append Mantissa and Correct Exponent
%%% Appended Mantissa has WordLength = MantissaLength + 1
function [ExponentCorrected, MantissaAppended] = appendMantissaAndCorrectExponent(cfType, Exponent, Mantissa)

if (Exponent == 0) || (cfType.Exponent_Inf_or_NaN == Exponent)  % if exponent = 00000 or 11111
    MantissaAppended = bitconcat(fi(0, 0, 1, 0), Mantissa);     % prefix with 0.
else
    MantissaAppended = bitconcat(fi(1, 0, 1, 0), Mantissa);     % prefix with 1.
end

if (Exponent == 0)                                              % if denormal
    ExponentCorrected = cast(1, 'like', Exponent);
else                                                            % convert 00000 to 00001 (for denormal, the Exponent is 00000 but it actually is 00001)
    ExponentCorrected = Exponent;
end
end

%%% Find the position of the leading 1 bit of a fi(~,0, ~, 0) object.
function pos = findFirst1(x_fi)
coder.inline('always');

pos = uint8(0);
for ii = coder.unroll(1:1:uint8(x_fi.WordLength))
    if bitget(x_fi, ii)
        pos = ii;
    end
end
end

% Round to the nearest even
function [Exp, MantRounded] = rounding(Exp, MantExtended, sticky)
% Mantissa input has extra rounding bit to the right
% Output mantissa will have WordLength = input extended mantissa's
% WordLength - 1



% Add extra bit to prevent overflow
Mant_tmp = bitconcat(fi(0, 0, 1, 0), MantExtended);

if (bitget(Mant_tmp, 1) ~= 0) && ((bitget(Mant_tmp, 2) ~= 0) || sticky)
    Mant_tmp(:) = Mant_tmp + cast(2, 'like', Mant_tmp);
end

if (bitget(Mant_tmp, Mant_tmp.WordLength) ~= 0)
    % Rounding increases exponent
    Exp(:) = Exp + cast(1, 'like', Exp);
    MantRounded = fi(0, 0, MantExtended.WordLength - 1, 0);
else
    MantRounded = bitsliceget(Mant_tmp, Mant_tmp.WordLength - 1, 2);
end
end


