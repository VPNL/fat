function fatConvert2matMRtrix3(fatDir, sessid, runName, fgName)
% fe = fatRunLife(fatDir, sessid, runName, fgName, Niter, L, force)
% This function run LIFE on the candidate ensemble connectome produced
% from fatRunET.

if nargin < 8, force = false; end
if nargin < 7, L = 360; end % Discretization parameter for encoding
if nargin < 6, Niter = 250; end % Number of iteration for LiFE

% Write the conenctome to mat
fgFile =fullfile(fatDir,sessid,runName,'/dti96trilin/mrtrix/',fgName)
fg      = fgRead(fgFile);
name=strsplit(fgName,'.');
dtiWriteFiberGroup(fg, fullfile(fatDir,sessid,runName,'/dti96trilin/fibers/', strcat(name{1}, '.mat')));
end

