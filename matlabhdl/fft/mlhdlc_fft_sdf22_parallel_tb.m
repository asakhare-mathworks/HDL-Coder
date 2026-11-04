fs = 20;  % Sampling frequency
t = 0:1/fs:2*pi*100;

clear mlhdlc_fft_sdf22_parallel
clear y_fi

% Input signal
F = 5;
X = complex(cos(2*pi*F*t), sin(2*pi*F*t));
X_fi = fi(X);
% X_fi = fi((1:1024*10)/1000, 1, 16, 12); % For testing FFT

% FFT settings
N = 64; % FFT size
out_idx = 1;
input_valid = true;
bit_reversed_out = false; % False means output will be in natural order
numParallel = 8; % Number of inputs to send to FFT in one call

% Run until we finish one fft for first N samples and then stop
for ii=1:numParallel:N*3
    x = complex(X_fi(ii:ii+numParallel-1));
    [y, valid_out] = mlhdlc_fft_sdf22_parallel(x, input_valid, N, bit_reversed_out);
    if valid_out
        y_fi(out_idx:out_idx+numParallel-1) = y;
        out_idx = out_idx + numParallel;
        if out_idx > N+1
            break
        end
    end
end

y_fi = y_fi(1:N);
% plot(abs(bitrevorder(y_fi(1:N))));

% Check error
doubleFFT = fft(double(X_fi(1:N)));
if bit_reversed_out
    y_out = bitrevorder(double(y_fi(1:N)));
else
    y_out = double(y_fi(1:N));
end

maxError = max(abs((abs(y_out) - abs(doubleFFT))));
RealmaxError = max(abs((real(y_out) - real(doubleFFT))));
ImagmaxError = max(abs((imag(y_out) - imag(doubleFFT))));

fprintf('Max Absolute Error = %f\n', maxError);
