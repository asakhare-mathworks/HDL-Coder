clear mlhdlc_fft192_buffered

total_samples = 65536; 
amplitude = 1023/1024; 

fs      = 1000; %sampling freq 
f_start = 1 ; %hz 
f_end   = 249 ; 

t = (0:(total_samples-1))/fs; 

chunk_size = 16; 
% Number of processors
N = 1; 
% FFT size is 192, overlap is 64, so we get one new FFT output every 128 input samples
chunks_per_output=128/(chunk_size*N); 

frequency = linspace(f_start,f_end,total_samples); 
input_signal = amplitude * sin(2*pi.*frequency.*t); 

parallel_chunk_size = N * chunk_size; 
iterations = floor(total_samples/parallel_chunk_size); 

output_Matrix = complex(zeros(ceil(iterations/chunks_per_output),192));   
result = complex(zeros(N,192));  

output_idx = 1;
for i = 1:iterations

    start_idx = (i-1)*parallel_chunk_size+1; 
    end_idx = i*parallel_chunk_size; 

    [result, valid_out] = mlhdlc_fft192_buffered(complex(input_signal(start_idx:end_idx)).');

    if valid_out
        out_idx_start   = (output_idx-1) * N + 1;
        out_idx_end     = output_idx * N; 
        output_idx = output_idx + 1;

        output_Matrix(out_idx_start:out_idx_end,:)  = reshape(result,192,N).'; 
    end

end 

figure(); 
image(20*log10(abs(fftshift(output_Matrix,2))),"CDataMapping","scaled");  
xlabel("FFT bin");
ylabel("FFT output [dBLSB]");
set(gca,'XTick',0:16:192);
grid on
figure;
plot(20*log10(abs(fftshift(output_Matrix(1,:)))));
hold on
plot(20*log10(abs(fftshift(output_Matrix(200,:)))));
plot(20*log10(abs(fftshift(output_Matrix(400,:)))));
xlabel("FFT bin");
ylabel("FFT output [dBLSB]");
grid on
set(gca,'XTick',0:16:192);