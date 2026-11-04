%   Copyright 2023-2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName1 = 'mlhdlc_hdlram_implicit';
designName2 = 'mlhdlc_hdlram_explicit';
designTB    = 'mlhdlc_hdlram_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

cfg.SynthesizeGeneratedCode = false;
cfg.SynthesisTool = 'Xilinx Vivado';
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Call codegen with float2fixed and hdl config objects.
fprintf('\n\nRunning codegen for %s\n', designName1);
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName1, '-launchreport');

fprintf('\n\nRunning codegen for %s\n', designName2);
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName2, '-launchreport');
