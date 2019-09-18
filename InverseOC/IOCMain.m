% test RL-based cost function derivations with the original files generated
% by PC

% clear all;
clc;
tic;

%% Add paths to directories with model definition and util functions
setPaths();

%% Define internal settings
overwriteFiles = 1;
configFilePath = '../Data/IOC_IITFatigue_test.json';

%% Create and/or look for folder where solutions are going to be saved
% currentDate = datestr(datetime('now'),'yyyy_mm_dd_HH_MM_SS');
currentDate = 'result';
savePath = sprintf('../Data/IOC/%s/', currentDate);

%% Load json file with list of all trials on which IOC will be run
configFile = jsondecode(fileread(configFilePath));

%% Load json with information about each trial
n = length(configFile.Files);

for i=1:1
    runParam = [];
    trialInfo = configFile.Files(i);
    
    % if the source matfile is not found in the json path, search these
    % following locations as well
    potentialBasePaths = {'H:/data', trialInfo.basepath};
    
    for j = 1:length(potentialBasePaths)
        targetPath = fullfile(potentialBasePaths{j}, trialInfo.subpath);
        
        if exist(targetPath, 'file')
            break;
        end
    end
    
    fprintf("Processing %s file \n", trialInfo.runName);
    
    for j = 1:length(configFile.runTemplates)
        if strcmpi(configFile.runTemplates(j).templateName, trialInfo.runTemplate)
            runParam = configFile.runTemplates(j);
            break;
        end
    end
    
    runParamFields = fieldnames(configFile.runParamGlobal);
    for j = 1:length(runParamFields)
        trialInfo.(runParamFields{j}) = configFile.runParamGlobal.(runParamFields{j});
    end
    
    runParamFields = fieldnames(runParam);
    for j = 1:length(runParamFields)
        trialInfo.(runParamFields{j}) = runParam.(runParamFields{j});
    end
    
    trialInfo.configFile = configFilePath;
    trialInfo.windowWidth = IOCInstanceNew.winSize;
    trialInfo.delta = IOCInstanceNew.delta;
    trialInfo.path = targetPath;
    
    subsavePath = fullfile(savePath, trialInfo.runName);
    [status, alreadyExist] = checkMkdir(subsavePath);
    if ~alreadyExist || overwriteFiles
        %         IOCRun(trialInfo, subsavePath);
        IOCIncomplete(trialInfo,subsavePath);
    end
end

toc