designName = 'mlhdlc_decimate2';
designTB = 'mlhdlc_decimate2_tb';

cfg = coder.config('hdl');
cfg.DesignFunctionName = designName;
cfg.TestBenchName = designTB;

fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

codegen('-float2fixed', fixptCfg, '-config', cfg, designName, '-launchreport');
