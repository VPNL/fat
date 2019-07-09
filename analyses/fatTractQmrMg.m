function  [SuperFiber, fgResampled, TractProfile,  T1, TV]=fatTractQmrMg(dwiDir, sessid, runName, fgName, qmrDir, qmrSessid,num)
% dwiTractQmri(dwiDir, sessid, runName, fgName)
% fgName: Name of fg file

fprintf('Compute tract Qmr for (%s,%s,%s)\n',sessid,runName,fgName);
runDir = fullfile(dwiDir,sessid,runName,'dti96trilin');
afqDir = fullfile(runDir, 'fibers','afq');
numNodes = 100; clip2rois = 1;
weighting=1;
% Load fg array
fgFile = fullfile(afqDir, fgName);
if exist(fgFile,'file')
    load(fgFile,'roifg');

    % Read the t1 file
    t1File = fullfile(qmrDir,qmrSessid,'mrQnew_processed/OutPutFiles_1/BrainMaps','T1_map_Wlin.nii.gz');
    t1 = niftiRead(t1File);
    % Check t1 header
    if ~all(t1.qto_xyz(:) == t1.sto_xyz(:))
        t1 = niftiCheckQto(t1);
    end
    % Compute a Tract t1
    [SuperFiber, fgResampled, TractProfile,  T1]  = AFQ_ComputeTractProperties(roifg,t1, numNodes, clip2rois, runDir,weighting,[],num);
   
    %AFQ_ComputeTractProperties(fg_classified,dt,[numberOfNodes=30],[clip2rois=1],[subDir], [weighting = 1], afq)
    % Compute diffusion properties along the trajectory of the fiber groups.
    % Read the tv file
    tvFile = fullfile(qmrDir,qmrSessid,'mrQnew_processed/OutPutFiles_1/BrainMaps','TV_map.nii.gz');
    tv = niftiRead(tvFile);
    % Check tv header
    if ~all(tv.qto_xyz(:) == tv.sto_xyz(:))
        tv = niftiCheckQto(tv);
    end
    % Compute a Tract tv
    [SuperFiber, fgResampled, TractProfile,  TV] = AFQ_ComputeTractProperties(roifg, tv, numNodes, clip2rois, runDir,weighting,[],num);
    
    % save tract Qmr
    tractFile = fullfile(afqDir, ['TractQmr','_', fgName]);
    save(tractFile,'T1','TV');
end

            