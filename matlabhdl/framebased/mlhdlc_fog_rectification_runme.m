% Runme file for fog rectification example design

%   Copyright 2023 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_fog_rectification';
designTB = 'mlhdlc_fog_rectification_tb';

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

% Enable Frame to Sample Conversion
cfg.AggressiveDataflowConversion = true;
cfg.FrameToSampleConversion = true;

cfg.SynthesisTool = 'Xilinx Vivado';
cfg.SynthesizeGeneratedCode = false; % Set this to true to synthesize generated code
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Create inputs to provide code generation arguments
I = imread('inputFogRectification.png');
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

% Call codegen with float2fixed and hdl config objects.
codegen('-config', 'cfg', designName, '-launchreport', '-args', {R,G,B});
