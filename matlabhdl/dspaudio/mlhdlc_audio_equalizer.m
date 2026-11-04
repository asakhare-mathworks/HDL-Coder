function y_out = mlhdlc_audio_equalizer(x_in, b_low, gain_low, ...
    b_mid, gain_mid, ...
    b_high, gain_high)
% Input audio x_in is equalized with a 3 band equalizer b_low, b_mid,
% b_high are filter coeffients for the 3 bands and must be constant.
% gain_load, gain_mid and gain_high are gains for the 3 bands
% All filter lengths are assumed to be equal.

persistent lowpass bandpass highpass
if isempty(lowpass)
    lowpass = zeros(1,length(b_low));
    bandpass = zeros(1,length(b_mid));
    highpass = zeros(1,length(b_high));
end

% Shift tap delay line
lowpass = [lowpass(2:end) x_in];
bandpass = [bandpass(2:end) x_in];
highpass = [highpass(2:end) x_in];

y_low = (lowpass*b_low.') * gain_low;
y_mid = (bandpass*b_mid.') * gain_mid;
y_high = (highpass*b_high.') * gain_high;

% Combine bands
y_out = y_low + y_mid + y_high;

end
