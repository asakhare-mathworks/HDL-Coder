% Provide Design Name and Testbench file.

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_duc';
designTB = 'mlhdlc_duc_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;
fixptcfg.LogIOForComparisonPlotting = true;
fixptcfg.LaunchNumericTypesReport = true;

fixptCfg.DefaultWordLength = 17;
fixptCfg.fimath = sprintf('fimath(''RoundingMethod'', ''Floor'', ''OverflowAction'', ''Wrap'', ''ProductMode'', ''FullPrecision'', ''SumMode'', ''FullPrecision'')');

fixptCfg.addTypeSpecification('dds_compute', 'acc', numerictype(1,32,31));
fixptCfg.addTypeSpecification('dds_compute', 'cos_lut', numerictype(1,18,17));
fixptCfg.addTypeSpecification('dds_compute', 'cos_lut_word', numerictype(1,18,17));
fixptCfg.addTypeSpecification('dds_compute', 'cout', numerictype(1,16,15));
fixptCfg.addTypeSpecification('dds_compute', 'fine_lut', numerictype(1,18,25));
fixptCfg.addTypeSpecification('dds_compute', 'fine_word', numerictype(0,18,25));
fixptCfg.addTypeSpecification('dds_compute', 'incr', numerictype(1,32,31));
fixptCfg.addTypeSpecification('dds_compute', 'lsb', numerictype(0,1,0));
fixptCfg.addTypeSpecification('dds_compute', 'sin_lut_word', numerictype(1,18,17));
fixptCfg.addTypeSpecification('dds_compute', 'sout', numerictype(1,16,15));

fixptCfg.addTypeSpecification('mlhdlc_duc', 'cin_hb1', numerictype(1,16,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'cin_hb2', numerictype(1,16,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'cin_hb3', numerictype(1,16,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'cin_srrc', numerictype(1,16,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'cos_lut', numerictype(1,18,17));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'cos_out', numerictype(1,16,15));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'd_out', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'd_out_i', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'd_out_q', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'din_i', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'din_q', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'fine_lut', numerictype(1,18,25));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'hb1_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'hb1_dout_i', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'hb1_dout_q', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'hb2_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'hb2_dout_i', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'hb2_dout_q', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'hb3_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'incr', numerictype(1,32,31));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'sin_out', numerictype(1,16,15));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'srcc_dout_i', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'srcc_dout_q', numerictype(1,17,14));
fixptCfg.addTypeSpecification('mlhdlc_duc', 'srrc_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'acc0', numerictype(1,24,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'acc1', numerictype(1,24,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'preadd_center', numerictype(1,18,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'preadd_even', numerictype(1,18,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'preadd_odd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'prod_center', numerictype(1,19,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'prod_even', numerictype(1,19,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'prod_odd', numerictype(1,19,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'srcc_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('fir_compute_i', 'srcc_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'acc0', numerictype(1,24,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'acc1', numerictype(1,24,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'preadd_center', numerictype(1,18,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'preadd_even', numerictype(1,18,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'preadd_odd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'prod_center', numerictype(1,19,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'prod_even', numerictype(1,19,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'prod_odd', numerictype(1,19,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'srcc_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('fir_compute_q', 'srcc_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb2_fir_i', 'acc', numerictype(1,24,14));
fixptCfg.addTypeSpecification('hb2_fir_i', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb2_fir_i', 'hb_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('hb2_fir_i', 'hb_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb2_fir_i', 'preadd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('hb2_fir_i', 'prod', numerictype(1,19,14));
fixptCfg.addTypeSpecification('hb2_fir_i', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb2_fir_q', 'acc', numerictype(1,24,14));
fixptCfg.addTypeSpecification('hb2_fir_q', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb2_fir_q', 'hb_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('hb2_fir_q', 'hb_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb2_fir_q', 'preadd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('hb2_fir_q', 'prod', numerictype(1,19,14));
fixptCfg.addTypeSpecification('hb2_fir_q', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb3_fir_i', 'acc', numerictype(1,24,14));
fixptCfg.addTypeSpecification('hb3_fir_i', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb3_fir_i', 'hb_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('hb3_fir_i', 'hb_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb3_fir_i', 'preadd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('hb3_fir_i', 'prod', numerictype(1,19,14));
fixptCfg.addTypeSpecification('hb3_fir_i', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb3_fir_q', 'acc', numerictype(1,24,14));
fixptCfg.addTypeSpecification('hb3_fir_q', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb3_fir_q', 'hb_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('hb3_fir_q', 'hb_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb3_fir_q', 'preadd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('hb3_fir_q', 'prod', numerictype(1,19,14));
fixptCfg.addTypeSpecification('hb3_fir_q', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb1_fir_i', 'acc', numerictype(1,24,14));
fixptCfg.addTypeSpecification('hb1_fir_i', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb1_fir_i', 'hb_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('hb1_fir_i', 'hb_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb1_fir_i', 'preadd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('hb1_fir_i', 'prod', numerictype(1,19,14));
fixptCfg.addTypeSpecification('hb1_fir_i', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb1_fir_q', 'acc', numerictype(1,24,14));
fixptCfg.addTypeSpecification('hb1_fir_q', 'din', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb1_fir_q', 'hb_coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('hb1_fir_q', 'hb_dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('hb1_fir_q', 'preadd', numerictype(1,18,14));
fixptCfg.addTypeSpecification('hb1_fir_q', 'prod', numerictype(1,19,14));
fixptCfg.addTypeSpecification('hb1_fir_q', 'sr', numerictype(1,17,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,1', 'cin', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,1', 'coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,1', 'gain', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,2', 'cin', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,2', 'coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,2', 'gain', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,3', 'cin', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,3', 'coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_hb_coeff,0,3', 'gain', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_srrc_coeff', 'cin', numerictype(1,17,14));
fixptCfg.addTypeSpecification('initilize_srrc_coeff', 'coeff', numerictype(1,16,14));
fixptCfg.addTypeSpecification('initilize_srrc_coeff', 'gain', numerictype(1,16,14));
fixptCfg.addTypeSpecification('duc_mix', 'dds_cos', numerictype(1,16,15));
fixptCfg.addTypeSpecification('duc_mix', 'dds_sin', numerictype(1,16,15));
fixptCfg.addTypeSpecification('duc_mix', 'dout', numerictype(1,17,14));
fixptCfg.addTypeSpecification('duc_mix', 'dout_i', numerictype(1,17,14));
fixptCfg.addTypeSpecification('duc_mix', 'dout_q', numerictype(1,17,14));
fixptCfg.addTypeSpecification('duc_mix', 'dout_tmp', numerictype(1,17,14));

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;

% To simulate the generated code, set the following
% variables to "true"
cfg.Workflow = 'High Level Synthesis';
cfg.GenerateHDLTestBench = true;
cfg.SimulateGeneratedCode = true;

cfg.SynthesisTool = "Xilinx Vitis HLS";

% To synthesize the generated code, set the following
% variable to "true"
cfg.SynthesizeGeneratedCode = true;
cfg.SynthesisToolChipFamily = 'Kintex UltraScale+';
cfg.SynthesisToolDeviceName = 'xcku11p-ffva1156-1-e';
cfg.TargetFrequency = 400;

cfg.EnableTraceability = true;

ARGS = cell(1,1);
ARGS{1} = cell(3,1);
ARGS{1}{1} = coder.typeof(fi(0,numerictype(1,17,14),fimath('RoundingMethod', 'Floor',...
             'OverflowAction', 'Wrap',...
             'ProductMode','FullPrecision',...
             'SumMode','FullPrecision')),[1 200]);
ARGS{1}{2} = coder.typeof(fi(0,numerictype(1,17,14),fimath('RoundingMethod', 'Floor',...
             'OverflowAction', 'Wrap',...
             'ProductMode','FullPrecision',...
             'SumMode','FullPrecision')),[1 200]);
ARGS{1}{3} = coder.typeof(fi(0,numerictype(1,32,31),fimath('RoundingMethod', 'Floor',...
             'OverflowAction', 'Wrap',...
             'ProductMode','FullPrecision',...
             'SumMode','FullPrecision')));

codegen('-float2fixed', 'fixptCfg','-config', 'cfg', designName);
