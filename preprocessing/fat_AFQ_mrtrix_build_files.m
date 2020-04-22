function files = fat_AFQ_mrtrix_build_files(fname_trunk,compute5tt, multishell)
% Builds a structure with the names of the files that the MRtrix commands
% will generate and need.
%
% files = mrtrix_build_files(fname_trunk,lmax)
%
% Franco Pestilli, Ariel Rokem, Bob Dougherty Stanford University
% GLU July.2016 added the T1 and tt5 file types


% Convert the raw dwi data to the mrtrix format:
files.dwi = strcat(fname_trunk,'_dwi.mif');

% This file contains both bvecs and bvals, as per convention of mrtrix
files.b     = strcat(fname_trunk, '.b');

% Extract the bo
files.b0 = strcat(fname_trunk,'_b0.mif');

% Convert the brain mask from mrDiffusion into a .mif file:
files.brainmask = strcat(fname_trunk,'_brainmask.mif');
files.brainmask_dilated    = strcat(fname_trunk, '_brainmask_dilated.mif');
files.brainmask_eroded    = strcat(fname_trunk, '_brainmask_eroded.mif');

% Generate diffusion tensors:
files.dt = strcat(fname_trunk, '_dt.mif');

% Get the FA from the diffusion tensor estimates:
files.fa = strcat(fname_trunk, '_fa.mif');

% Generate the eigenvectors, weighted by FA:
files.ev = strcat(fname_trunk, '_ev.mif');

% If we have multishell data we will want the FA calculated with the shell
% closest to b1000
if multishell>0
    files.dwiSS = strcat(fname_trunk,'_dwiSS.mif');
    files.bSS   = strcat(fname_trunk, '.bSS');
end

% Estimate the response function of single fibers:
files.sf = strcat(fname_trunk, '_sf.mif');
files.response = strcat(fname_trunk, '_response.txt');

% Create a white-matter mask, tracktography will act only in here.
files.wmMask    = strcat(fname_trunk, '_wmMask.mif');
files.wmMask_dilated    = strcat(fname_trunk, '_wmMask_dilated.mif');

% Compute the CSD estimates:
%files.csd = strcat(fname_trunk, sprintf('_csd_lmax%i.mif',lmax));

% Create tissue type segmentation to be used in multishell or ACT

if compute5tt>0 || multishell>0
    files.tt5 = strcat(fname_trunk, '_5tt.mif');
    files.gmwmi = strcat(fname_trunk, '_5tt_gmwmi.mif');
end


% Create per tissue type response file
files.wmResponse = strcat(fname_trunk, '_wmResponse.txt');
files.gmResponse = strcat(fname_trunk, '_gmResponse.txt');
files.csfResponse = strcat(fname_trunk, '_csfResponse.txt');
% Compute the CSD estimates:
files.wmCsd  = strcat(fname_trunk, '_wmCsd_lmax_auto.mif');

if multishell>0
    files.gmCsd  = strcat(fname_trunk, '_gmCsd_lmax_auto.mif');
end

files.csfCsd = strcat(fname_trunk, '_csfCsd_lmax_auto.mif');
% RGB tissue signal contribution maps
files.vf = strcat(fname_trunk, '_vf.mif');
% dhollander voxel selection for QA
files.voxels = strcat(fname_trunk, '_voxels.mif');
end

