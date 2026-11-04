function getFPGAHILSynthesisResults (models, datatype, excelSheet, synthesisToolParams)
    %
    
    % Copyright 2024-2025 The MathWorks, Inc.

    % getFPGAHILSynthesisResults : This function takes simscape model/subsystem
    % names, datatype, name of excel sheet and synthesis tool parameters as
    % inputs, goes through Simscape to HDL workflow, HDL code generation,
    % Synthesis and stores the synthesis results along with achievable time
    % step to the excel sheet.
    
    % models: this input expects a cell array of model/ subsystem names 
    % which are present in current directory or accessible on path. Eg:
    % models = {'sschdlexBoostConverterModel', 'BridgeRectifier/Subsystem'};

    % datatype: this input expects a numerictype object of either single,
    % double or fixed point. Eg:
    % datatype = numerictype('Double');
    % datatype = numerictype(0,32);
    % by default, we set datatype to numerictype('Single')

    % excelSheet: this input expects a string/character array which
    % indicates the name of the excel file where the results will be
    % stored. Eg:
    % excelSheet = 'SynthesisResults.xlsx'
    % excelSheet = 'ResultsData'
    % by default, we assign 'FPGAHILSynthesisResults.xls' as the name of 
    % excel sheet.
    
    % synthesisToolParams: this input expects a struct which contains the
    % information about synthesis tool parameters. by default, we set it to
    % synthesisToolParams = struct('SynthesisTool', 'Xilinx Vivado',...
    %'SynthesisToolChipFamily',  'Kintex7',...
    %'SynthesisToolDeviceName', 'xc7k325t',...
    %'SynthesisToolPackageName', 'fbg676',...
    %'SynthesisToolSpeedValue' , '-1',...
    %'TargetFrequency', 100);
    
    % if there are no inputs provided to the function, models array is missing
    if nargin < 1 
        err = MException('getFPGAHILSynthesisResults:MissingModelsInput',...
            'Missing the cell array of models.');
        throwAsCaller(err);
    else
        validateModels(models);
    end
    
    % to set/validate synthesis tool parameters
    if (nargin < 4) || (isempty(synthesisToolParams))
        
        disp('### Setting the default values for Synthesis tool: Xilinx Vivado...');
        disp('### Setting the default values for Synthesis tool chip family: Kintex7...');

        synthesisToolParams = struct('SynthesisTool', 'Xilinx Vivado',...
        'SynthesisToolChipFamily',  'Kintex7',...
        'SynthesisToolDeviceName', 'xc7k325t',...
        'SynthesisToolPackageName', 'fbg676',...
        'SynthesisToolSpeedValue' , '-1',...
        'TargetFrequency', 100);

    else
        validateSynthesisToolParams(synthesisToolParams);
    end
    
    % to set/validate excel sheet name
    if (nargin < 3) || (isempty(excelSheet))
        disp('### Setting the default value for excel sheet name: FPGAHILSynthesisResults.xls...');
        excelSheet = 'FPGAHILSynthesisResults.xls';
    else
        validateExcel(excelSheet);
    end
    
    % to set/validate datatype
    if (nargin < 2) || (isempty(datatype))
        disp('### Setting the default value for datatype: single...');
        datatype = numerictype('Single');
    else
        validateDatatype(datatype);
    end
    
    % to check whether synthesis tool path is set by the user or not.
    validateSynthesisToolPathSet();

    try       
        for itr = 1:length(models)
            model = models{itr};
                       
            % Load the Model
            try
                if ~bdIsLoaded(model)
                    load_system(model);
                end
                isSubsys = false;
            catch
                subsystem = model;
                model = strtok(model, '/');
                if ~bdIsLoaded(model)
                    load_system(model);
                end
                isSubsys = true;
            end
            
            % Starting ssc2hdl workflow
            if isSubsys
                disp(['### Calculating Synthesis results for "' subsystem '"...']);           
                sscCodeGenWorkflowObj = ssccodegenworkflow.SwitchedLinearWorkflow(subsystem);
            else
                disp(['### Calculating Synthesis results for "' model '"...']);           
                sscCodeGenWorkflowObj = ssccodegenworkflow.SwitchedLinearWorkflow(model); 
            end

            % set the datatype for swlin workflow object
            if any(strcmp({'single', 'double'}, datatype.DataType))
                sscCodeGenWorkflowObj.HDLAlgorithmDataType = datatype.DataType;
            elseif strcmp('Fixed', datatype.DataType)
                sscCodeGenWorkflowObj.convertToFixpt = true;
                sscCodeGenWorkflowObj.fixPtWordLength = datatype.WordLength;
            end

            % setting treat as hardware rates false to get oversampling factor
            sscCodeGenWorkflowObj.treatAsHardwareRate = false;

            % run ssc2hdl workflow    
            sscCodeGenWorkflowObj.runWorkflow;
            
            daemon_info = sscCodeGenWorkflowObj.StateSpaceParametersDeamon;

            if sscCodeGenWorkflowObj.SolverTypes(1) == 0
                solver = "Backward Euler";
                numNetworks = numel(daemon_info);
            elseif sscCodeGenWorkflowObj.SolverTypes(1) == 1
                solver = "Partitioning";
                numNetworks = numel(fields(daemon_info));
            else
                solver = "Trapezoidal Rule";
                numNetworks = numel(daemon_info);
            end        
            
            % if there are multiple networks inside the same subsystem, then we 
            % consider only 1 subsystem to go till synthesis. 
            % (All networks inside are included in this subsystem only)
            if isSubsys && (numNetworks > 1)
                numNetworks = 1;
            end           

            % get all the HDL subsystems of the implementation model
            HDLmodel = sscCodeGenWorkflowObj.HDLModel;
            solverIter = sscCodeGenWorkflowObj.NumberOfSolverIterations;
            hdlSubsystems = sscCodeGenWorkflowObj.HDLSubsystemNames;
            
            for i = 1:numNetworks
                
                % find the name of subsystem to store in excel
                solver_blk = sscCodeGenWorkflowObj.SolverConfiguration{i};
                idcs = strfind(solver_blk,'/');
                subsystem = solver_blk(1:idcs(end) - 1);

                overSampling = hdlget_param(HDLmodel, 'OverSampling');
    
                % table to capture ssc2hdl data for the provided model
                if strcmp(solver, "Partitioning")
                    
                    Parameter = ["Subsystem"; "Solver"; "Number of states"; "Number of modes";...
                        "Number of differential clumps"; "Number of algebraic clumps";...
                        "Number of solver iterations"; "OverSampling factor"];
                    
                    networkNames  = fields(daemon_info);                
                    numStates = size(daemon_info.(networkNames{i}).IC.X, 1);
                    numModes  = size(daemon_info.(networkNames{i}).IC.M, 1);
               
                    if numel(daemon_info.(networkNames{i}).DiffClumpInfo.DiffStates) == 0
                        numDiffClumps = 0;
                    else
                        numDiffClumps = 1;
                    end
                    numClumps = numel(daemon_info.(networkNames{i}).ClumpInfo);
                    

                    Value = [subsystem; string(solver); num2str(numStates); num2str(numModes);...
                        num2str(numDiffClumps); num2str(numClumps);...
                        num2str(solverIter); num2str(overSampling)];
                else
                    info = sscCodeGenWorkflowObj.StateSpaceParameters;
                    Parameter = ["Subsystem"; "Solver"; "A"; "B"; "C"; "D"; "Y0d"; "F0d"; "Number of solver iterations"; "OverSampling factor"];

                    Value = [ subsystem ; string(solver);...
                    [num2str(size(info(i).Ad, 1))  ' x ' num2str(size(info(i).Ad, 2))  ' x ' num2str(size(info(i).Ad, 3))]; ...
                    [num2str(size(info(i).Bd, 1))  ' x ' num2str(size(info(i).Bd, 2))  ' x ' num2str(size(info(i).Bd, 3))]; ...
                    [num2str(size(info(i).Cd, 1))  ' x ' num2str(size(info(i).Cd, 2))  ' x ' num2str(size(info(i).Cd, 3))]; ...
                    [num2str(size(info(i).Dd, 1))  ' x ' num2str(size(info(i).Dd, 2))  ' x ' num2str(size(info(i).Dd, 3))]; ...
                    [num2str(size(info(i).Y0d, 1)) ' x ' num2str(size(info(i).Y0d, 2)) ' x ' num2str(size(info(i).Y0d, 3))]; ...
                    [num2str(size(info(i).F0d, 1)) ' x ' num2str(size(info(i).F0d, 2)) ' x ' num2str(size(info(i).F0d, 3))]; ...
                    num2str(solverIter); num2str(overSampling)];
                    
                end
                modelInfo = table(Parameter, Value, 'VariableNames', ["Parameters", "Values"]);
                
                % store the info in excel sheet
                if i > 1
                    mdlHeading = {'';'';''; "Simscape to HDL Parameters"};
                    writecell(mdlHeading, excelSheet, 'WriteMode', 'Append', 'AutoFitWidth', true, 'Sheet', makeValidSheetName(model));
                end

                writetable(modelInfo, excelSheet, 'WriteMode', 'Append', 'WriteVariableNames', true, 'AutoFitWidth', true, 'Sheet', makeValidSheetName(model));
                
                % generate HDL code and run till synthesis
                HDLSSpaths = hdlSubsystems{i};
                % Set Implementation Model HDL parameters
                hdlset_param(HDLmodel, 'FPToleranceValue', 1.000000e-03);
                hdlset_param(HDLmodel, 'FloatingPointTargetConfiguration',...
                    hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint', 'LatencyStrategy', 'MIN'));
                hdlset_param(HDLmodel, 'MaskParameterAsGeneric', 'on');
                hdlset_param(HDLmodel, 'SynthesisTool', synthesisToolParams.SynthesisTool);
                hdlset_param(HDLmodel, 'SynthesisToolChipFamily', synthesisToolParams.SynthesisToolChipFamily );
                hdlset_param(HDLmodel, 'SynthesisToolDeviceName', synthesisToolParams.SynthesisToolDeviceName);
                hdlset_param(HDLmodel, 'SynthesisToolPackageName', synthesisToolParams.SynthesisToolPackageName);
                hdlset_param(HDLmodel, 'SynthesisToolSpeedValue', synthesisToolParams.SynthesisToolSpeedValue );
                hdlset_param(HDLmodel, 'TargetDirectory', 'hdl_prj\hdlsrc');
                hdlset_param(HDLmodel, 'TargetFrequency',  synthesisToolParams.TargetFrequency);
                
                % set the workflow to Generic ASIC/FPGA (if not done by default)
                hdlset_param(HDLmodel, 'Workflow', 'Generic ASIC/FPGA');
            
                % Workflow Configuration Settings Construct the Workflow Configuration
                % Object with default settings
                hWC = hdlcoder.WorkflowConfig('SynthesisTool', synthesisToolParams.SynthesisTool,...
                    'TargetWorkflow', 'Generic ASIC/FPGA');
            
                % Specify the top level project directory
                hWC.ProjectFolder = 'hdl_prj';
            
                % Set Workflow tasks to run
                hWC.RunTaskGenerateRTLCodeAndTestbench = true;
                hWC.RunTaskVerifyWithHDLCosimulation = false;
                hWC.RunTaskCreateProject = true;
                hWC.RunTaskAnnotateModelWithSynthesisResult = false;
                
                % running only till synthesis and going till implementation.
                if contains(synthesisToolParams.SynthesisTool,'vivado', 'IgnoreCase', true)
                    hWC.RunTaskRunSynthesis = true;
                    hWC.RunTaskRunImplementation = false;
                else
                    hWC.RunTaskPerformLogicSynthesis = true;
                    hWC.RunTaskPerformMapping = false;
                    hWC.RunTaskPerformPlaceAndRoute = false;
                end
            
                % Set properties related to 'RunTaskGenerateRTLCodeAndTestbench' Task
                hWC.GenerateRTLCode = true;
                hWC.GenerateTestbench = false;
                hWC.GenerateValidationModel = false;
            
                % Set properties related to 'RunTaskCreateProject' Task
                hWC.Objective = hdlcoder.Objective.None;
                hWC.AdditionalProjectCreationTclFiles = '';
            
                % Set properties related to 'RunTaskRunSynthesis' Task
                hWC.SkipPreRouteTimingAnalysis = false;
            
                % Set properties related to 'RunTaskRunImplementation' Task
                hWC.IgnorePlaceAndRouteErrors = false;
            
                % Set properties related to 'RunTaskAnnotateModelWithSynthesisResult' Task
                hWC.CriticalPathSource = 'pre-route';
                hWC.CriticalPathNumber =  1;
                hWC.ShowAllPaths = false;
                hWC.ShowDelayData = true;
                hWC.ShowUniquePaths = false;
                hWC.ShowEndsOnly = false;
            
                % Validate the Workflow Configuration Object
                hWC.validate;
            
                % Run the HDL workflow
                hdlcoder.runWorkflow(HDLSSpaths, hWC);
                hDI = downstream.integration('Model', HDLmodel, 'cliDisplay', true,'cmdDisplay',true);
                [~, ~, ~, hardwareResults] = hDI.run({'Synthesis', 'PostMapTiming'});
        
                % resource summary
                resourceVariables = hardwareResults.ResourceVariables;
                usage             = hardwareResults.ResourceData;
                available         = hardwareResults.AvailableResources;
                util              = hardwareResults.Utilization;
                
                resourceInfo = table(resourceVariables, usage, available, util,...
                    'VariableNames', ["Resource", "Usage", "Available", "Utilization (%)"]);

                % timing summary
                timingVariables = hardwareResults.TimingVariables;
                timingData = hardwareResults.TimingData;
                timingInfo = table(timingVariables, timingData, 'VariableNames', ["Timing", "Value"]);
                
                % Store the synthesis results in excel
                res = {'';''; 'Resources Utilization Results'};
                writecell(res, excelSheet, 'WriteMode', 'Append', 'AutoFitWidth', true, 'Sheet', makeValidSheetName(model));
                writetable(resourceInfo, excelSheet, 'WriteMode', 'Append', 'WriteVariableNames', true, 'AutoFitWidth', true, 'Sheet', makeValidSheetName(model));
                timing = {'';''; 'Timing Results'};
                writecell(timing, excelSheet, 'WriteMode', 'Append', 'AutoFitWidth', true, 'Sheet', model);
                writetable(timingInfo, excelSheet, 'WriteMode', 'Append', 'WriteVariableNames', true, 'AutoFitWidth', true, 'Sheet', makeValidSheetName(model)); 

                
                % storing the frequency in MHz, achievable time step in us
                freq = regexp(timingData{4}, '(.*)MHz', 'match', 'once');
                clkFrequency = str2double(freq(1:length(freq) - 4));
                samplingFrequency = clkFrequency/double(solverIter * overSampling);
                achievableSampleTime = 1 / samplingFrequency;

                hwResults = {'';''; 'Hardware achievable results'};
                writecell(hwResults, excelSheet, 'WriteMode', 'Append', 'AutoFitWidth', true, 'Sheet', makeValidSheetName(model));
                achievableResults = {'Sampling frequency (MHz)', samplingFrequency; 'Achievable time step (us)', achievableSampleTime};
                writecell(achievableResults, excelSheet, 'WriteMode', 'Append', 'AutoFitWidth', true, 'Sheet', makeValidSheetName(model));

            end

            if isSubsys
                disp(['### Successfuly computed the Synthesis results for "' subsystem '" and stored the results in "' excelSheet '"...']);
            else
                disp(['### Successfuly computed the Synthesis results for "' model '" and stored the results in "' excelSheet '"...']);
            end
            
            disp("Model info:"); disp(modelInfo);
            disp("Resources Utilization Results:"); disp(resourceInfo);
            disp("Timing Results:"); disp(timingInfo);
            disp("Hardware achievable results:");
            disp(['Sampling frequency (MHz): ' num2str(samplingFrequency)]);
            disp(['Achievable time step (us): ' num2str(achievableSampleTime)]);

        end
        

    catch error
        err = {model, error.identifier, error.message};
        writecell(err, excelSheet, 'WriteMode', 'Append', 'Sheet', makeValidSheetName(model));
        
        % Error message will be written to excel sheet and displayed on 
        % screen. But, the function will continue till all the models in 
        % the cell array are completed.
        disp(['>>> Error occured while running the function for "' model '"...']);
        disp(error.message);
    end
end

% to validate models input
function validateModels(models)
    if ~iscellstr(models) || isempty(models)
        err = MException('getFPGAHILSynthesisResults:InvalidModelsInput',...
            'Invalid models input to the function. Models input should be cell array of character vectors.');
        throwAsCaller(err);
    end
    % Loop through each element in the cell array
    for i = 1:numel(models)
        m = models{i};
        % Must be a char row vector 
        if ~ischar(m) || size(m,1) ~= 1
            msg = sprintf('Invalid %dnd model name entry. Model name should be a character row vector.', i);
            err = MException('getFPGAHILSynthesisResults:InvalidModelNameEntry', msg);
            throwAsCaller(err);
        end
    end
end

% to validate synthesis tool parameters
function validateSynthesisToolParams(synthesisToolParams)
    if ~isstruct(synthesisToolParams)
        err = MException('getFPGAHILSynthesisResults:InvalidSynthesisParametersInput',...
            'Invlaid synthesis tool parameters input. Synthesis tool parameters should be a struct which contains information about synthesis tool parameters');
        throwAsCaller(err);
    end
end

% to validate datatype input
function validateDatatype(datatype)
    if ~isnumerictype(datatype)
        err = MException('getFPGAHILSynthesisResults:InvalidDatatypeInput',...
            'Invalid datatype input to the function. Datatype should be of type "numerictype"');
        throwAsCaller(err);
    elseif ~any(strcmp({'single', 'double', 'Fixed'}, datatype.DataType))
        err = MException('getFPGAHILSynthesisResults:InvalidDatatypeInput',...
            'Invalid datatype input to the function. Datatype can be either single double or fixed point of type "numerictype"');
        throwAsCaller(err);
    end
end

% to validate excel sheet input
function validateExcel(excelSheet)
    if ~ischar(excelSheet) && ~isstring(excelSheet)
        err = MException('getFPGAHILSynthesisResults:InvalidExcelSheetInput',...
            'Inavlid excel input to the function. Excel sheet should be character array or string');
        throwAsCaller(err);
    end

    % if the user has not provided extension, default to '.xls'
    [~,~,ext] = fileparts(excelSheet);

    if ~any(strcmp(ext, {'xls', 'xlsx', 'csv'}))
        err = MException('getFPGAHILSynthesisResults:InvalidExcelSheetExtension',...
            'Inavlid extension in excel sheet input. The extensions can be "xls", "xlsx", "csv"');
        throwAsCaller(err);
    end
    if isempty(ext)
        filename = strcat(excelSheet, '.xls');
    end
end

% to check if synthesis tool path is set or not.
function validateSynthesisToolPathSet()
    iseToolPath       = hdlsetuptoolpath('ToolName', 'Xilinx ISE');
    alteraToolPath    = hdlsetuptoolpath('ToolName', 'Altera Quartus II');
    vivadoToolPath    = hdlsetuptoolpath('ToolName', 'Xilinx Vivado');
    microchipToolPath = hdlsetuptoolpath('ToolName', 'Microchip Libero SoC');
    quartusToolPath   = hdlsetuptoolpath('ToolName', 'Intel Quartus Pro');
    cadenceToolPath   = hdlsetuptoolpath('ToolName', 'Cadence Genus');

    if (isempty(iseToolPath) && isempty(alteraToolPath) && isempty(vivadoToolPath) && isempty(microchipToolPath) && isempty(quartusToolPath) && isempty(cadenceToolPath))
        err = MException('getFPGAHILSynthesisResults:SynthesisToolPathNotSet',...
            'Synthesis tool path is not set up. See \n>> help hdlsetuptoolpath');
        throwAsCaller(err);
    end
end
function out =  makeValidSheetName(model)
out = matlab.lang.makeValidName(model);
if length(out)>31
    out = out(1:31);
end
end