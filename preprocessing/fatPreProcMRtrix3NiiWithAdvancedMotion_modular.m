
function [DIFF_FULLY_PROCESSED] = fatPreProcMRtrix3NiiWithAdvancedMotion_modular(fatDir, sessid, runName,revPhase,doDenoise,doGibbs,doEddy,doBiasCorr,doRicn)
% This code is based on https://github.com/vistalab/RTP-prep. It was
% adujsted so that preprco can be ru locally in matlab. This code does not
% include reverse phase encoding images, as this was not applicable in my
% data
%this code has many dependencies, including fsl (I used version 6.02. with
%cuda 9.1)

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

% get rid of later 
% if revPhase==0
%     diff=fullfile(fatDir, sessid, runName, 'raw/run1.nii.gz')
%     diffName='dwi';
%     
%     bval=fullfile(fatDir, sessid, runName, 'raw/run1.bval')
%     bvec=fullfile(fatDir, sessid, runName, 'raw/run1.bvec')
%     
% else
%     diffMS=fullfile(fatDir, sessid, runName, 'raw/dwiMultiShell.nii.gz')
%     diffMSName='dwiMultiShell';
%     
%     bvalMS=fullfile(fatDir, sessid, runName, 'raw/dwiMultiShell.bval')
%     bvecMS=fullfile(fatDir, sessid, runName, 'raw/dwiMultiShell.bvec')
%     
%     diffRP=fullfile(fatDir, sessid, runName, 'raw/dwiRevPhase.nii.gz')
%     diffRPName='dwiRevPhase';
%     
%     bvalRP=fullfile(fatDir, sessid, runName, 'raw/dwiRevPhase.bval')
%     bvecRP=fullfile(fatDir, sessid, runName, 'raw/dwiRevPhase.bvec')
% end

OutDir=fullfile(fatDir, sessid, runName);
cd(OutDir);

if doDenoise>0 || doRicn>0 %Ricn is not valid without denoise
    disp('Performing PCA denoising...');
    
    if revPhase==0
        input = 'raw/run1.nii.gz';
        output = 'dwi_denoise.nii.gz';
        fatDenoise(fatDir,sessid,runName,input,output)
       
        
    else
        input = 'raw/dwiMultiShell.nii.gz';
        output = 'dwiMultiShell_denoise.nii.gz';
        fatDenoise(fatDir,sessid,runName,input,output)
        
        
        input = 'raw/dwiRevPhase.nii.gz';
        output = 'dwiRevPhase_denoise.nii.gz';
        fatDenoise(fatDir,sessid,runName,input,output)

    end
end

if doGibbs>0 %do not use this when muxing
    disp('Performing Gibbs ringing correction..');
    
    if revPhase==0
        input = 'dwi_denoise.nii.gz';
        output = 'dwi_denoise_gibbs.nii.gz';
        fatGibbs(fatDir,sessid,runName,input,output)
    else
        input = 'dwiMultiShell_denoise.nii.gz';
        output = 'dwiMultiShell_denoise_gibbs.nii.gz';
        fatGibbs(fatDir,sessid,runName,input,output)
        
        input = 'dwiRevPhase_denoise.nii.gz';
        output = 'dwiRevPhase_denoise_gibbs.nii.gz';
        fatGibbs(fatDir,sessid,runName,input,output)
    end
end


if doEddy>0
    disp('Performing FSL eddy correction, this will take a long time...');
    
    if revPhase==0
        input = 'dwi_denoise_gibbs.nii.gz';
        output = 'dwi_denoise_gibbs_eddy.nii.gz';
        bvec = 'run1.bvec';
        bval = 'run1.bval';
        fatEddy_singleShell(fatDir,sessid,runName,input,bvec,bval,output)
        
        fatPlotMotion('eddy_movement_over_time','On');
        
    else
        input_ms = 'dwiMultiShell_denoise.nii.gz';
        input_rp = 'dwiRevPhase_denoise.nii.gz';
        bvec = 'dwiMultiShell.bvec';
        bval = 'dwiMultiShell.bval';
        output = 'dwiMultiShell_denoise_unwarped_eddy.nii.gz';
        fatEddy_multiShell(fatDir,sessid,runName,input_ms,input_rp,bvec,bval,output)
        
        MASK='topup_b0_out_brain_mask.nii.gz';
        
        fatPlotMotion('dwiMultiShell_denoise_unwarped_eddy.eddy_movement_over_time'),'On');
       
    end
end

% RESUME HERE!
if doBiasCorr>0
    disp('Computing bias correction with ANTs on dwi data...');
    diffBias=fullfile(fatDir, sessid, runName, strcat(diffName, '_bias.nii.gz'));
    
    fatBiasCorrect(fatDir,sessid,runName,input,mask,bvec,bval,output)
    
    if revPhase>0
        bvec=bvecMS;
        bval=bvalMS;
    end
    cmd_str = ['dwibiascorrect -ants ' strcat(diffName, '.nii.gz') ' ' diffBias ' -mask ' MASK ' -fslgrad ' bvec ' ' bval ' -force -quiet']
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
     
    if ~exist(strcat(diffName, '_bias.nii.gz'))
        warning('Dwibiascorrect failed when using the -ants option. Using -fsl option instead.');
        cmd_str = ['dwibiascorrect -mask ' MASK ' -fsl '  strcat(diffName,'.nii.gz') ' -fslgrad ' bvec ' ' bval ' ' diffBias ' -force -tempdir ./tmp -quiet'];
        [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    end
    
        warning('Dwibiascorrect is using the -fsl option. This is not recommended, by the ANTS option fails after advanced motion correction.');
    cmd_str = ['dwibiascorrect fsl ' strcat(diffName, '.nii.gz') ' ' diffBias ' -mask ' MASK ' -fslgrad ' bvec ' ' bval ' -force -quiet'];
        [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
     diffName=strcat(diffName, '_bias');
end

if doRicn>0 && revPhase==0
    disp('Perform Rician background noise removal...');
    diffRicn=fullfile(fatDir, sessid, runName, strcat(diffName, '_ricn.nii.gz'));
    cmd_str = ['mrcalc noise.nii.gz -finite noise.nii.gz 0 -if lowbnoisemap.nii.gz  -quiet'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    cmd_str = ['mrcalc ' strcat(diffName, '.nii.gz') ' 2 -pow lowbnoisemap.nii.gz 2 -pow -sub -abs -sqrt - -quiet | mrcalc - -finite - 0 -if tmp.nii.gz -quiet'];
    system(cmd_str)
    cmd_str = ['mrconvert tmp.nii.gz -fslgrad ' bvec ' ' bval ' ' diffRicn ' -quiet'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    cmd_str = ['rm -f tmp.mif tmp.b'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    diffName=strcat(diffName, '_ricn');
else
    disp('No Ricn Denoising applied. You either chose not to use Ricn or you privided revPhase encoding for which Ricn is not supported.')
end

disp('Creating fully preprocessed dwi files in native space...');
diffFinal = fullfile(fatDir, sessid, runName, 'dwi_processed.nii.gz');
cmd_str = ['cp ' strcat(diffName,'.nii.gz') ' ' diffFinal];
system(cmd_str)

disp('Creating dwi space b0 reference images...');
cmd_str = ['dwiextract dwi_processed.nii.gz -fslgrad ' bvec ' ' bval ' - -bzero -quiet | mrmath - mean dwi_processed_b0.nii.gz -axis 3 -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);

cmd_str = ['cp ' bvec ' ' 'dwi_processed.bvec'];
system(cmd_str)

cmd_str = ['cp ' bval ' ' 'dwi_processed.bval'];
system(cmd_str)

disp('Cleaning up working directory...')
!rm -rf ./tmp;
end

