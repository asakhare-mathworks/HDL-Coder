% Runme file for demosaic example design

%   Copyright 2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_demosaic';
designTB = 'mlhdlc_demosaic_tb';

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

% Enable Frame to Sample Conversion
cfg.AggressiveDataflowConversion = true;
cfg.FrameToSampleConversion = true;

cfg.FloatingPointLibrary = 'NativeFloatingPoint';

cfg.SynthesisTool = 'Xilinx Vivado';
cfg.SynthesizeGeneratedCode = false; % Set this to true to synthesize generated code
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Create inputs to provide code generation arguments
I = single(imread('mlhdlc_demosaic.tif'));

% Call codegen with hdl config object.
codegen('-config', 'cfg', designName, '-launchreport', '-args', {I});
