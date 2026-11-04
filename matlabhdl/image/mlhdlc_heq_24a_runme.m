
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = 'mlhdlc_heq_24a_tb';

cfg = coder.config('hdl');
cfg.TestBenchName = 'mlhdlc_heq_24a_tb';

codegen -float2fixed fixptCfg -config cfg mlhdlc_heq_24a -launchreport

