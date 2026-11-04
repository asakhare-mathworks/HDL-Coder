
c = coder.config('hdl');
c.DesignFunctionName = 'mlhdlc_wtw_BytestoMTuples';
c.TestBenchName = 'mlhdlc_wtw_test';
c.TargetLanguage = "SystemVerilog"; % VHDL, Verilog or SystemVerilog or SystemC

codegen -config c


c = coder.config('hdl');
c.DesignFunctionName = 'mlhdlc_wtw_MTuplesToBytes';
c.TestBenchName = 'mlhdlc_wtw_test';
c.TargetLanguage = "SystemVerilog"; % VHDL, Verilog or SystemVerilog or SystemC

codegen -config c

