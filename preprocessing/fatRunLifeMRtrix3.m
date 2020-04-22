function fgAfterLife=fatRunLifeMRtrix3(fatDir, sessid, runName, fgName, Niter, L)
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
sessionDir = fullfile(fatDir,sessid,runName);
cd(sessionDir);
        subdir=dir('*trilin')
        runDir = fullfile(sessionDir,subdir.name);
MRtrixDir=fullfile(runDir,'mrtrix')
fiberDir=fullfile(runDir,'fibers')

lifedir    = fullfile(runDir, 'LiFE');

config.dtiinit             = fatDir;
config.track               = fullfile(fiberDir,fgName);
config.life_discretization = L;
config.num_iterations      = Niter;

% Change dir to LIFEDIR so that it writes everything there
if ~exist(lifedir); mkdir(lifedir); end;
cd(lifedir)

disp('loading dt6.mat')
disp(['Looking for file: ' fullfile(runDir, 'dt6.mat')])
dt6 = load(fullfile(runDir, 'dt6.mat'))
[~,NAME,EXT] = fileparts(dt6.files.alignedDwRaw);
aligned_dwi = fullfile(sessionDir, [NAME,EXT]);
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
tck_file_life = fullfile(fiberDir,'WholeBrainFG_LiFE.tck');
fgWrite(fg_LiFE, tck_file_life, 'tck');
% fg = fgRead(tck_file_life);

fgAfterLife='WholeBrainFG_LiFE.mat';
dtiWriteFiberGroup(fg_LiFE, fullfile(fiberDir, fgAfterLife));
end

