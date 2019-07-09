function fatRunLifeMRtrix3(fatDir, sessid, runName, fgName, t1_name, Niter, L, force)
% fe = fatRunLife(fatDir, sessid, runName, fgName, Niter, L, force)
% This function run LIFE on the candidate ensemble connectome produced
% from fatRunET.

if nargin < 8, force = false; end
if nargin < 7, L = 360; end % Discretization parameter for encoding
if nargin < 6, Niter = 250; end % Number of iteration for LiFE

% Run LiFE 
%mrtrixFolderParts  = split(csdFile, filesep);
% Obtain the session name. This is usually the zip name if it has not
% been edited. 
sessionDir = fullfile(fatDir,sessid);
dt6Dir=fullfile(sessionDir,'/96dir_run1/fw_afq_ET_ACT_LiFE_3.0.2_lmax8/dti96trilin')
MRtrixDir=fullfile(sessionDir,'/96dir_run1/fw_afq_ET_ACT_LiFE_3.0.2_lmax8/dti96trilin/mrtrix')
fiberDir=fullfile(sessionDir,'/96dir_run1/fw_afq_ET_ACT_LiFE_3.0.2_lmax8/dti96trilin/fibers')

lifedir    = fullfile(sessionDir, 'dti96trilin/LiFE');

config.dtiinit             = fatDir;
config.track               = fullfile(fiberDir,fgName);
config.life_discretization = 360;
config.num_iterations      = 500;

% Change dir to LIFEDIR so that it writes everything there
if ~exist(lifedir); mkdir(lifedir); end;
cd(lifedir)

disp('loading dt6.mat')
disp(['Looking for file: ' fullfile(dt6Dir, 'dt6.mat')])
dt6 = load(fullfile(dt6Dir, 'dt6.mat'))
[~,NAME,EXT] = fileparts(dt6.files.alignedDwRaw);
aligned_dwi = fullfile(MRtrixDir, [NAME,EXT])
 %fg      = fgRead(fullfile(fiberDir,fgName));
 
[fe, out] = life(config, aligned_dwi);

out.stats.input_tracks = length(fe.fg.fibers);
out.stats.non0_tracks = length(find(fe.life.fit.weights > 0));
fprintf('number of original tracks	: %d\n', out.stats.input_tracks);
fprintf('number of non-0 weight tracks	: %d (%f)\n', out.stats.non0_tracks, out.stats.non0_tracks / out.stats.input_tracks*100);

% This is what we want to pass around
fg_LiFE = out.life.fg;
% And I think I would need to write and substitute the non cleaned ET tractogram tck with the new one...
% Write the tck and mat files
tck_file_life = fullfile(fiberDir,'WholeBrainFGAtlas_LiFE.tck');
fgWrite(fg_LiFE, tck_file_life, 'tck');
% fg = fgRead(tck_file_life);

dtiWriteFiberGroup(fg_LiFE, fullfile(fiberDir, 'WholeBrainFGAtlas_LiFE.mat'));
end

