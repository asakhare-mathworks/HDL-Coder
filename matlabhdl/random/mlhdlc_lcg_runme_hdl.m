%% Runme script for HDL code generation

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_lcg';
testbenchName = 'mlhdlc_lcg_tb';

% Create fixed-point configuration
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = testbenchName;
fixptCfg.TestNumerics = true;

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
codegen('-float2fixed','fixptCfg','-config','hdlCfg',designName,'-launchreport');
