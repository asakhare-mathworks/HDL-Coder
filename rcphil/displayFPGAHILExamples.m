function modelsTable = displayFPGAHILExamples()
    % function which returns the location of all examples present in 
    % hil_examples and its subfolders. 
    % This function returns the location of .slx files recursively from
    % the path of this same function. Hence, this function needs to be 
    % placed in 'hil_examples' folder.
    
    path = which(mfilename);
    [folder, ~, ~] = fileparts(path);
    
    % find models recursively in all subfolders as well
    mdlStruct = dir(fullfile(folder,'**/*.slx'));
    models = {};
    if isempty(mdlStruct)
        disp('No examples were found in the folder...');
        return;
    end
    for i = 1:length(mdlStruct)
        models{end + 1} = fullfile(mdlStruct(i).folder, mdlStruct(i).name);
    end
    modelsTable = table(string(models'), 'VariableNames',"Examples");
end

