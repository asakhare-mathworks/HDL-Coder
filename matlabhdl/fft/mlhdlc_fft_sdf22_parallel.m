function [y, valid_out] = mlhdlc_fft_sdf22_parallel(x, valid_in, N, bitreversed_out)
% Example of FFT pipelined design implementing radix-2² SDF architecture.
% Supports any FFT size with scalar and vector inputs. Output can be
% optionally bit reversed or natural order.
%
% x is input. Number of elements must be a power of 2.
%             Number of elements must be less than FFT size N.
% N is FFT size. Must be power of 2 and a constant.
% If bitreversed_out is true output is bit reversed. If it is false output
%    is natural order. Input is expected to be in natural order.
% If output is in bitreversed order latency would be N-1. If output is in
%    natural order latency would be 2N-1.

    numStages = int32(coder.const(log2(N)));
    NumElements = int32(numel(x));
    NumElementsLog2 = coder.const(log2(double(NumElements)));
    numParallelStages = numStages - NumElementsLog2;
    bufferSizes = int32(coder.const(2.^(((numParallelStages-1):-1:0))));
    bufferOffsets = coder.const(cumsum([1 bufferSizes(1:end-1)])-1);
    persistent buffer circBufferIndices control outputValidCtr parallelStageControl
    if isempty(buffer)
        if isfi(x)
            % For fixed-point use wordlength to account for range growth
            buffer = complex(fi(zeros(NumElements, N/NumElements-1),1,x.WordLength+numStages, x.FractionLength));
        else
            buffer = complex(zeros(NumElements, N/NumElements-1, 'like', x));
        end
        control = fi(0, 0, numParallelStages, 0, 'OverflowAction', 'Wrap');
        parallelStageControl = fi(0, 0, numStages, 0, 'OverflowAction', 'Wrap');
        circBufferIndices = ones(numParallelStages, 1, 'int32');
        outputValidCtr = fi(0, 0, numStages+2, 0);
    end

    valid_out = false;
    x1 = cast(x, 'like', buffer);
    out = cast(x, 'like', buffer);
    if valid_in
        for stage=coder.unroll(1:numParallelStages)
            % control signal to decide which signal to send to pipeline
            stageControl = bitget(control, numParallelStages-stage+1);
            % pipeline for each stage is stored in same buffer.
            % bufferOffset shows start location for each stage in buffer
            bufferOffset = bufferOffsets(stage);
            for ii=1:NumElements
                if stageControl
                    curIdx = circBufferIndices(stage);
                    in1 = buffer(ii, curIdx+bufferOffset);
                    in2 = cast(x1(ii), 'like', buffer);
                    if coder.const(rem(stage, 2))
                        [x1(ii), out(ii)] = radix21(in1, in2);
                    else
                        controlIdx = cast(control*NumElements+(ii-1),'like',parallelStageControl);
                        [x1(ii), out(ii)] = radix22(in1, in2, controlIdx, stage, N, numStages);
                    end
                else
                    curIdx = circBufferIndices(stage);
                    out(ii) = x1(ii);
                    x1(ii) = buffer(ii, curIdx+bufferOffset);
                end
                buffer(ii, curIdx+bufferOffset) = out(ii);
            end
            circBufferIndices(stage) = updateBufferIndex(bufferSizes(stage), curIdx);
        end
        % Final stages to combine outputs from parallel FFTs
        localIdx = parallelStageControl;
        for stage=1:NumElementsLog2
            offset = bitsll(1, NumElementsLog2-stage);
            % localIdx gives us index for twiddle look up
            localIdx(:) = localIdx + offset;
            NumSections = bitsrl(NumElements,NumElementsLog2-stage+1);
            for section=1:NumSections %NumElements/(offset*2)
                localIdx2 = localIdx;
                localIdx2(:) = localIdx2 + (section-1)*offset*2;
                for startIdx=1:offset
                    ii = (section-1)*offset*2+startIdx;
                    if coder.const(rem(stage+numParallelStages, 2))
                        [x1(ii), x1(ii+offset)] = radix21(x1(ii), x1(ii+offset));
                    else
                        [x1(ii), x1(ii+offset)] = radix22(x1(ii), x1(ii+offset), localIdx2, stage+numParallelStages, N, numStages);
                    end
                    localIdx2(:) = localIdx2 + 1;
                end
            end
        end
        control(:) = control + 1;
        parallelStageControl(:) = parallelStageControl + NumElements;
        outputValidCtr(:) = outputValidCtr + NumElements;
        if bitreversed_out && outputValidCtr >= N
            valid_out = true;
            outputValidCtr(:) = N;
        elseif ~bitreversed_out && outputValidCtr >= N
            for ii=1:NumElements
                x1(ii) = bitreverse(x1(ii), N, numStages);
            end
            if outputValidCtr >= 2*N
                valid_out = true;
                outputValidCtr(:) = 2*N;
            end
        end
    end
    y = x1;
end

function [y1, y2] = radix21(in1, in2)
% Butterfly I with no twiddle multiplication
    y1 = cast(in1 + in2, 'like', in1);
    y2 = cast(in1 - in2, 'like', in1);
end

function [y1, y2] = radix22(in1, in2, idx, stage, N, numStages)
% Butterfly II with -j and twiddle multiplication
    persistent W
    if isempty(W)
        if isfi(in1)
            % Use wordlength from input
            W = coder.const(fi(compute_twiddle(N), 1, in1.WordLength));
        else
            % Floating-point FFT
            W = coder.const(cast(compute_twiddle(N), 'like', in1));
        end
    end
    stageidx = bitshift(int32(stage),-1)-1;
    idx(:) = idx+bitshift(int32(N),-(2*stageidx+1));
    multiplyByNegJ = bitget(idx, numStages-stage+2);
    offset = bitsrl(int32(N), stage);
    idx1 = cast(idx-offset,'like',idx);
    % factor = int32(pow2(double(stage-2)));
    % Compute WIdx1 = mod(idx1, N/factor)*factor;
    WIdx1 = bitsll(bitsrl(bitsll(idx1, stage-2),stage-2), stage-2);
    WIdx2 = bitsll(bitsrl(bitsll(idx, stage-2),stage-2), stage-2);
    if multiplyByNegJ
        in2 = complex(imag(in2), -real(in2)); % Multiply by -j
    end
    % fprintf("stage=%d idx=%d W1=%f%+fi idx=%d W2=%f%+fi mulByJ=%d\n", ...
        % stage, idx1, real(W(WIdx1+1)), imag(W(WIdx1+1)), idx, ...
        % real(W(WIdx2+1)), imag(W(WIdx2+1)), multiplyByNegJ);
    y1 = cast((in1 + in2) * W(WIdx1+1), 'like', in1);
    y2 = cast((in1 - in2) * W(WIdx2+1), 'like', in1);
end

function W = compute_twiddle(N)
% Compute twiddle and arrange in a way for easy access
    W1 = exp(double(-1i * 2 * pi * (0 : N - 1) / N));
    W = coder.nullcopy(W1);
    W(1:N/4) = 1; % Could use this information to reduce memory usage
    W((N/4+1):(N/2)) = W1(1:2:(N/2));
    W((N/2+1):(3*N/4)) = W1(((N/2+1):(3*N/4))-N/2);
    W((3*N/4+1):N) = W1(1:3:(3*N/4));
end

function newIdx = updateBufferIndex(bufferSize, startIdx)
% Update circular buffer index
newIdx = startIdx + 1;
if newIdx > bufferSize
    newIdx(:) = 1;
end
end

function y = bitreverse(x1, N, numStages)
persistent bitRevBuffer1 bitRevBuffer2 bitRevCounter writeTobuffer1
if isempty(bitRevBuffer1)
    bitRevBuffer1 = zeros(N, 1, 'like', x1);
    bitRevBuffer2 = zeros(N, 1, 'like', x1);
    bitRevCounter = fi(0, 0, numStages, 0, 'OverflowAction', 'Wrap');
    writeTobuffer1 = true;
end

readAddress = bitrev(bitRevCounter);
if writeTobuffer1
    % Read from buffer 2 in bit-reversed order and write to buffer 1
    y = bitRevBuffer2(readAddress+1);
    bitRevBuffer1(bitRevCounter+1) = x1;
else
    % Read from buffer 1 in bit-reversed order and write to buffer 2
    y = bitRevBuffer1(readAddress+1);
    bitRevBuffer2(bitRevCounter+1) = x1;
end

if bitRevCounter == N-1
    writeTobuffer1 = ~writeTobuffer1;
end
bitRevCounter(:) = bitRevCounter + 1;

end

function readAddress = bitrev(bitRevCounter)
% Reverse bits of input
wl = bitRevCounter.WordLength;
readAddress = coder.nullcopy(bitRevCounter);
for ii=1:wl
    bits = bitget(bitRevCounter, wl-ii+1);
    readAddress = bitset(readAddress, ii, bits);
end

end
