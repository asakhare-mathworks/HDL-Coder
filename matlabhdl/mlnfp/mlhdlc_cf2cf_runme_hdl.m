%

%   Copyright 2025 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_cf2cf';
designTB = 'mlhdlc_cf2cf_tb';
cfType = CustomFloatType(16, 10);   % half-precision: 16 bits, 10 mantissa bits
inType = CustomFloatType(32, 23);   % single-precision: 32 bits, 23 mantissa bits
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
% Define argument types for entry-point 'cf2cf' as individual variables

TargetType             = coder.Constant(cfType);
InputType_Sign         = coder.typeof(fi(0, numerictype(0,1,0)));
InputType_Exponent     = coder.typeof(fi(0, numerictype(0,8,0)));
InputType_Mantissa     = coder.typeof(fi(0, numerictype(0,23,0)));
InputType              = coder.Constant(inType);

% Put the argument types into a cell array for codegen
ARGS = {TargetType, InputType_Sign, InputType_Exponent, InputType_Mantissa, InputType};

% Call codegen with hdl config objects
codegen(designName, '-config', cfg, '-args', ARGS, '-launchreport');