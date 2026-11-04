
clear mlhdlc_audio_equalizer

% Load audio file
load gong.mat

% Set gain for each band
gain_low = 0.5;   % Reduce bass
gain_mid = 1.0;   % Keep mids unchanged
gain_high = 5;    % Boost treble

% Design filter bands
low_cutoff = 300;     % Hz
mid_cutoff = [300, 3000]; % Hz
high_cutoff = 3000;   % Hz

% Design FIR filters
b_low = fir1(128, low_cutoff/(Fs/2), 'low');
b_mid = fir1(128, mid_cutoff/(Fs/2), 'bandpass');
b_high = fir1(128, high_cutoff/(Fs/2), 'high');

% Apply equalizer
clear mlhdlc_audio_equalizer % Clear previous state
out = zeros(size(y), 'like', y);
for idx = 1:numel(y)
    out(idx) = mlhdlc_audio_equalizer(y(idx), b_low, gain_low, ...
                               b_mid, gain_mid, ...
                               b_high, gain_high);
end

% Uncomment to listen to audio
% fprintf("Playing original audio\n");
% player_orignal = audioplayer(double(y), Fs);
% player_orignal.play;
% pause(7)
% fprintf("Playing equalized audio\n");
% player_equalized = audioplayer(double(out), Fs);
% player_equalized.play;

% Plot original and filtered signals
figure;
subplot(2,1,1);
pspectrum(y)
title('Original Audio Power Spectrum');

subplot(2,1,2);
pspectrum(out)
title('Equalized Audio Power Spectrum');
