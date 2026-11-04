%% Runme script for HDL code generation

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_mt_19937';
testbenchName = 'mlhdlc_mt_19937_tb';

% Create HDL code generation configuration
hdlCfg = coder.config('hdl');
hdlCfg.TestBenchName = testbenchName;
hdlCfg.SynthesisTool = 'Xilinx Vivado';
hdlCfg.SynthesizeGeneratedCode = false;
hdlCfg.GenerateHDLTestBench = true;
hdlCfg.SimulateGeneratedCode = true;

if strcmpi(hdlCfg.SynthesisTool,'Xilinx Vivado')
    hdlCfg.SynthesisToolChipFamily = 'Artix7';
    hdlCfg.SynthesisToolDeviceName = 'xa7a100t';
    hdlCfg.SynthesisToolPackageName = 'csg324';
    hdlCfg.SynthesisToolSpeedValue = '-1I';
end

% Generate HDL code
codegen('-config','hdlCfg',designName,'-launchreport');
