%

%   Copyright 2023-2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_fft_channelizer';
designTB = 'mlhdlc_fft_channelizer_tb';

% Simulate the MATLAB TB
mlhdlc_fft_channelizer_tb;

% Set the codegen target
isCodingForHDL = true;
isCodingForStratusHLS = false;
isCodingForVitisHLS = false;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;
if ~isCodingForHDL
    cfg.Workflow = 'High Level Synthesis';
    cfg.GenerateHDLTestBench = true;
    cfg.SimulateGeneratedCode = true;
    cfg.SynthesizeGeneratedCode = true;
end

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus HLS"; %#ok<*UNRCH>
elseif isCodingForVitisHLS
    cfg.SynthesisTool = "Xilinx Vitis HLS";
    cfg.SynthesisToolChipFamily = 'Artix7';
    cfg.SynthesisToolDeviceName = 'xa7a100t';
    cfg.SynthesisToolPackageName = 'csg324';
    cfg.SynthesisToolSpeedValue = '-1I';
end

% Call codegen with float2fixed and hdl config objects.
codegen('-config', 'cfg', designName);
