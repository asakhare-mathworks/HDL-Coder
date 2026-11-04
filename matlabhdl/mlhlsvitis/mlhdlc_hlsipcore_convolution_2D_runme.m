% Provide Design Name and Testbench file.

%   Copyright 2025 The MathWorks, Inc.

designName = 'mlhdlc_hlsipcore_convolution_2D';
designTB = 'mlhdlc_hlsipcore_convolution_2D_tb';

% Create fixpt config object.
fixptCfg = coder.config('fixpt');
fixptCfg.TestBenchName = designTB;

fixptCfg.addTypeSpecification('mlhdlc_hlsipcore_convolution_2D', 'kernel', numerictype(0,1,0));
fixptCfg.addTypeSpecification('mlhdlc_hlsipcore_convolution_2D', 'rgbImage', numerictype(0,8,0));
fixptCfg.addTypeSpecification('mlhdlc_hlsipcore_convolution_2D', 'kernel_size', numerictype(0,3,0));
fixptCfg.addTypeSpecification('mlhdlc_hlsipcore_convolution_2D', 'kernel1', numerictype(0,8,0));
fixptCfg.addTypeSpecification('mlhdlc_hlsipcore_convolution_2D', 'kernel_reshape', numerictype(0,8,0));
fixptCfg.addTypeSpecification('mlhdlc_hlsipcore_convolution_2D', 'result', numerictype(0,8,0));
fixptCfg.addTypeSpecification('mlhdlc_hlsipcore_convolution_2D', 'sum', numerictype(0,31,0));

% Create HDL config.
cfg = coder.config('hdl');
cfg.TestBenchName = designTB;
cfg.Workflow = "IP Core Generation";
cfg.SynthesisTool = "Xilinx Vivado";
cfg.TargetLanguage = 'SynthesizableC++';

% set the RowMajor option to true, to generate code using row-major array
% layout
cfg.RowMajor = true;

% set the platform
cfg.TargetPlatform = 'ZedBoard';
cfg.SynthesisToolChipFamily = 'Zynq';
cfg.SynthesisToolDeviceName = 'xc7z020';
cfg.SynthesisToolPackageName = 'clg484';
cfg.SynthesisToolSpeedValue = '-1';

% Set target frequency
cfg.TargetFrequency = 300;

% Set the Target interface
cfg.setTargetInterface('rgbImage','AXI4 Master Read','Data');
cfg.setTargetInterface('kernel','AXI4-Lite','');
cfg.setTargetInterface('result','AXI4 Master Write','Data');

% Set the IP Core name & Version and reference design
cfg.IPCoreName = 'user_ipcore';
cfg.IPCoreVersion = '1.0';
cfg.ReferenceDesign = 'Default system with Shared Memory Access';

% Set the below commands to true, to run Embedded System Integration steps
% To create project
cfg.CreateEmbeddedSystemProject = false;
% To generate Host Interface scripts
cfg.GenerateHostInterfaceScript = false;
% To generate Bitstream
cfg.BuildBitstream = false;
cfg.BitstreamBuildMode = "External";
% To program the device
cfg.ProgramTargetDevice = false;

% Define argument types for entry-point 'mlhdlc_hlsipcore_convolution_2D'.
ARGS = cell(1,1);
ARGS{1} = cell(3,1);
ARGS{1}{1} = coder.typeof(uint8(0),[480 752]);
ARGS{1}{2} = coder.typeof(0,[1 225]);
ARGS{1}{3} = coder.Constant([15,15]);

codegen -float2fixed fixptCfg -config cfg mlhdlc_hlsipcore_convolution_2D -args ARGS{1}
