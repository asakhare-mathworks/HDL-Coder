% Motivation: Basic instructions to get from floating-point MATLAB code to
% Fixed-Point code and generate HDL

%   Copyright 2023-2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_sfir1';
designTB = 'mlhdlc_sfir1_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;
cfg.SynthesisTool = 'Xilinx Vivado';

cfg.SynthesizeGeneratedCode = false; % turn this on to do synthesis
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName, '-launchreport');

