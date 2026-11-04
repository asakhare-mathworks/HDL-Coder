%

%   Copyright 2023-2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_sharing';
designTB = 'mlhdlc_sharing_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

% Ensuring that the sharing variables are having the same numerictype for
% resource sharing
signed = 1;
wordLength = 14;
fractionLength = 12;
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u1', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u2', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u3', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u4', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u5', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u6', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u7', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'u8', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'a1', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'a2', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'a3', numerictype(signed, wordLength, fractionLength));
fixptCfg.addTypeSpecification('mlhdlc_sharing', 'a4', numerictype(signed, wordLength, fractionLength));

% Set the codegen target
isCodingForHDL = true;
isCodingForStratusHLS = false;
isCodingForVitisHLS = false;

% Create HDL config.
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

% Enable resource sharing
cfg.ResourceSharing = 4;

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName, '-launchreport');

