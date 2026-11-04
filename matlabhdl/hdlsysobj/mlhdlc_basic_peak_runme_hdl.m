

fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = 'mlhdlc_basic_peak_tb';

hdlcfg = coder.config('hdl');
hdlcfg.TargetLanguage = 'Verilog'; % or 'VHDL'
hdlcfg.TestBenchName = 'mlhdlc_basic_peak_tb';

%hdlcfg.AggressiveDataflowConversion = true;
hdlcfg.GenerateSimulinkModel = true;

codegen -float2fixed fixptCfg -config hdlcfg mlhdlc_basic_peak
