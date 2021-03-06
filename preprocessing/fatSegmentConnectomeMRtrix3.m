function fgFile=fatSegmentConnectomeMRtrix3(fatDir, anatDir, anatid, sessid, runName, fgName, computeRoi)
% fatSegmentConnectome(fatDir, sessid, runName, fgName)
% fgName: full name of fg including path and postfix
% foi, a vector to indicate fiber of interest
% This function will run AFQ on a % given list of subjects and runs.
if nargin < 7, computeRoi = true; end
if nargin < 6, fgName = 'lmax_curv1_post_life_et_it500.mat'; end

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
[fg_classified,fg_unclassified,classification,fg] = AFQ_SegmentFiberGroups(dt, wholebrainFG,...
    'MNI_JHU_tracts_prob.nii.gz',useRoiBasedApproach);
clear wholebrainFG

fg_classified = fg2Array(fg_classified);


%% Identify VOF and pAF
fsROIdir = fullfile(anatDir,anatid,'fsROI');
[L_VOF, R_VOF, L_pAF, R_pAF, L_pAF_vot, R_pAF_vot] = AFQ_FindVOF(wholeBrainfgFile,...
   fg_classified(19),fg_classified(20),fsROIdir{1},afqDir,[],[],dt);

%[L_VOF, R_VOF, L_pAF, R_pAF, L_pAF_vot, R_pAF_vot] = AFQ_FindVOF(wholeBrainfgFile,...
%    fg_classified(19),fg_classified(20),fsROIdir,afqDir,[],[],dt);

fg_classified(21) = L_VOF;

try
    fg_classified(22) = R_VOF;
catch
    fg_classified(22) =L_VOF;
    fg_classified(22).name ='R_VOF';
    fg_classified(22).fibers =[];
end
% pAF
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


fg_classified(23) = L_pAF;
try
    fg_classified(24) = R_pAF;
catch
    fg_classified(24) = L_pAF;
    fg_classified(24).name ='R_pAF';
    fg_classified(24).fibers =[];
end


% pAF_vot

fg_classified(25) = L_pAF_vot;
try
    fg_classified(26) = R_pAF_vot;
catch
    fg_classified(26) = L_pAF_vot;
    fg_classified(26).name ='R_pAF_vot';
    fg_classified(26).fibers =[];
end

% merge pAF and pAFvot
fg_classified(27) = fgUnion(L_pAF,L_pAF_vot);
try
fg_classified(28) = fgUnion(R_pAF,R_pAF_vot);
catch
    fg_classified(26) = L_pAF_vot;
    fg_classified(26).name ='R_Arcuate_Posterior_R_posteriorArcuate_vot';
    fg_classified(26).fibers =[];
end

% save file
fgFile_classified = fullfile(afqDir, [fgNameWoExt, '_classified.mat']);
S.fg = fg_classified;
save(fgFile_classified,'-struct','S');

% save unclassified fibers 
fgFile_unclassified = fullfile(afqDir, [fgNameWoExt,'_unclassified.mat']);
S.fg = fg_unclassified;
save(fgFile_unclassified,'-struct','S');
 
clear S;

end

