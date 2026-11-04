function [y, valid_out] = mlhdlc_fft_sdf2(x, valid_in, N)
% Example of FFT pipelined design implementing radix-2 SDF architecture
% Simpler architecture compared to radix-2² SDF. Takes scalar inputs,
% produces bit reversed output. Latency is N-1. Input can be floating-point
% or fixed-point type. Output is same type as input. cast function in
% radix2 can be removed to allow bit growth.
%
% x is input one sample at a time
% N is FFT size. Must be power of 2 and a constant.

    numStages = int32(coder.const(log2(N)));
    bufferSizes = int32(coder.const(2.^(((numStages-1):-1:0))));
    bufferOffsets = coder.const(cumsum([1 bufferSizes(1:end-1)])-1);
    persistent buffer circBufferIndices control outputValidCtr
    if isempty(buffer)
        buffer = zeros(N-1, 1, 'like', x);
        control = fi(0, 0, numStages, 0, 'OverflowAction', 'Wrap');
        circBufferIndices = ones(numStages, 1, 'int32');
        outputValidCtr = int32(0);
    end

    valid_out = false;
    if valid_in
        for stage=coder.unroll(1:numStages)
            stageControl = bitget(control, numStages-stage+1);
            bufferOffset = bufferOffsets(stage);
            if stageControl
                curIdx = circBufferIndices(stage);
                in1 = buffer(curIdx+bufferOffset);
                in2 = x;
                [x, out] = radix2(in1, in2, curIdx, stage, N);
            else
                curIdx = circBufferIndices(stage);
                out = x;
                x = buffer(curIdx+bufferOffset);
            end
            buffer(curIdx+bufferOffset) = out;
            circBufferIndices(stage) = updateBufferIndex(bufferSizes(stage), curIdx);
        end
        control(:) = control + 1;
        outputValidCtr(:) = outputValidCtr + 1;
        if outputValidCtr >= int32(N)
            valid_out = true;
            outputValidCtr = int32(N);
        end
    end
    y = x;
end

function [y1, y2] = radix2(in1, in2, curIdx, stage, N)
    persistent W
    if isempty(W)
        W = coder.const(cast(compute_twiddle(N), 'like', in1));
    end
    y1 = cast(in1 + in2, 'like', in1);
    WIdx = (curIdx-1)*bitshift(1, stage-1);
    y2 = cast((in1 - in2) * W(WIdx+1), 'like', in1);
end

function W = compute_twiddle(N)
    W = exp(double(-1i * 2 * pi * (0 : N - 1) / N));
end

function newIdx = updateBufferIndex(bufferSize, startIdx)
% Update circular buffer index
newIdx = startIdx + 1;
if newIdx > bufferSize
    newIdx(:) = 1;
end
end
