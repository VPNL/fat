
function [DIFF_FULLY_PROCESSED] = fatPreProcMRtrix3NiiWithAdvancedMotion_multishell(fatDir, sessid, runName)
% This code is based on https://github.com/vistalab/RTP-prep. It was
% adujsted so that preprco can be ru locally in matlab. This code does not
% include reverse phase encoding images, as this was not applicable in my
% data
%this code has many dependencies, including fsl (I used version 6.02. with
%cuda 9.1)

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

bval='dwiMultiShell.bval';
bvec='dwiMultiShell.bvec';

OutDir=fullfile(fatDir, sessid, runName);
cd(OutDir);

%% Denoise

disp('Performing PCA denoising...');
input = 'raw/dwiMultiShell.nii.gz';
output = 'dwiMultiShell_denoise.nii.gz';
noise = 'noiseMS.nii.gz';
fatDenoise(fatDir,sessid,runName,input,output,noise)


input = 'raw/dwiRevPhase.nii.gz';
output = 'dwiRevPhase_denoise.nii.gz';
noise = 'noiseRP.nii.gz';
fatDenoise(fatDir,sessid,runName,input,output,noise)

%% Eddy 
disp('Performing FSL eddy correction, this will take a long time...');
    

input_ms = 'dwiMultiShell_denoise.nii.gz';
input_rp = 'dwiRevPhase_denoise.nii.gz';
output = 'dwiMultiShell_denoise_unwarped_eddy.nii.gz';
fatEddy_multiShell(fatDir,sessid,runName,input_ms,input_rp,bvec,bval,output)

fatPlotMotion('dwiMultiShell_denoise_unwarped_eddy.eddy_movement_over_time','On');


%% Bias Correction 
disp('Computing bias correction with ANTs on dwi data...');
input = 'dwiMultiShell_denoise_unwarped_eddy.nii.gz';
mask='topup_b0_out_brain_mask.nii.gz';

output = 'dwiMultiShell_denoise_unwarped_eddy_bias.nii.gz';

fatBiasCorrect(fatDir,sessid,runName,input,mask,bvec,bval,output)
    
%% Create final files 
disp('Creating fully preprocessed dwi files in native space...');
diffFinal = fullfile(fatDir, sessid, runName, 'dwi_processed.nii.gz');
cmd_str = ['cp ' output ' ' diffFinal];
system(cmd_str)

bvec = fullfile(fatDir,sessid,runName,'raw',bvec);
bval = fullfile(fatDir,sessid,runName,'raw',bval);

disp('Creating dwi space b0 reference images...');
cmd_str = ['dwiextract dwi_processed.nii.gz -fslgrad ' bvec ' ' bval...
    ' - -bzero -quiet | mrmath - mean dwi_processed_b0.nii.gz -axis 3 -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);

cmd_str = ['cp ' bvec ' ' 'dwi_processed.bvec'];
system(cmd_str)

cmd_str = ['cp ' bval ' ' 'dwi_processed.bval'];
system(cmd_str)

disp('Cleaning up working directory...')
!rm -rf ./tmp;
end

