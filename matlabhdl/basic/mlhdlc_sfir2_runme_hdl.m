
cfg = coder.config('hdl');
cfg.FloatingPointLibrary = 'NativeFloatingPoint';
cfg.AggressiveDataflowConversion = true;
cfg.TreatRealsInGeneratedCodeAs = 'None';
codegen -config cfg -args {single(0), single(0), single(0), single(0), single(0)} mlhdlc_sfir2_single -report

