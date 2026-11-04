%

%   Copyright 2024 The MathWorks, Inc.

% Provide Design Name and Testbench file.
designName = 'mlhdlc_exp1';
designTB = 'mlhdlc_exp1_tb';

% Set the codegen target
isCodingForStratusHLS = true;
%isCodingForVitisHLS = false;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

cfg.Workflow = 'High Level Synthesis';

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus HLS";
% elseif isCodingForVitisHLS
%     cfg.SynthesisTool = "Xilinx Vitis HLS";
end

cfg.TargetFrequency = 100;

% Call codegen with hdl config objects.
codegen('-config', 'cfg', designName, '-launchreport');
