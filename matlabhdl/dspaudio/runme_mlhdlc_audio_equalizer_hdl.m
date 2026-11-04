%   Copyright 2025 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_audio_equalizer';
designTB = 'mlhdlc_audio_equalizer_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

cfg.GenerateHDLTestBench = false;
cfg.SimulateGeneratedCode = false;

cfg.SynthesisTool = 'Xilinx Vivado';

cfg.SynthesizeGeneratedCode = false;
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Run testbench to get constants.
mlhdlc_audio_equalizer_tb

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', fixptCfg, '-config', 'cfg', designName, ...
        '-args', {y(idx), coder.Constant(b_low), gain_low, ...
                             coder.Constant(b_mid), gain_mid, ...
                             coder.Constant(b_high), gain_high},...
        '-launchreport');
