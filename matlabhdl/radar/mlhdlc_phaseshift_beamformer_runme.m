% Runme: Phase shift beamforming for a sensor array.

%   Copyright 2024 The MathWorks, Inc.

% Provide Design Name and Testbench
designName = 'mlhdlc_phaseshift_beamformer';
designTB = 'mlhdlc_phaseshift_beamformer_tb';

% Set the codegen target
isCodingForHDL = true;
isCodingForStratusHLS = false;
isCodingForVitisHLS = false;

% Create HDL config
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;
if ~isCodingForHDL
    error('This example does not support HLS code generation.');
end

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus"; %#ok<*UNRCH>
elseif isCodingForVitisHLS
    cfg.SynthesisTool = "Xilinx Vitis HLS";
else
    cfg.SynthesisTool = 'Xilinx Vivado';
end

cfg.SynthesizeGeneratedCode = true;
cfg.GenerateReport = true;
cfg.SynthesisToolChipFamily = 'Kintex7';
cfg.SynthesisToolDeviceName = 'xq7k325t';
cfg.SynthesisToolPackageName = 'rf900';
cfg.SynthesisToolSpeedValue = '-1I';
cfg.FloatingPointLibrary = "NativeFloatingPoint";
cfg.TreatIOThresholdAs = 'None';
cfg.AggressiveDataflowConversion = true;
cfg.TargetFrequency = 100;

% Generate HDL code
codegen('-config', 'cfg', designName, '-launchreport');
