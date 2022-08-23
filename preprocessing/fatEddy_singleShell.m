function fatEddy_singleShell(fatDir,sessid,runName,input,bvec,bval,output)

%   fatEddy_singleShell: Takes in DWI data and performs eddy current correction
%   inputs:
%       fatDir = data directory 
%       sessid = subject folder name 
%       runName = run folder name 
%       bvec = input bvec file name
%       bval = input bval file name
%       input = input dwi file name 
%       output = output denoised file name

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

input = fullfile(fatDir,sessid,runName,input);
output = fullfile(fatDir,sessid,runName,output);
bvec = fullfile(fatDir,sessid,runName,'raw',bvec);
bval = fullfile(fatDir,sessid,runName,'raw',bval);


% Create B0 reference image

cmd_str = ['dwiextract ' input ' -fslgrad ' bvec ' ' bval ...
    ' - -bzero -quiet | mrmath - mean dwi_b0.nii.gz -axis 3 -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);

% Create processing mask

cmd_str=['dwi2mask ' input ' -fslgrad ' bvec ' ' bval ...
    ' dwi_b0_brain_mask.nii.gz -force -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);


MASK=fullfile(fatDir, sessid, runName, 'dwi_b0_brain_mask.nii.gz');
cmd_str = ['dwipreproc -eddy_options --mporder=3'...
    ' --slspec=./dwiSlSpec.txt'...
    ' --mask=' MASK ...
    ' --repol'...
    ' --data_is_shelled'...
    ' --slm=linear'...
    ' --cnr_maps'...
    ' --residuals'...
    ' -rpe_none'...
    ' -pe_dir PA'...
    ' ' input...
    ' -fslgrad ' bvec ' ' bval...
    ' ' output ...
    ' -eddyqc_text'...
    ' ' OutDir ...
    ' -tempdir ./tmp -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);

% if the above step fails, use mriinfor to ensure that you slspec
% match your number of slices. Sometimes, even with the same
% protocol, the number of slices can vary
%
% cmd_str=['mrinfo ' strcat(diffName,'.nii.gz') ' -size']
% [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
%
fatPlotMotion('eddy_movement_over_time','On');
end 
       