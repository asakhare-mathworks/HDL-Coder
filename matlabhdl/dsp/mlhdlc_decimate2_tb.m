clear mlhdlc_decimate2;

%matlab\toolbox\matlab\audiovideo\mtlb.mat
load mtlb;

y = zeros(size(mtlb));
valid_out = false(size(mtlb));
for ii=1:numel(mtlb)
    [y(ii), valid_out(ii)] = mlhdlc_decimate2(mtlb(ii), true);
end

% Compare results with dsp.FIRDecimator
decim = dsp.FIRDecimator;
decim.Numerator = fir1(35,0.4);
out = decim(mtlb);

validy = y(valid_out);
figure(1);
plot(out(1:1999)-validy(2:2000));

%========================================================================
% Function Overview:
%
% This MATLAB function implements a decimation filter that reduces the
% sample rate of the input signal by a factor of 2. It uses valid signals
% to handle multi-rate processing for hardware design.
%
% Filter Design:
%
% Uses a low-pass FIR filter with cutoff at 0.4 (normalized frequency).
% Filter order is 35. The coefficients are split into two sets (odd and
% even indices) to implement the two different polyphase sub-filters.
%
% Persistent Variables:
%
% tap_delay1 and tap_delay2: Two delay lines for the two polyphase
% sub-filter implementations.
% cnt: Counter to track which phase is being processed
% out1 and out2: Outputs from each sub-filter 
%
% Decimation Process:
%
% The function processes input samples only when valid_in is true. It
% alternates between two filter phases using the counter. Output is
% produced only on every other input sample. The polyphase implementation
% uses efficient decimation by using only one sub-filter per input sample.
% 
% Helper Function:
%
% mlhdlc_fir: A simple FIR filter implementation that performs the dot
% product of coefficients and delay line.
%
% The filter coefficients are split into two sets (odd and even indices).
% Two separate delay lines are maintained. On each valid input, one of the
% polyphase filters is updated. When cnt=0, the outputs from both filters
% are summed and valid output is produced. When cnt=1, no output is
% produced (valid_out = false). This approach is hardware-friendly and
% efficiently implements decimation by 2 without computing unnecessary
% outputs.
%
% Hardware Design Considerations
%
% The function uses persistent variables which will be mapped to registers
% in hardware. The coder.const call indicates that filter coefficients
% should be treated as constants and created during code generation.
%
% In summary this implementation demonstrates how to model multi-rate
% systems in MATLAB for hardware implementation using valid signals to
% control the data flow.
