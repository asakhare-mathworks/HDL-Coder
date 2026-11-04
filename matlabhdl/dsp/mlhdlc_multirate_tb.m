%

%   Copyright 2025 The MathWorks, Inc.

%matlab\toolbox\matlab\audiovideo\mtlb.mat
load mtlb;

% Call with a not-valid data to get coverage for all lines in design
mlhdlc_multirate(mtlb(1), false);

% Clear states
clear mlhdlc_multirate;

valid_out = false(size(mtlb));
valid_in = true(size(mtlb));

% Upsample input and valid signals by 2. We use 2 because the design
% decimates by 2 and interpolates by 4 effectively increasing the rate by
% 2.
data = upsample(mtlb, 2);
valid_in = upsample(valid_in, 2);
y = zeros(numel(mtlb)*2, 1);
idx = 1;
for ii=1:numel(data)
    [out, valid_out] = mlhdlc_multirate(data(ii), valid_in(ii));
    if valid_out
        y(idx) = out;
        idx = idx + 1;
    end
end

% Compare results with dsp.FIRInterpolator and dsp.FIRInterpolator
decim = dsp.FIRDecimator(2);
decim.Numerator = fir1(35,0.4);
decim_out = decim(mtlb);
interp = dsp.FIRInterpolator(4);
interp.Numerator = designMultirateFIR(4,1);
out = interp(decim_out);

figure(1);
plot(out(1:1000-8)-y(9:1000));

%========================================================================
% Function Overview

% This MATLAB function implements a multirate system that does decimation
% by 2 followed by interpolation of 4. The output rate will be
% twice as fast as input data rate. It uses valid signals to handle
% multi-rate processing for hardware design.
%
% Key Components Filter Design:
% Uses FIR filters designed using fir1 for decimation and
% designMultirateFIR for interpolation.
%
% mlhdlc_decimate2: Decimation filter uses tap_delay variables as
% delay_line for polyphase implementation, out2 and out2 to store output
% from the filters and cnt as counter to track the output state.
%
% mlhdlc_interpolate4: Interpolation function processes input samples only
% when valid_in is true. It uses same delay line for 4 polyphase filters to
% produce 4 outputs.
%
% fir: A simple FIR filter implementation that performs the dot
% product of coefficients and delay line.
%
% Hardware Design Considerations
% The function uses persistent variables which will be mapped to registers
% in hardware.
%
% The coder.const indicates that filter coefficients should be treated as
% constants.
%
% Valid signals are used to control data flow, which is important for
% hardware implementation.
%
% valid signal indicates when the inputs and outputs to different functions
% are valid.
%
% The implementation is designed to be synthesizable by HDL Coder.
% 
% In summary this implementation demonstrates how to model multi-rate
% systems in MATLAB for hardware implementation using valid signals to
% control the data flow.
