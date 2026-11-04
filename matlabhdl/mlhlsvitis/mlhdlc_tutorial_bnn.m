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

%% BNN MATLAB Design
% Binarized neural network (BNN) design for hardwriting digit recognition

% Handwriting digit recognition pertains to a computer's capability to interpret handwritten inputs. 
% It is extensively used in document processing, signature verification, and bank check clearance. 
% An important phase in handwriting digit recognition is classification, where data is categorized 
% into one of several predetermined classes. 

% A Convolutional Neural Network (CNN) is a type of machine learning algorithm designed primarily 
% for image classification. It comprises interconnected layers, with each layer processing 
% a set of feature maps (abbreviated as fmaps) and producing a new set for the subsequent layer.
% To improve the throughput and save the power consumption, we introduce BNN, which is is 
% a specialized form of CNN where a portion or all of the input feature maps and weights are quantized to 1-bit binary values.

% In this implementation, we implement a BNN inference accelerator with 2 convolutional layers 
% followed by 2 dense/fully-connected layers.

%% Create an HDL Coder Project with the runme files
% Method 1. Select the script "mlhdlc_bnn_runme" in the leftmost bar, right-click, in the pop-up menu hit "run". 
% Method 2. Double click and open this runme script, hit "Run" button in the top column.
% Method 3. In the MATLAB terminal
% >> mlhdlc_bnn_runme.m

%% Create an HDL Coder Project with MATLAB command or Workflow Advisor
% To create an HDL Coder project:
%
% 1. In the MATLAB Editor, on the *Apps* tab, select *HDL Coder. 
% Enter |bnn_project| as *Name* of the project.
%
% To create a project from the MATLAB command prompt, run this command:
%
%   coder -hdlcoder -new bnn_project
%
% A |bnn_project.prj| file is created in the current folder. 
%
% 2. For *MATLAB Function*, click the *Add MATLAB function* link and select
% the FIR filter MATLAB design |mlhdlc_bnn|. Under the *MATLAB Test Bench*
% section, click *Add files* and add the MATLAB test bench
% |mlhdlc_bnn_tb.m|.
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
% If you use the "runme" script, the temporary files are located under "/tmp/mlhdlc_bnn/".
% If you use the "Workflow Advisor", the temporary files are located in the same
% folder of the source files by default.
