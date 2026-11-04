%

%   Copyright 2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_exp1';
designTB = 'mlhdlc_exp1_tb';

% Set the codegen target
isCodingForHDL = true;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

cfg.SynthesisTool = 'Xilinx Vivado';
cfg.SynthesizeGeneratedCode = true;
cfg.SynthesisToolChipFamily = 'Zynq UltraScale+';
cfg.SynthesisToolDeviceName = 'xazu11eg-ffvf1517-1-i';
cfg.TargetFrequency = 100;
cfg.RegisterInputs = true;
cfg.RegisterOutputs = true;
cfg.DistributedPipelining = true;
cfg.OutputPipeline = 10;
cfg.ConstantMultiplierOptimization = 'AUTO';

% Call codegen with hdl config objects.
codegen('-config', 'cfg', designName, '-launchreport');
