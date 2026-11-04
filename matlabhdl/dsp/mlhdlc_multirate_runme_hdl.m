%

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_multirate';
designTB = 'mlhdlc_multirate_tb';

cfg = coder.config('hdl');
cfg.DesignFunctionName = designName;
cfg.TestBenchName = designTB;
cfg.AdaptivePipelining = true;
cfg.TargetFrequency = 300;

cfg.SynthesisTool = 'Xilinx Vivado';

cfg.SynthesizeGeneratedCode = false; % turn this on to do synthesis
cfg.SynthesisToolChipFamily = 'Virtex7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '1';

fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

codegen('-float2fixed', fixptCfg, '-config', cfg, designName, '-launchreport');
