designName = 'mlhdlc_decimate2';
designTB = 'mlhdlc_decimate2_tb';

fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

isCodingForStratusHLS = false;
isCodingForVitisHLS = false;

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

cfg.Workflow = 'High Level Synthesis';
cfg.GenerateHDLTestBench = true;
cfg.SimulateGeneratedCode = true;

if isCodingForStratusHLS
    cfg.SynthesisTool = "Cadence Stratus HLS"; %#ok<*UNRCH>
else %if isCodingForVitisHLS
    cfg.SynthesisTool = "Xilinx Vitis HLS";
    cfg.SynthesizeGeneratedCode = true;
    cfg.SynthesisToolChipFamily = 'Artix7';
    cfg.SynthesisToolDeviceName = 'xa7a100t';
    cfg.SynthesisToolPackageName = 'csg324';
    cfg.SynthesisToolSpeedValue = '-1I';
end

% Call codegen with float2fixed and hdl config objects.
codegen('-float2fixed', 'fixptCfg', '-config', 'cfg', designName, '-launchreport');
