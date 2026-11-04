%   Copyright 2023 The MathWorks, Inc.

cfg = coder.config('hdl');
cfg.AggressiveDataflowConversion = true;
cfg.FrameToSampleConversion = true;
cfg.TestBenchName = 'hdlFrame_demosaic_tb';
cfg.DesignFunctionName = 'hdlFrame_demosaic';
cfg.TreatRealsInGeneratedCodeAs = 'None';
cfg.FloatingPointLibrary = 'NativeFloatingPoint';
codegen -config cfg
