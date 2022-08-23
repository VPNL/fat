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
files.dtWithDki = strcat(fname_trunk, '_dt_dki.mif');
files.dki = strcat(fname_trunk, '_dki.mif');


% Get the FA from the diffusion tensor estimates:
files.fa = strcat(fname_trunk, '_fa.mif');
files.faWithDki = strcat(fname_trunk, '_fa_dki.mif');

% Get the MD from the diffusion tensor estimates:
files.md = strcat(fname_trunk, '_md.mif');
files.mdWithDki = strcat(fname_trunk, '_md_dki.mif');

% Get the AD from the diffusion tensor estimates:
files.ad = strcat(fname_trunk, '_ad.mif');
files.adWithDki = strcat(fname_trunk, '_ad_dki.mif');

% Get the RD from the diffusion tensor estimates:
files.rd = strcat(fname_trunk, '_rd.mif');
files.rdWithDki = strcat(fname_trunk, '_rd_dki.mif');

% Generate the eigenvectors, weighted by FA:
files.ev = strcat(fname_trunk, '_ev.mif');
files.evWithDki = strcat(fname_trunk, '_ev_dki.mif');

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
% Create per tissue type response file with msmst_5tt
files.wmResponseMSMT5tt = strcat(fname_trunk, '_msmt_5tt_wmResponse.txt');
files.gmResponseMSMT5tt = strcat(fname_trunk, '_msmt_5tt_gmResponse.txt');
files.csfResponseMSMT5tt = strcat(fname_trunk, '_msmt_5tt_csfResponse.txt');
% Create per tissue type response file with dhollander
files.wmResponseDhollander = strcat(fname_trunk, '_dhollander_wmResponse.txt');
files.gmResponseDhollander = strcat(fname_trunk, '_dhollander_gmResponse.txt');
files.csfResponseDhollander = strcat(fname_trunk, '_dhollander_csfResponse.txt');
% Create response file with tournier
files.wmResponseTournier = strcat(fname_trunk, '_tournier_wmResponse.txt');

% Compute the CSD estimates from msmt_5tt:
files.wmCsdMSMT5tt  = strcat(fname_trunk, '_msmt_5tt_wmCsd.mif');
files.csfCsdMSMT5tt = strcat(fname_trunk, '_msmt_5tt_csfCsd.mif');

% Compute the CSD estimates from a mixture of dhollander and tournier as in Pietsch et al 2019:
files.wmCsdMSMTTournier  = strcat(fname_trunk, '_msmt_tournier_wmCsd.mif');
files.wmCsdMSMTDhollander  = strcat(fname_trunk, '_msmt_dhollander_wmCsd.mif');
files.csfCsdMSMTTournier = strcat(fname_trunk, '_msmt_dhollander_tournier_csfCsd.mif');
files.csfCsdMSMTDhollander = strcat(fname_trunk, '_msmt_dhollander_csfCsd.mif');
files.gmCsdMSMTTournier  = strcat(fname_trunk, '_msmt_tournier_gmCsd.mif');
files.gmCsdMSMTDhollander  = strcat(fname_trunk, '_msmt_dhollander_gmCsd.mif');

% Compute the CSD estimates from msmt_5tt:
files.wmCsdMSMT5ttNorm  = strcat(fname_trunk, '_msmt_5tt_wmCsd_norm.mif');
files.csfCsdMSMT5ttNorm = strcat(fname_trunk, '_msmt_5tt_csfCsd_norm.mif');

% Compute the CSD estimates from a mixture of dhollander and tournier as in Pietsch et al 2019:

files.wmCsdMSMTDhollanderNorm  = strcat(fname_trunk, '_msmt_dhollander_wmCsd_norm.mif');
files.csfCsdMSMTDhollanderNorm = strcat(fname_trunk, '_msmt_dhollander_csfCsd_norm.mif');

files.wmCsdMSMTTournierNorm  = strcat(fname_trunk, '_msmt_tournier_wmCsd_norm.mif');
files.csfCsdMSMTTournierNorm  = strcat(fname_trunk, '_msmt_tournier_csfCsd_norm.mif');

% RGB tissue signal contribution maps
files.vfMSMT5tt = strcat(fname_trunk, '_msmt_5tt_vf.mif');
files.vfMSMTDhollander = strcat(fname_trunk, '_msmst_dhollander_vf.mif');
files.vfMSMTTournier = strcat(fname_trunk, '_msmst_tournier_vf.mif');

% dhollander voxel selection for QA
files.voxelsMSMT5tt = strcat(fname_trunk, '_voxelsMSMT5tt.mif');
files.voxelsDhollander = strcat(fname_trunk, '_voxelsDhollander.mif');
files.voxelsTournier = strcat(fname_trunk, '_voxelsTournier.mif');
end

