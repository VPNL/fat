function [dtFolder,dtFile]=fatCreateDT6(dwiDir,sessid,runName,t1_name,force)
% fatPreprocess(dwiDir, sessid, runName)
% The function will preprocess the data and produce a dt6 file

if nargin < 5, force = false; end



for s = 1:length(sessid)
    for r = 1:length(runName)
        fprintf('Run preprocess for (%s,%s)\n',sessid{s},runName{r});
        
        runDir = fullfile(dwiDir,sessid{s},runName{r});
        
        % Init the params through vistasoft
        dwParams = dtiInitParams('clobber',force);
        dwParams.eddyCorrect =-1;
        dwParams.outDir=runDir;
        
        
        cd(runDir)
        dtFolder=dir('dti*') ;
        dtFile=fullfile(runDir,dtFolder.name,'dt6.mat');
        
        
        
        % if a dt6 file exists, skip the run
        if ~exist(dtFile,'file') || force
            
            dtiNiftiPath = fullfile(runDir,'dwi_processed.nii.gz');
            t1NiftiPath  = fullfile(runDir,'t1',t1_name);
            
            % Now process
            fprintf('Beginning dwi preprocess for (%s,%s)\n',...
                sessid{s},runName{r})
            
            fat_AFQ_dtiInit(dtiNiftiPath,t1NiftiPath,dwParams);
            
            fprintf('Succesfully created dt6 file for for (%s,%s)\n',...
                sessid{s},runName{r});
        else
            fprintf('DT6 already made for (%s,%s)\n',sessid{s}, runName{r})
            
        end
        
        cd(runDir)
        dtFolder=dir('*trilin') ;
        dtFile=fullfile(runDir,dtFolder.name,'dt6.mat');
    end
end
