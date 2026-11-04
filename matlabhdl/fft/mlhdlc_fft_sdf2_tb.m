
fs = 20;  % Sampling frequency
t = 0:1/fs:2*pi*100;

clear mlhdlc_fft_sdf2

F = 5;
X = complex(cos(2*pi*F*t), sin(2*pi*F*t));
X_fi = fi(X, 1, 32, 16);

N = 1024; % FFT size
out_idx = 1;
input_valid = true;

% Run until we finish one fft for first N samples and then stop
for ii=1:N*3
    x = X_fi(ii);
    [y, valid_out] = mlhdlc_fft_sdf2(X_fi(ii), input_valid, N);
    if valid_out
        y_fi(out_idx) = y;
        out_idx = out_idx + 1;
    end
end

plot(abs(bitrevorder(y_fi(1:N))));
