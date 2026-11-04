%

%   Copyright 2023-2024 The MathWorks, Inc.

% This design requires fixed-point conversion.
% It involves division operations, 
% which need to be replaced in the hardware with a shift-add divide 
% that is performed during the conversion process.
% For details, please see:
% https://www.mathworks.com/help/hdlcoder/ug/generate-systemc-code-for-division-operation.html

% Provide Design Name and Testbench file.
designName = 'mlhdlc_moving_average';
designTB = 'mlhdlc_moving_average_tb';

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

