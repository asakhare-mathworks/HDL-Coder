%   Copyright 2025 The MathWorks, Inc.

mlhdlc_fft_sdf22_parallel_tb % Run test bench to get sample inputs

% Provide Design Name and Testbench file.
designName = 'mlhdlc_fft_sdf22_parallel';
designTB = 'mlhdlc_fft_sdf22_parallel_tb';

% Set the codegen target
isCodingForHDL = true;
isCodingForStratusHLS = false;
isCodingForVitisHLS = false;

valid_in = true;
bit_reversed_output = coder.Constant(true);

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

codegen('-config', cfg, ...
    '-args', {X_fi(1), true, coder.Constant(N), bit_reversed_output },...
    '-report', designName);
