function [y, valid_out, ready] = mlhdlc_fft_parallel(x, valid_in, N)
% Example of FFT design that is fully parallel
% Takes scalar inputs, stores inputs until you reach buffer size of FFT
% size and computes FFT on the buffer. Suitable for small FFTs.
%
% x is input one sample at a time
% N is FFT size. Must be power of 2
% ready output indicates whether new input can be given

    persistent buffer input_idx output_idx
    if isempty(buffer)
        buffer = zeros(N, 1, 'like', x);
        input_idx = int32(0);
        output_idx = int32(0);
    end

    % Buffer samples and then launch fft
    if input_idx < N && valid_in
        buffer(input_idx+1) = x;
        input_idx = input_idx + 1;
        if input_idx == N % do fft computation
            valid_out = true;
            ready = false;
            buffer(:) = fft_radix_4(buffer, N);
            y = buffer(output_idx+1);
            output_idx = int32(1);
        else % Need more inputs
            y = x;
            ready = true;
            valid_out = false;
        end
    elseif output_idx < N % stream outputs
        valid_out = true;
        ready = false;
        y = buffer(output_idx+1);
        output_idx(:) = output_idx + 1;
    else % reset for new input
        y = x;
        input_idx = int32(0);
        output_idx = int32(0);
        valid_out = false;
        ready = true;
    end
end

function y=fft_radix_4(z, N)
    persistent W
    if isempty(W)
        W = coder.const(cast(compute_twiddle(N), 'like', z));
    end
    x=z;
    % FFT size
    numStages = coder.const(round(log(N)/log(4))); 
    for p = coder.unroll(1 : numStages)
        M=coder.const(pow2((N),-2*p));
        S=pow2(fi(N),-log2(N)+(p-1)*2);    %  Make sure that the first input is a wide number so that fixed point quantization works
        x=fft_stage(x,W,N,M,S);  % Run a single stage
    end
    t = bitrevorder(x);
    y= t*N;
end

function W = compute_twiddle(N)
    W = exp(double(-1i * 2 * pi * (0 : N - 1) / N));
end

function x = fft_stage(x,W,N,M,S)
coder.inline('always');
    % Run a single FFT stage
    % x: 64 element input/output vector
    % W: 32 element twiddle factor vector
    % N: FFT size
    % M: Distance between 2 inputs of a butterfly
    % S: Scaling factor for the twiddle factor lookup
    for index = 0 : 4*M :(N-1)
        for n = 0 : M - 1
            butterfly=butterfly_radix4(x(n + index + (0:3)* M+ 1),W([2 1 3]*S*int32(n)+1));
            x(n + (0:3)*M + 1 + index) = butterfly;
        end
    end
end

function [y] = butterfly_radix4(x,W)
    %Calculate the core butterfly for a Radix 4 FFT algorithm
    coder.inline('never');
    t=complex(zeros(4,1,'like',x));
    t(1) =  x(1) +      x(2) + x(3) +      x(4)        ;
    t(2) = (x(1) -      x(2) + x(3) -      x(4)) * W(1);% .* omegaa^(2 * (4^(p - 1) * n));
    t(3) = (x(1) - 1i * x(2) - x(3) + 1i * x(4)) * W(2);% .* omegaa^(1 * (4^(p - 1) * n));
    t(4) = (x(1) + 1i * x(2) - x(3) - 1i * x(4)) * W(3);% .* omegaa^(3 * (4^(p - 1) * n));
    y = complex(pow2(real(t),-2),pow2(imag(t),-2));
end
