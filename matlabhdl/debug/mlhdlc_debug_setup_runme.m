% This script helps users to debug MATLAB setup for HDL/HLS code generation.
%
% 1. access to necessary licenses
% 2. basic test for codegen workflows
% 3. access to fixed point and float2fixed capabilities
% 4. basic HDL and HLS codegen
clc

% Start a new MATLAB; print a MATLAB usage info
fprintf(1, newline)
mlR = matlabRelease;
fprintf(1, '### %s %s update %d %d', mlR.Release, mlR.Stage, mlR.Update, yyyymmdd(mlR.Date));
fprintf(1, newline)

hasFixedPointToolBox= license('test', 'fixed_point_toolbox');
hasHDLCoder = license('test', 'simulink_hdl_coder');
hasMATLABCoder = license('test', 'matlab_coder');

fprintf(1, 'Check for required products:');

fprintf(1, 'Has license for Fixed Point Designer:  %s', boolToStr(hasFixedPointToolBox));
fprintf(1, 'Has license for MATLAB Coder:  %s', boolToStr(hasMATLABCoder));
fprintf(1, 'Has license for HDL Coder:  %s', boolToStr(hasHDLCoder));
fprintf(1, newline)

% Basic Multiplier
type mlhdlc_debug_setup.m

license inuse % you should see MATLAB here
fprintf(1, newline)

% make sure fixptdesigner is installed
ver('Fixedpoint')
fprintf(1, newline)

% Define Input arguments
u = fi(pi, 0,10,0,hdlfimath); % ufix10
v = fi(pi, 0,12,0,hdlfimath); % ufix12

% Check the output type of the multiplier; expect a ufix22 output
mlhdlc_debug_setup(u, v)

license inuse
fprintf(1, newline)

% check for compiler setup
fprintf(1, 'To check for compiler setup run: mex -setup C++\n');
%mex -setup C++

% make sure MATLAB Coder is installed
ver('MATLABCoder')
fprintf(1, newline)


% Run Basic C code generation; 
hasEmbeddedCoder = license('test', 'rtw_embedded_coder');
if hasEmbeddedCoder
    cfg = coder.config('lib'); % Basic C codegen test
else
    cfg = coder.config('mex'); % Basic MEX filegen test
end


fprintf(1, 'Checking for basic C++ codegen setup:');
fprintf(1, newline)
codegen -config cfg -args {u, v} -launchreport mlhdlc_debug_setup 
license inuse
fprintf(1, newline)

% move the arguments to a testbench
type mlhdlc_debug_setup_tb.m

% run fixed-point conversion

fprintf(1, 'Checking for basic Float2Fixed workflow setup:');
fprintf(1, newline)
float2fixedCfg = coder.config('fixpt');
float2fixedCfg.TestBenchName = 'mlhdlc_debug_setup_tb';
codegen -config float2fixedCfg -args {u, v} mlhdlc_debug_setup

ver('HDLCoder')
fprintf(1, newline)

% run fixed-point conversion and hdl code generation

fprintf(1, 'Checking for basic MATLAB to HDL workflow setup:');
fprintf(1, newline)
hdlCfg = coder.config('hdl');
codegen -config float2fixedCfg -config hdlCfg -args {u, v} mlhdlc_debug_setup
fprintf(1, newline)

% run fixed-point conversion and systemC code generation

fprintf(1, 'Checking for basic MATLAB to HLS workflow setup:');
fprintf(1, newline)
systemCfg = coder.config('hdl');
systemCfg.TargetLanguage = 'SystemC';
codegen -config float2fixedCfg -config systemCfg -args {u, v} mlhdlc_debug_setup
fprintf(1, newline)


% convert boolean to yes/no
function str = boolToStr(boolValue)    
if boolValue, str = 'Yes';  else, str = 'No'; end
end