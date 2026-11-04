function y_out = mlhdlc_audio_equalizer(x_in, b_low, gain_low, ...
    b_mid, gain_mid, ...
    b_high, gain_high)
% Input audio x_in is equalized with a 3 band equalizer b_low, b_mid,
% b_high are filter coeffients for the 3 bands and must be constant.
% gain_load, gain_mid and gain_high are gains for the 3 bands

persistent lowpass bandpass highpass
if isempty(lowpass)
    lowpass = dsp.FIRFilter(b_low);
    bandpass = dsp.FIRFilter(b_mid);
    highpass = dsp.FIRFilter(b_high);
end

y_low = lowpass(x_in) * gain_low;
y_mid = bandpass(x_in) * gain_mid;
y_high = highpass(x_in) * gain_high;

% Combine bands
y_out = y_low + y_mid + y_high;
end
