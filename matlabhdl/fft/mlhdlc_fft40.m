function y = mlhdlc_fft40(x)
% 40-point FFT
N = 40;

% split up into top/mid/bottom by round-robin every 5th sample
Buffer0=x((0:5:N-1)+1);
Buffer1=x((1:5:N-1)+1);
Buffer2=x((2:5:N-1)+1);
Buffer3=x((3:5:N-1)+1);
Buffer4=x((4:5:N-1)+1);

% compute 8 point FFT of each section
fft0 = fft8(Buffer0);
fft1 = fft8(Buffer1);
fft2 = fft8(Buffer2);
fft3 = fft8(Buffer3);
fft4 = fft8(Buffer4);

% make 5-copies of each 8-point fft
FFT0 = [fft0; fft0; fft0; fft0; fft0];
FFT1 = [fft1; fft1; fft1; fft1; fft1];
FFT2 = [fft2; fft2; fft2; fft2; fft2];
FFT3 = [fft3; fft3; fft3; fft3; fft3];
FFT4 = [fft4; fft4; fft4; fft4; fft4];

[TWIDDLE1, TWIDDLE2, TWIDDLE3, TWIDDLE4] = coder.const(@generate_twiddle_lut_40);

% multiply by twiddle
FFTW0 = coder.hdl.pipeline(FFT0); % top portion doesn't get a twiddle
FFTW1 = coder.hdl.pipeline(complexGain(complex(FFT1), complex(TWIDDLE1)));
FFTW2 = coder.hdl.pipeline(complexGain(complex(FFT2), complex(TWIDDLE2)));
FFTW3 = coder.hdl.pipeline(complexGain(complex(FFT3), complex(TWIDDLE3)));
FFTW4 = coder.hdl.pipeline(complexGain(complex(FFT4), complex(TWIDDLE4)));

% add up results for final FFT
t1 = coder.hdl.pipeline(FFTW0 + FFTW1);
t2 = coder.hdl.pipeline(FFTW2 + FFTW3);
t3 = coder.hdl.pipeline(t1 + t2);
y = coder.hdl.pipeline(t3 + FFTW4);
end

function [TWIDDLE1, TWIDDLE2, TWIDDLE3, TWIDDLE4] = generate_twiddle_lut_40()

N = 40;

TWIDDLE1=make_exact(exp(-1j*2*pi*(0:(N-1))/N).');
TWIDDLE2=make_exact(exp(-1j*2*pi*2*(0:(N-1))/N).');
TWIDDLE3=make_exact(exp(-1j*2*pi*3*(0:(N-1))/N).');
TWIDDLE4=make_exact(exp(-1j*2*pi*4*(0:(N-1))/N).');

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

function y  = fft8(u_r)
% 8 point FFT
% Real input and Complex output
% Cooley-Tukey
% Radix-2
% Decimation in Time

% N point FFT involves N/2 stages.
%
N = 8;
%reverse input order
bitrevIdx = bitrevorder(1:N);
u = u_r(bitrevIdx);
y = fft_8(N, u);

end

function x = fft_8(N, u)
tu1 = fft4(N, u(1:4));
tu2 = fft4(N, u(5:8));
i = 1:4;
tw = coder.const(@twf, double(N), double(i-1));
twu = tu2 .* tw;
x = bfly2(tu1, twu);
end

%fft4
function x = fft4(N, u)
tu1 = bfly2(u(1), u(2));
tu2 = bfly2(u(3), u(4));

% typical butterfly structure in an FFT
%
%    u0 --------------> tu0
%               \   /
%                \ /
%                 x
%                / \
%               /   \
%   u1 ---------------> tu1
%        tw

i = 1:2;
tw = coder.const(@twf, double(N), double((i-1)*2));
twu = tu2 .* tw;
x = bfly2(tu1, twu);
end

function x = bfly2(u, v)
% Two element butterfly
x = [(u + v)/2; (u - v)/2];
end

function W = twf(N, k)
% complex roots of unity (N=32)
w_N = exp(-2*pi*1i*(0:(N-1))/N).';
W = w_N(k+1);
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