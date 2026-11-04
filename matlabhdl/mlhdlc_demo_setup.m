function varargout = mlhdlc_demo_setup(demoname, demodir)
%mlhdlc_demo_setup Copy demo files to directory.
%
% mlhdlc_demo_setup('demoname') creates a temporary directory and copies
% all the required files for the demo 'demoname' to the directory. Any
% existing data in the directory will be overwritten.
%
% mlhdlc_demo_setup('demoname','demodir') copies all the required files for
% the demo 'demoname' to the directory 'demodir'. Any existing data in the
% directory will be overwritten.
%
% mlhdlc_demo_setup('list') lists the available demos.

%   Copyright 2013-2026 The MathWorks, Inc.

if nargin < 1
    error(sprintf(['Incorrect number of input arguments.\n' ...
        '\tUse mlhdlc_demo_setup(''demoname'') to copy files to a temporary directory.\n' ...
        '\tUse mlhdlc_demo_setup(''demoname'',''demodir'') to copy files to ''demodir'' directory.\n' ...
        '\tUse mlhdlc_demo_setup(''list'') to get the list of available demos.']));
end

demoname = convertStringsToChars(demoname);

if nargin == 2
    demodir = convertStringsToChars(demodir);
end

% get to the root directory of MATLAB HDL design patterns
rootDir = fullfile(matlabroot, 'toolbox', 'hdlcoder', 'hdldesignpatterns', 'matlabhdl');
% generate list of sub directories
listOfSubDirsUnderRoot = genpath(rootDir);
% remove trailing pathsep in the result
listOfSubDirsUnderRoot(end) = '';
cellArrayOfDirs = strsplit(listOfSubDirsUnderRoot, pathsep);

if strcmpi(demoname, 'list')
    fileTBList = findSpecificFiles(cellArrayOfDirs, '_tb.m');

    % Loop through each string in the cell array
    for i = 1:numel(fileTBList)
        % Replace the target substring with an empty string
        fileTBList{i} = strrep(fileTBList{i}, rootDir, '');
        fileTBList{i} = strrep(fileTBList{i}, '_tb', '');
        fileTBList{i} = ['matlabhdl', fileTBList{i}];
    end

    
    % Sort and group by folder
    fileTBList = sort(fileTBList);

    lastFolder = '';
    groupedList = {};

    for ii = 1:numel(fileTBList)
        fullPath = fileTBList{ii};
        %folderName = fileparts(fullPath);

        % Extract the subfolder after 'matlabhdl\'
        tokens = regexp(fullPath, 'matlabhdl\\([^\\]+)\\', 'tokens');
        if ~isempty(tokens)
            currentFolder = tokens{1}{1};
        else
            currentFolder = '';
        end

        % Insert separator if folder changes
        if ~strcmp(currentFolder, lastFolder)
            %if ii > 1  % to avoid BASIC folder name printed
            if strcmpi(currentFolder, 'basic')
                folderHeader = 'Get Started';
            else
                folderHeader = upper(currentFolder);
            end

                groupedList{end+1} = {['---------------      ', folderHeader, '      ---------------']};
            %end 
            lastFolder = currentFolder;
        end

        groupedList{end+1} = {fullPath};
    end

    % Convert to table
    varargout{1} = cell2table(vertcat(groupedList{:}), 'VariableNames', {'MATLAB HDLCoder Design Name'});


else
    fileList = findFilesWithSubstring(cellArrayOfDirs, demoname);

    if isempty(fileList)
        error('Demo not found. Use mlhdlc_demo_setup(''list'') to get the list of available demos.');
    end

    topHit = fileList{1};
    [pathstr, designName, ext] = fileparts(topHit);

    if nargin == 2
        targetDir = fullfile(demodir, designName);
    else
        targetDir = fullfile(tempdir, designName);
    end
    copyFilesToTarget(fileList, targetDir);
end
end

function fileList = findSpecificFiles(dirPaths, filesEndingWith)
% Initialize an empty cell array to hold the list of files
fileList = {};

% Loop through each directory path in the cell array
for i = 1:length(dirPaths)
    % Get a list of all files in the directory
    filesInDir = dir(dirPaths{i});

    % Loop through each file in the directory
    for j = 1:length(filesInDir)
        % Get the filename
        filename = filesInDir(j).name;

        % Check if the file ends with '_tb.m'
        if length(filename) > 4 && strcmp(filename(end-4:end), filesEndingWith)
            % If it does, add the full path of the file to the fileList
            fileList{end+1} = fullfile(dirPaths{i}, filename); %#ok<*AGROW>
        end
    end
end
end

function fileList = findFilesWithSubstring(folderNames, substring)
% Initialize an empty cell array to hold the list of matching files
fileList = {};

% Loop through each directory path in the cell array
for i = 1:length(folderNames)
    % Get the full path and pattern to search for files with the substring
    searchPattern = fullfile(folderNames{i}, ['*', substring, '*']);

    % Get a list of all files in the folder that contain the substring
    files = dir(searchPattern);

    % Loop through the found files and add their full paths to fileList
    for j = 1:length(files)
        if ~files(j).isdir % Skip directories
            % Construct the full file path
            fullFilePath = fullfile(folderNames{i}, files(j).name);

            % Add the file path to the fileList
            fileList{end+1} = fullFilePath;
        end
    end
end
end

function copyFilesToTarget(filesList, targetDir)

% Look for unique folders in the filesList and print the folder list here
uniqueFolders = unique(cellfun(@(x) fileparts(x), filesList, 'UniformOutput', false));
fprintf('Copying files from the following folders:\n');
for i = 1:length(uniqueFolders)
    fprintf('  %s\n', uniqueFolders{i});
end

% Ensure the target directory exists, if not, create it
if ~exist(targetDir, 'dir')
    [~,~,~] = mkdir(targetDir); % Note: [~,~,~] help suppress unnecessary messages.
else
    if isfolder(targetDir)
        [~,~,~] = rmdir(targetDir, 's');
    end
    [~,~,~] = mkdir(targetDir);
end

cd(targetDir);

% Loop through each file in the files list
for i = 1:length(filesList)
    % Get the full path of the current file
    sourceFile = filesList{i};

    % Copy the file to the target directory
    [success, message, messageId] = copyfile(sourceFile, pwd, 'f');

    [pathstr, designName, ext] = fileparts(sourceFile); %#ok<*ASGLU>

    % Check if the copy was successful    
    if success
        fprintf(1, 'Successfully copied: %s\n', designName);
    else
        fprintf(1, 'Failed to copy: %s\nError: %s\n', designName, message);
    end
end
end
