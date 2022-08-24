function fgFile_classified=babyFatSegmentConnectomeMRtrix3(fatDir, ROIdir,...
    sessid, runName, fgName, computeRoi,anatFile,asegFile)
% fatSegmentConnectome(fatDir, sessid, runName, fgName)
% fgName: full name of fg including path and postfix
% foi, a vector to indicate fiber of interest
% This function will run AFQ on a % given list of subjects and runs.

if computeRoi
    useRoiBasedApproach = true;
else
    useRoiBasedApproach = [2,0];
end

[~,fgNameWoExt] = fileparts(fgName);

fprintf('\nConnectome segment for (%s, %s, %s)\n',sessid,runName,fgNameWoExt);

cd(fullfile(fatDir,sessid,runName))
subdir=dir('*trilin')
runDir = fullfile(fatDir,sessid,runName,subdir.name);
afqDir = fullfile(runDir, 'fibers','afq');
if ~exist(afqDir, 'dir')
    mkdir(afqDir);
end

%% Load and plot whole brain fiber
% Load ensemble connectome
wholeBrainfgFile = fullfile(runDir,'fibers', strcat(fgNameWoExt, '.mat'));

wholebrainFG = fgRead(wholeBrainfgFile);
%% classified the fibers
% Load the subject's dt6 file (generated from dtiInit).

dt = dtiLoadDt6(fullfile(runDir,'dt6.mat'));

% Segment the whole-brain fiber group into 20 fiber tracts
[fg_classified,fg_unclassified,classification,fg] = babyAFQ_SegmentFiberGroups(dt, wholebrainFG,...
    [],useRoiBasedApproach, [], [], anatFile);

fg.classifiedWithBabyAFQIndex=classification.index;
fg.classifiedWithBabyAFQNames=classification.names;
clear wholebrainFG

%prepare VOF ROI
%%
babyFatDtiRoi2Nii(fatDir, sessid, runName,[])
cmd_str=['mri_convert ' fullfile(ROIdir,'VOF_box_L.nii.gz') ' ',...
    fullfile(ROIdir,'VOF_box_L_resliced.nii.gz') ' --reslice_like ',...
    fullfile(fatDir, sessid, runName,'t1', asegFile)];
system(cmd_str);

cmd_str=['mri_convert ' fullfile(ROIdir,'VOF_box_R.nii.gz') ' ',...
    fullfile(ROIdir,'VOF_box_R_resliced.nii.gz') ' --reslice_like ',...
    fullfile(fatDir, sessid, runName,'t1', asegFile)];
system(cmd_str);

cmdstr=['5tt2gmwmi -mask_in ' fullfile(ROIdir,'VOF_box_L_resliced.nii.gz') ' ',...
    fullfile(runDir, 'mrtrix', 'dwi_processed_aligned_trilin_noMEC_5tt.mif') ' ',...
    fullfile(ROIdir,'VOF_gmwmi_L.nii.gz') ' -force'];
[status,results] = AFQ_mrtrix_cmd(cmdstr, 0, 1,3);

cmdstr=['5tt2gmwmi -mask_in ' fullfile(ROIdir,'VOF_box_R_resliced.nii.gz') ' ',...
    fullfile(runDir, 'mrtrix', 'dwi_processed_aligned_trilin_noMEC_5tt.mif') ' ',...
    fullfile(ROIdir,'VOF_gmwmi_R.nii.gz') ' -force'];
[status,results] = AFQ_mrtrix_cmd(cmdstr, 0, 1,3);

img=niftiRead(fullfile(ROIdir,'VOF_gmwmi_L.nii.gz'));
load(fullfile(ROIdir,'VOF_box_L.mat'));

imgCoords = find(ceil(img.data));
[I,J,K] = ind2sub(img.dim, imgCoords);
roi.coords  = mrAnatXformCoords(img.qto_xyz, [I,J,K]);

outname='VOF_gmwmi_L.mat';
save(fullfile(ROIdir,outname),'roi','versionNum','coordinateSpace');

img=niftiRead(fullfile(ROIdir,'VOF_gmwmi_R.nii.gz'));
load(fullfile(ROIdir,'VOF_box_R.mat'));

imgCoords = find(ceil(img.data));
[I,J,K] = ind2sub(img.dim, imgCoords);
roi.coords  = mrAnatXformCoords(img.qto_xyz, [I,J,K]);

outname='VOF_gmwmi_R.mat';
save(fullfile(ROIdir,outname),'roi','versionNum','coordinateSpace');

fg_classified = fg2Array(fg_classified);
%
%
% %% Identify VOF and pAF

[L_VOF, R_VOF, L_pAF, R_pAF, L_pAF_vot, R_pAF_vot] = babyAFQ_FindVOF(wholeBrainfgFile,...
    fg_classified(19),fg_classified(20),ROIdir,afqDir,[],[],dt);


fg_classified(23) = L_VOF;
fg_classified(24) = R_VOF;

%pAF
fields = {'coordspace'};
try
    L_pAF = rmfield(L_pAF,fields);
    R_pAF = rmfield(R_pAF,fields);
catch
end

fields = {'type'};
try
    L_pAF = rmfield(L_pAF,fields);
    R_pAF = rmfield(R_pAF,fields);
catch
end

fields = {'fiberNames'};
try
    L_pAF = rmfield(L_pAF,fields);
    R_pAF = rmfield(R_pAF,fields);
catch
end

fields = {'fiberIndex'};
try
    L_pAF = rmfield(L_pAF,fields);
    R_pAF = rmfield(R_pAF,fields);
catch
end


fields = {'coordspace'};
try
    L_pAF_vot = rmfield(L_pAF_vot,fields);
    R_pAF_vot = rmfield(R_pAF_vot,fields);
catch
end

fields = {'type'};
try
    L_pAF_vot = rmfield(L_pAF_vot,fields);
    R_pAF_vot = rmfield(R_pAF_vot,fields);
catch
end

fields = {'fiberNames'};
try
    L_pAF_vot = rmfield(L_pAF_vot,fields);
    R_pAF_vot = rmfield(R_pAF_vot,fields);
catch
end

fields = {'fiberIndex'};
try
    L_pAF_vot = rmfield(L_pAF_vot,fields);
    R_pAF_vot = rmfield(R_pAF_vot,fields);
catch
end


fg_classified(25) = L_pAF;
fg_classified(26) = R_pAF;

% pAF_vot

fg_classified(27) = L_pAF_vot;
fg_classified(28) = R_pAF_vot;

% merge pAF and pAFvot
fg_classified(29) = fgUnion(L_pAF,L_pAF_vot);
fg_classified(30) = fgUnion(R_pAF,R_pAF_vot);

% save file
fgFile_classified = fullfile(afqDir, [fgNameWoExt, '_classified_withBabyAFQ.mat']);
S.fg = fg_classified;
save(fgFile_classified,'-struct','S');

% % save unclassified fibers
fgFile_unclassified = fullfile(afqDir, [fgNameWoExt,'_unclassified_withBabyAFQ.mat']);
S.fg = fg_unclassified;
save(fgFile_unclassified,'-struct','S');

% % save unclassified fibers
fgFile = (fullfile(afqDir, [fgNameWoExt,'_allFibers_babyAFQ.mat']));
S.fg = fg;
save(fgFile,'-struct','S');
clear S;

end

