%   Copyright 2023-2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName1 = 'mlhdlc_implicit_hdlram';
designName2 = 'mlhdlc_explicit_hdlram';
designTB    = 'mlhdlc_hdlram_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

% Set the codegen target
isCodingForStratusHLS = true;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

cfg.Workflow = 'High Level Synthesis';
cfg.GenerateHDLTestBench = true;
cfg.SimulateGeneratedCode = false;
cfg.SynthesizeGeneratedCode = false;

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus HLS"; %#ok<*UNRCH>
else
    cfg.SynthesisTool = "Xilinx Vitis HLS";
end

cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Call codegen with float2fixed and hdl config objects.
fprintf('\n\nRunning codegen for %s\n', designName1);
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName1, '-launchreport');

fprintf('\n\nRunning codegen for %s\n', designName2);
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName2, '-launchreport');
