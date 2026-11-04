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

%% 3D rendering MATLAB Design
% A process of creating 2D images/animation from the 3D models.
% Specifically, this example takes a 3D model and generate 2D images from a
% given perspective. 3D models are composed of multiple 3D triangles, where each 
% triangle is defined by its vertices (x0, y0, z0, x1, y1, z1, x2, y2, z2).

% The top-level function is the "mlhdlc_3D_rendering" function, 
% defined inside the "mlhdlc_3D_rendering.m".
% It is composed of the following stages (i.e., subfunctions):
%   (1) projection: project the 3D triangles to 2D triangles.
%   (2) rasterization (1,2): create a triangle box for the 2D triangle 
%       and obtain the pixels inside this 2D triangle
%       * To optimize performance, we have split the rasterization into two phases. 
%         This approach helps to balance the pipeline stages when utilizing the 
%         Vitis dataflow pragma (task-level pipelining).
%   (3) z-culling: determine the visibility of pixels based on the 
%       depth ("z" value) of each pixel. In addition, the pixels that require 
%       updating are recorded within the z_buffer.
%   (4) coloringFB: coloring framebuffer according to the z_buffer.


%% Create an HDL Coder Project with the runme files
% Method 1. Select the script "mlhdlc_3D_rendering_runme" in the leftmost bar, 
% right-click, in the pop-up menu hit "run". 
% Method 2. Double click and open this runme script, hit "Run" button in the top column.
% Method 3. In the MATLAB terminal
% >> mlhdlc_3D_rendering_runme.m

%% Create an HDL Coder Project with MATLAB command or Workflow Advisor
% To create an HDL Coder project:
%
% 1. In the MATLAB Editor, on the *Apps* tab, select *HDL Coder. 
% Enter |3D_rendering_project| as *Name* of the project.
%
% To create a project from the MATLAB command prompt, run this command:
%
%   coder -hdlcoder -new 3D_rendering_project
%
% A |3D_rendering_project.prj| file is created in the current folder. 
%
% 2. For *MATLAB Function*, click the *Add MATLAB function* link and select
% the FIR filter MATLAB design |mlhdlc_3D_rendering|. Under the *MATLAB Test Bench*
% section, click *Add files* and add the MATLAB test bench
% |mlhdlc_3D_rendering_tb.m|.
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
% If you use the "runme" script, the temporary files are located under "/tmp/mlhdlc_3D_rendering/".
% If you use the "Workflow Advisor", the temporary files are located in the same
% folder of the source files by default.
