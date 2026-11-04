%

%   Copyright 2023 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_comms_toe';
designTB = 'mlhdlc_comms_toe_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

% Create HDL config.
cfg = coder.config('hdl');
cfg.Workflow = 'High Level Synthesis';
cfg.GenerateHDLTestBench = true;
cfg.TestBenchName = designTB;
cfg.SimulateGeneratedCode = true;
cfg.SynthesizeGeneratedCode = true;
cfg.SynthesisTool = "Xilinx Vitis HLS";
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';
cfg.DebugLevel = 4;

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName);
