
fs = 20;  % Sampling frequency
t = 0:1/fs:2*pi*100;

clear mlhdlc_fft_parallel

F = 5;
X = complex(cos(2*pi*F*t), sin(2*pi*F*t));

X_fi = fi(X, 1, 18, 16);
y_fi = X_fi;
N = 1024; % FFT size
out_idx = 1;
for ii=1:N*5
    if ii <= N % Send inputs
      input_valid = true;
      x = X_fi(ii);
    else
        input_valid = false;
    end
    [y, valid_out, ready] = mlhdlc_fft_parallel(X_fi(ii), input_valid, N);
    if valid_out
        y_fi(out_idx) = y;
        out_idx = out_idx + 1;
        if out_idx > N
            break
        end
    end
end

plot(abs(y_fi(1:N)));