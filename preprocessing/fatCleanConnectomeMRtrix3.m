function fatCleanConnectomeMRtrix3(fatDir, anatDir, anatid, sessid, runName, fgName, rmOutlier)
% fatSegmentConnectome(fatDir, sessid, runName, fgName)
% fgName: full name of fg including path and postfix
% foi, a vector to indicate fiber of interest
% This function will run AFQ on a % given list of subjects and runs.
if nargin < 7, rmOutlier = true; end


[~,fgNameWoExt] = fileparts(fgName);
runDir = fullfile(fatDir,sessid,runName,'dti96trilin');
afqDir = fullfile(runDir, 'fibers','afq');
if ~exist(afqDir, 'dir')
    mkdir(afqDir);
end

%% Load and plot whole brain fiber
% Load ensemble connectome
fgFile = fullfile(fatDir,sessid,runName,...
    'dti96trilin','fibers','afq',fgName);

fg_classified = fgRead(fgFile);
fg_clean = fgRead(fgFile);
numNodes = 100;

%% Identify and remove abherrant fibers.
if rmOutlier
    
    for ii = 1:28
        try
        if ii==11
            
            cnt=0
            fg_clean(ii).fibers={};
            [SuperFiber] = dtiComputeSuperFiberRepresentation(fg_classified(ii+8), [], numNodes, 'mean'); %find the core of the AF
            
            for x=1:length(fg_classified(ii).fibers)
                if (max(fg_classified(ii).fibers{x,1}(3,:)))<(max(SuperFiber.fibers{1,1}(3,:))-5) %if max of IFOF is too close to max of AF count as AF istead
                    cnt=cnt+1
                    fg_clean(ii).fibers{cnt,1}=fg_classified(ii).fibers{x,1};
                else
                    size=length(fg_clean(ii+8).fibers)
                    fg_clean(ii+8).fibers{size+1,1}=fg_classified(ii).fibers{x,1};
                end
            end
            
        elseif ii==12
            
            cnt=0
            fg_clean(ii).fibers={};
            [SuperFiber] = dtiComputeSuperFiberRepresentation(fg_classified(ii+8), [], numNodes, 'mean'); %find the core of the AF
            
            for x=1:length(fg_classified(ii).fibers)
                if (max(fg_classified(ii).fibers{x,1}(3,:)))<(max(SuperFiber.fibers{1,1}(3,:))-5) %if max of IFOF is too close to max of AF count as AF istead
                    cnt=cnt+1
                    fg_clean(ii).fibers{cnt,1}=fg_classified(ii).fibers{x,1};
                else
                    size=length(fg_clean(ii+8).fibers)
                    fg_clean(ii+8).fibers{size+1,1}=fg_classified(ii).fibers{x,1};
                end
            end
        end
        
        
        maxDist = 4; maxLen = 4; numNodes = 100; M = 'mean'; maxIter = 200; count = true; show=false;
        
        fg_clean(ii) = AFQ_removeFiberOutliers(fg_clean(ii),...
            maxDist,maxLen,numNodes,M,count,maxIter,show);
        catch
        end
    end
    
    
    
    clear fg_classified
    
    % save file
    pName = sprintf('_clean.mat');
    fgFile = fullfile(afqDir, [fgNameWoExt, pName]);
    S.fg =  fg_clean;
    save(fgFile,'-struct','S')
end

