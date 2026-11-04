
cfg = coder.config('hdl');
cfg.FloatingPointLibrary = 'NativeFloatingPoint';
cfg.AggressiveDataflowConversion = true;
codegen -config cfg -args {half(0), half(0), half(0), half(0), half(0)} mlhdlc_sfir3_half -report

