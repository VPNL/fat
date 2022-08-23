
function [DIFF_FULLY_PROCESSED] = fatPreProcMRtrix3NiiWithAdvancedMotion_singleshell(fatDir, sessid, runName,revPhase,doDenoise,doGibbs,doEddy,doBiasCorr,doRicn)
% This code is based on https://github.com/vistalab/RTP-prep. It was
% adujsted so that preprco can be ru locally in matlab. This code does not
% include reverse phase encoding images, as this was not applicable in my
% data
%this code has many dependencies, including fsl (I used version 6.02. with
%cuda 9.1)

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

  
bval='run1.bval';
bvec='run1.bvec';

OutDir=fullfile(fatDir, sessid, runName);
cd(OutDir);

%% Denoise
disp('Performing PCA denoising...');

input = 'raw/run1.nii.gz';
output = 'dwi_denoise.nii.gz';
noise = 'noise.nii.gz';
fatDenoise(fatDir,sessid,runName,input,output,noise)

        
 %% Gibbs

 disp('Performing Gibbs ringing correction..');

 input = 'dwi_denoise.nii.gz';
 output = 'dwi_denoise_gibbs.nii.gz';
 fatGibbs(fatDir,sessid,runName,input,output)
    
 %% Eddy

 disp('Performing FSL eddy correction, this will take a long time...');

 input = 'dwi_denoise_gibbs.nii.gz';
 output = 'dwi_denoise_gibbs_eddy.nii.gz';
 bvec = 'run1.bvec';
 bval = 'run1.bval';
 fatEddy_singleShell(fatDir,sessid,runName,input,bvec,bval,output)

 fatPlotMotion('eddy_movement_over_time','On');

%% Bias Correction

disp('Computing bias correction with ANTs on dwi data...');
input = 'dwi_denoise_gibbs_eddy.nii.gz';
mask = 'dwi_b0_brain_mask.nii.gz';
output = 'dwi_denoise_gibbs_eddy_bias.nii.gz';
fatBiasCorrect(fatDir,sessid,runName,input,mask,bvec,bval,output)

%% Rician

disp('Perform Rician background noise removal...');
input = 'dwi_denoise_gibbs_eddy_bias.nii.gz';
output = 'dwi_denoise_gibbs_eddy_bias_ricn.nii.gz';
fatRicn(fatDir,sessid,runName,input,output,bvec,bval)
   
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

