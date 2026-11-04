%% Runme script for HLS code generation

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_dct_1d';
testbenchName = 'mlhdlc_dct_1d_tb';

% Create fixed-point configuration
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = testbenchName;
fixptCfg.TestNumerics = true;

% Create HLS code generation configuration
hdlCfg = coder.config('hdl');
hdlCfg.Workflow = 'High Level Synthesis';
hdlCfg.TestBenchName = testbenchName;
hdlCfg.SynthesisTool = 'Xilinx Vitis HLS';
hdlCfg.SynthesizeGeneratedCode = false;
hdlCfg.GenerateHDLTestBench = true;
hdlCfg.SimulateGeneratedCode = true;

if strcmpi(hdlCfg.SynthesisTool,'Xilinx Vitis HLS')
    hdlCfg.SynthesisToolChipFamily = 'Artix7';
    hdlCfg.SynthesisToolDeviceName = 'xa7a100t';
    hdlCfg.SynthesisToolPackageName = 'csg324';
    hdlCfg.SynthesisToolSpeedValue = '-1I';
end

% Generate HLS code
codegen('-float2fixed','fixptCfg','-config','hdlCfg',designName,'-launchreport');
