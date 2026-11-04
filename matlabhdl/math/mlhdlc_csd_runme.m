%

%   Copyright 2023-2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_csd';
designTB = 'mlhdlc_csd_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

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
end

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus HLS"; %#ok<*UNRCH>
elseif isCodingForVitisHLS
    cfg.SynthesisTool = "Xilinx Vitis HLS";
else
    cfg.SynthesisTool = 'Xilinx Vivado';
end

cfg.SynthesizeGeneratedCode = true;
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName, '-launchreport');

