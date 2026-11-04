%% Runme script for HLS code generation

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_mt_19937';
testbenchName = 'mlhdlc_mt_19937_tb';

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
codegen('-config','hdlCfg',designName,'-launchreport');
