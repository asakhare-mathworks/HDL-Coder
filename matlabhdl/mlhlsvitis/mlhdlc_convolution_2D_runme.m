% Provide Design Name and Testbench file.

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_convolution_2D';
designTB = 'mlhdlc_convolution_2D_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

fixptCfg.addTypeSpecification('mlhdlc_convolution_2D', 'kernel', numerictype(0,8,0));
fixptCfg.addTypeSpecification('mlhdlc_convolution_2D', 'kernel1', numerictype(0,8,0));
fixptCfg.addTypeSpecification('mlhdlc_convolution_2D', 'result', numerictype(0,8,0));
fixptCfg.addTypeSpecification('mlhdlc_convolution_2D', 'sum', numerictype(0,31,0));

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

% To simulate the generated code, set the following
% variables to "true"
cfg.Workflow = 'High Level Synthesis';
cfg.GenerateHDLTestBench = true;
cfg.SimulateGeneratedCode = true;

cfg.SynthesisTool = "Xilinx Vitis HLS";

% set the RowMajor option to true, to generate code using row-major array
% layout
cfg.RowMajor = true;

% To synthesize the generated code, set the following
% variable to "true"
cfg.SynthesizeGeneratedCode = true;
cfg.SynthesisToolChipFamily = 'Kintex UltraScale+';
cfg.SynthesisToolDeviceName = 'xcku11p-ffva1156-1-e';

% Set target frequency
cfg.TargetFrequency = 300;%MHz

codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName, '-launchreport');
