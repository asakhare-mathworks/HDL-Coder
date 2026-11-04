%% Getting Started with MATLAB to HLS Workflow
% This example shows how to create a HDL Coder(TM) project and generate code
% from your MATLAB(R) design. In this example, you:
%
% # Create a MATLAB HDL Coder project.
% # Add the design and test bench files to the project.
% # Start the HDL Workflow Advisor for the MATLAB design.
% # Run fixed-point conversion and HDL code generation.

%   Copyright 2011-2023 The MathWorks, Inc.

% This design works in both Stratus HLS and Vitis HLS.
% However, the Quality of Results (QoR) for this design can be further enhanced 
% with the support of other advanced HLS techniques.

%% Vvadd MATLAB Design
% Vector-vector addition

%% Create an HDL Coder Project with the runme files
% Method 1. Select the script "mlhdlc_vvadd_runme" in the leftmost bar, right-click, 
% in the pop-up menu hit "run". 
% Method 2. Double click and open this runme script, hit "Run" button in the top column.
% Method 3. In the MATLAB terminal
% >> mlhdlc_vvadd_runme.m

%% Create an HDL Coder Project with MATLAB command or Workflow Advisor
% To create an HDL Coder project:
%
% 1. In the MATLAB Editor, on the *Apps* tab, select *HDL Coder. 
% Enter |vvadd_project| as *Name* of the project.
%
% To create a project from the MATLAB command prompt, run this command:
%
%   coder -hdlcoder -new vvadd_project
%
% A |vvadd_project.prj| file is created in the current folder. 
%
% 2. For *MATLAB Function*, click the *Add MATLAB function* link and select
% the FIR filter MATLAB design |mlhdlc_vvadd|. Under the *MATLAB Test Bench*
% section, click *Add files* and add the MATLAB test bench
% |mlhdlc_vvadd_tb.m|.
%
% 3. Click *Autodefine types* and use the recommended types for the MATLAB
% design. The code generator infers the input types from the MATLAB test bench.
%

%% Select the Code Generation Workflow
% In the *Code Generation Workflow* column, select *MATLAB to HLS*.

%% Run Fixed-Point Conversion and HDL Code Generation
% 
% # Click the *Workflow Advisor* button to start the HDL Workflow Advisor.
% # Right-click the *HDL Code Generation* task and select *Run to selected task*.
%
% The code generator runs the Workflow Advisor tasks to generate HDL code
% for the filter design. The steps:
%
% * Translate your floating-point MATLAB design to a fixed-point design.
% To examine the generated fixed-point code from the floating-point design,
% click the *Fixed-Point Conversion* task. After the conversion, there are hyperlinks 
% for the generated fixed point code and the corresponding reports in the command
% window. Fore more information and to learn how to specify conversion options, see
% <docid:hdlcoder_ug#example-mlhdlc_tutorial_float2fixed_intro>.
%
% * Generate HLS code from the fixed-point MATLAB design.
% To examine the generated HLS code, 
% click the *HDL Code Generation* task. After code generation, there are hyperlinks
% for the generated fixed point code and the corresponding reports in the command
% window. For more information and to learn how to specify code generation options, see 
% <docid:hdlcoder_ug#example-mlhdlc_tutorial_float2fixed_intro>.

%% Location of the Generated Files
% If you use the "runme" script, the temporary files are located under "/tmp/mlhdlc_vvadd/".
% If you use the "Workflow Advisor", the temporary files are located in the same
% folder of the source files by default.
