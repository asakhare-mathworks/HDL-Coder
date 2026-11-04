%

%   Copyright 2023-2024 The MathWorks, Inc.

% 

% Provide Design Name and Testbench file.
designName = 'mlhdlc_3D_rendering';
designTB = 'mlhdlc_3D_rendering_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

% Set the codegen target
isCodingForHDL = false;
isCodingForStratusHLS = false;
isCodingForVitisHLS = true;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;
if ~isCodingForHDL
    cfg.Workflow = 'High Level Synthesis';
    cfg.GenerateHDLTestBench = true;
    cfg.SimulateGeneratedCode = true;
end

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus HLS"; %#ok<*UNRCH>
elseif isCodingForVitisHLS
    cfg.SynthesisTool = "Xilinx Vitis HLS";
else
    cfg.SynthesisTool = 'Xilinx Vivado';
end

% To synthesize the generated code, set the following
% variable to "true"
cfg.SynthesizeGeneratedCode = false;
% Set target device
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';
% Set target frequency
cfg.TargetFrequency = 100; % MHz

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName, '-launchreport');

