%

%   Copyright 2023-2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_european_call';
designTB = 'mlhdlc_european_call_tb';

%% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

%% Log
mathFcnGenCfg = coder.approximation('Function','log','Architecture','LookupTable','NumberOfPoints',50,'InterpolationDegree',3,'ErrorThreshold',1e-3);
mathFcnGenCfg.NumberOfPoints = 1e2;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;
fixptCfg.addApproximation(mathFcnGenCfg);

%% Exp
mathFcnGenCfg = coder.approximation('Function','exp');
mathFcnGenCfg.NumberOfPoints = 1e2;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;
fixptCfg.addApproximation(mathFcnGenCfg);

%% NormCDF
mathFcnGenCfg = coder.approximation('Function','erfc');
mathFcnGenCfg.NumberOfPoints = 1e3;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;
fixptCfg.addApproximation(mathFcnGenCfg);

%% Custom Function Replacement
mathFcnGenCfg = coder.approximation('Function','mlhdlc_european_call_invdiv','Architecture','LookupTable');
mathFcnGenCfg.NumberOfPoints = 1e3;
mathFcnGenCfg.InterpolationDegree = 1;
mathFcnGenCfg.ErrorThreshold = 1e-3;
mathFcnGenCfg.CandidateFunction = @mlhdlc_european_call_invdiv;
fixptCfg.addApproximation(mathFcnGenCfg);

%% Set the codegen target
isCodingForHDL = true;
isCodingForStratusHLS = false;
isCodingForVitisHLS = false;

%% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;
if ~isCodingForHDL
    cfg.Workflow = 'High Level Synthesis';
    cfg.GenerateHDLTestBench = true;
    cfg.SimulateGeneratedCode = true;
end

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus HLS"; %#ok<*UNRCH>
elseif isCodingForVitisHLS
    cfg.SynthesisTool = "Xilinx Vitis HLS";
else
    cfg.SynthesisTool = 'Xilinx Vivado';
end

cfg.SynthesizeGeneratedCode = true;
cfg.SynthesisToolChipFamily = 'Artix7';
cfg.SynthesisToolDeviceName = 'xa7a100t';
cfg.SynthesisToolPackageName = 'csg324';
cfg.SynthesisToolSpeedValue = '-1I';

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName, '-launchreport');

