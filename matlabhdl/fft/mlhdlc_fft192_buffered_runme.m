%   Copyright 2024 The MathWorks, Inc.
% Provide Design Name and Testbench file.
designName = 'mlhdlc_fft192_buffered';
designTB = 'mlhdlc_fft192_buffered_tb';
% Create Fixed-Point config
fxpcfg = coder.config('fixpt');
fxpcfg.TestBenchName = designTB;

% Set the codegen target
isCodingForHDL = false;
isCodingForStratusHLS = true;
isCodingForVitisHLS = false;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;
if ~isCodingForHDL
    cfg.Workflow = 'High Level Synthesis';
    cfg.GenerateHDLTestBench = true;
    cfg.SimulateGeneratedCode = false;
    cfg.SynthesizeGeneratedCode = false;
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
codegen('-float2fixed', 'fxpcfg', '-config', 'cfg', designName);