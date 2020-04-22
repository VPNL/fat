function  [fa, md, rd, ad]=fatTractDmrMg(dwiDir, sessid, runName, fgName)
% dwiTractQmri(dwiDir, sessid, runName, fgName)
% fgName: Name of fg file

fprintf('Compute tract Qmr for (%s,%s,%s)\n',sessid,runName,fgName);
runDir = fullfile(dwiDir,sessid,runName,'dti96trilin');
afqDir = fullfile(runDir, 'fibers','afq');
numNodes = 30; clip2rois = 1;
% Load fg array
fgFile = fullfile(afqDir, fgName);
if exist(fgFile,'file')
    load(fgFile,'roifg');

    % Read the t1 file
  dt = dtiLoadDt6(fullfile(dwiDir,sessid,'96dir_run2','dti96trilin','dt6.mat'));
    
    % Compute a Tract t1
    [fa, md, rd, ad]  = AFQ_ComputeTractProperties(roifg, dt, numNodes, clip2rois, runDir,'mean');
    %AFQ_ComputeTractProperties(fg_classified,dt,[numberOfNodes=30],[clip2rois=1],[subDir], [weighting = 1], afq)
    % Compute diffusion properties along the trajectory of the fiber groups.
    % Read the tv file
%   dt = dtiLoadDt6(fullfile(runDir,'dt6.mat'));
%     % Compute a Tract tv
%     [SuperFiber, fgResampled, TractProfile,  md] = AFQ_ComputeTractProperties(roifg, dt, numNodes, clip2rois, runDir,0);
%     
%     % save tract Qmr
%     tractFile = fullfile(afqDir, ['TractQmr','_', fgName]);
%     save(tractFile,'fa','md');
end

            
            