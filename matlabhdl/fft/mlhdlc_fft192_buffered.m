function [y, valid_out] = mlhdlc_fft192_buffered(x)
    % Example of FFT design using window size of 192 points.
    % x comes in as frames of 16 samples.
    % When valid_out is true output y has 192 point fft values.
    input_frame_size = 16;

    persistent input_buffer overlap frame_cnt
    if isempty(input_buffer)
        input_buffer = zeros(128, 1, 'like', x);
        overlap = zeros(64, 1, 'like', x);
        frame_cnt = uint8(1);
    end

    % Buffer 128 samples and then launch fft
    start_idx = input_frame_size*(frame_cnt-1)+1;
    input_buffer(start_idx:start_idx+15) = x;
    frame_cnt = frame_cnt + 1;
    if frame_cnt < 9 % (128/input_frame_size)
        valid_out = false;
        y = zeros(192, 1, 'like', x);
    else
        valid_out = true;
        frame_cnt(:) = 1;
        fft_input = [overlap; input_buffer];
        overlap = input_buffer(65:end);
        y = mlhdlc_fft192(fft_input);
    end
end
    
function y = mlhdlc_fft192(x)
    % Perform 192 point fft
    % Input x need to be a column vector
    N = 192;
    
    % Split up into top/mid/bottom by round-robin every 3rd sample
    Buffer0=x((0:3:N-1)+1);
    Buffer1=x((1:3:N-1)+1);
    Buffer2=x((2:3:N-1)+1);
    
    % Compute 64 point FFT of each section
    fft0 = fft_radix_4(Buffer0);
    fft1 = fft_radix_4(Buffer1);
    fft2 = fft_radix_4(Buffer2);
    
    % Make 3-copies of each 64-point fft
    FFT0 = [fft0; fft0; fft0;];
    FFT1 = [fft1; fft1; fft1;];
    FFT2 = [fft2; fft2; fft2;];
    
    % Compute twiddle tables for FFT computation
    TWIDDLE1 = coder.const(generate_twiddle1);
    TWIDDLE2 = coder.const(generate_twiddle2);
    
    % Multiply by twiddle
    FFTW0 = coder.hdl.pipeline(FFT0); % top portion doesn't get a twiddle
    FFTW1 = coder.hdl.pipeline(complexGain(FFT1, TWIDDLE1));
    FFTW2 = coder.hdl.pipeline(complexGain(FFT2, TWIDDLE2));
    
    % Add up results for final FFT
    t1 = FFTW0 + FFTW1;
    y = t1 + FFTW2;
end

function [TWIDDLE1] = generate_twiddle1()
    N = 192;
    TWIDDLE1 = exp(-1j*2*pi*(0:(N-1))/N).';
    TWIDDLE1 = make_exact(TWIDDLE1);
end

function [TWIDDLE2] = generate_twiddle2()
    N = 192;
    TWIDDLE2 = exp(-1j*2*pi*2*(0:(N-1))/N).';
    TWIDDLE2 = make_exact(TWIDDLE2);
end


function [TWIDDLE]=make_exact(TWIDDLE)
    for idx = 1:numel(TWIDDLE)
        E1=real(TWIDDLE(idx))-.5;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(.5,imag(TWIDDLE(idx)));
        end
        E1=real(TWIDDLE(idx))+.5;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(-.5,imag(TWIDDLE(idx)));
        end
        E1=real(TWIDDLE(idx))-1;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(1,0);
        end
        E1=real(TWIDDLE(idx))+1;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(-1,0);
        end
        E1=imag(TWIDDLE(idx))-.5;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(real(TWIDDLE(idx)),.5);
        end
        E1=imag(TWIDDLE(idx))+.5;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(real(TWIDDLE(idx)),-.5);
        end
        E1=imag(TWIDDLE(idx))-1;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(0,1);
        end
        E1=imag(TWIDDLE(idx))+1;
        if abs(E1)<1e-4
            TWIDDLE(idx)=complex(0,-1);
        end
    end
end

function y = complexGain(u, v)
    %coder.inline('always')
    y = coder.nullcopy(u);
    for ii=coder.unroll(1:length(u))
        y(ii) = coder.hdl.pipeline(complexMul(u(ii),v(ii)));
    end
end

function y = complexMul(u, v)
    %coder.inline('always')
    re_u = real(u);
    im_u = imag(u);
    re_v = real(v);
    im_v = imag(v);
    y_re = coder.hdl.pipeline(re_u * re_v) - coder.hdl.pipeline(im_u * im_v);
    y_im = coder.hdl.pipeline(re_u * im_v) + coder.hdl.pipeline(im_u * re_v);
    y = complex(y_re, y_im);
end

function y=fft_radix_4(z)
    W = compute_twiddle;
    x=z;
    % FFT size
    numStages = 3; 
    N=64;
    for p = 1 : numStages
        M=pow2(N,-2*p); 
        O=pow2(N,-8+2*p);
        S=pow2(N,-6+(p-1)*2);    %  Make sure that the first input is a wide number so that fixed point quantization works
        x=fft_stage(x,W,N,M,O,S);      % Run a single stage
    end
    t = bitrevorder(x);
    y= t*N;
end

function W = compute_twiddle()
    W = exp(double(-1i * 2 * pi * (0 : 64 - 1) / 64));
end

function x = fft_stage(x,W,N,M,O,S)
    % Run a single FFT stage
    % x: 64 element input/output vector
    % W: 32 element twiddle factor vector
    % N: FFT size
    % M: Distance between 2 inputs of a butterfly
    % O: Number of iterations in the outer loop
    % S: Scaling factor for the twiddle factor lookup
    for index = 0 : 4*M :(N-1)
        for n = 0 : M - 1
            butterfly=butterfly_radix4(x(n + index + (0:3)* M+ 1),W([2 1 3]*S*n+1));
            x(n + (0:3)*M + 1 + index) = butterfly;
        end
    end
end

function [y] = butterfly_radix4(x,W)
    %Calculate the core butterfly for a Radix 4 FFT algorithm
    coder.inline('never');
    t=complex(zeros(4,1));
    t(1) =  x(1) +      x(2) + x(3) +      x(4)        ;
    t(2) = (x(1) -      x(2) + x(3) -      x(4)) * W(1);% .* omegaa^(2 * (4^(p - 1) * n));
    t(3) = (x(1) - 1i * x(2) - x(3) + 1i * x(4)) * W(2);% .* omegaa^(1 * (4^(p - 1) * n));
    t(4) = (x(1) + 1i * x(2) - x(3) - 1i * x(4)) * W(3);% .* omegaa^(3 * (4^(p - 1) * n));
    y=complex(pow2(real(t),-2),pow2(imag(t),-2));
end