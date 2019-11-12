
function [DIFF_FULLY_PROCESSED] = babyFatPreProcMRtrix3(fatDir, sessid, runName,revPhase,doDenoise,doGibbs,doEddy,doBiasCorr,doRicn)
% This code is based on https://github.com/vistalab/RTP-prep. It was
% adujsted so that preprco can be ru locally in matlab. This code does not
% include reverse phase encoding images, as this was not applicable in my
% data
%this code has many dependencies, including fsl (I used version 6.02. with
%cuda 9.1)

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

if revPhase==0
diff=fullfile(fatDir, sessid, runName, 'raw/dwi.nii.gz')
diffName='dwi';

BVAL=fullfile(fatDir, sessid, runName, 'raw/dwi.bval')
BVEC=fullfile(fatDir, sessid, runName, 'raw/dwi.bvec')

else
diffMS=fullfile(fatDir, sessid, runName, 'raw/dwiMultiShell.nii.gz')
diffMSName='dwiMultiShell';

bvalMS=fullfile(fatDir, sessid, runName, 'raw/dwiMultiShell.bval')
bvecMS=fullfile(fatDir, sessid, runName, 'raw/dwiMultiShell.bvec')   

diffRP=fullfile(fatDir, sessid, runName, 'raw/dwiRevPhase.nii.gz')
diffRPName='dwiRevPhase';

bvalRP=fullfile(fatDir, sessid, runName, 'raw/dwiRevPhase.bval')
bvecRP=fullfile(fatDir, sessid, runName, 'raw/dwiRevPhase.bvec')
end  
    
OutDir=fullfile(fatDir, sessid, runName);
cd(OutDir);

if doDenoise>0 || doRicn>0 %Ricn is not valid without denoise
disp('Performing PCA denoising...');

if revPhase==0     
diffDenoise=fullfile(fatDir, sessid, runName, strcat(diffName, '_denoise.nii.gz'));
cmd_str = ['dwidenoise -extent 5,5,5 -noise noise.nii.gz ' diff  ' ' diffDenoise ' -force -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffName=strcat(diffName, '_denoise.nii.gz');

else
diffMS_Denoise=fullfile(fatDir, sessid, runName, strcat(diffMSName, '_denoise.nii.gz'));
cmd_str = ['dwidenoise -extent 5,5,5 -noise noiseMS.nii.gz ' diffMS ' ' diffMS_Denoise ' -force -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffMSName=strcat(diffMSName, '_denoise');

diffRP_Denoise=fullfile(fatDir, sessid, runName, strcat(diffRPName, '_denoise.nii.gz'));
cmd_str = ['dwidenoise -extent 5,5,5 -noise noiseRP.nii.gz ' diffRP  ' ' diffRP_Denoise ' -force -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffRPName=strcat(diffRPName, '_denoise');
end
end

if doGibbs>0 %do not use this when muxing
disp('Performing Gibbs ringing correction..');

if revPhase==0
diffGibbs=fullfile(fatDir, sessid, runName, strcat(diffName, '_gibbs.nii.gz'));
cmd_str = ['mrdegibbs -nshifts 20 -minW 1 -maxW 3 ' diffName ' ' diffGibbs ' -quiet -force'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffName=strcat(diffName, '_gibbs');
else
diffMS_Gibbs=fullfile(fatDir, sessid, runName, strcat(diffMSName, '_gibbs.nii.gz'));
cmd_str = ['mrdegibbs -nshifts 20 -minW 1 -maxW 3 ' diffMSName ' ' diffMS_Gibbs ' -quiet -force'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffMSName=strcat(diffMSName, '_gibbs');

diffRP_Gibbs=fullfile(fatDir, sessid, runName, strcat(diffRPName, '_gibbs.nii.gz'));
cmd_str = ['mrdegibbs -nshifts 20 -minW 1 -maxW 3 ' diffRPName ' ' diffRP_Gibbs ' -quiet -force'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffRPName=strcat(diffRPName, '_gibbs');
end
end


if doEddy>0
disp('Performing FSL eddy correction, this will take a long time...');

if revPhase==0
    
disp('Creating dwi space b0 reference images...');
cmd_str = ['dwiextract ' strcat(diffName,'nii.gz') ' - -bzero -quiet | mrmath - mean dwi_b0.nii.gz -axis 3 -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
MASK=fullfile(OutDir,'b0_out_brain_mask.nii.gz');
cmd_str = ['dwi2mask dwi_b0.nii.gz ' MASK ' -force -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    
diffEddy=fullfile(fatDir, sessid, runName, strcat(diffName, '_eddy.nii.gz'));
cmd_str = ['dwipreproc -eddy_options " --mask=b0_out_brain_mask --repol --data_is_shelled --slm=linear" -rpe_none -pe_dir PA ' diffName ' ' diffEddy ' -eddyqc_text ' OutDir ' -tempdir ./tmp -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffName=strcat(diffName, '_eddy');

else
    
    %chenck that we are workinh with an even number of slices
    
    cmd_str=['mrinfo ' strcat(diffMSName,'.nii.gz') ' -size']
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    imageSize=str2num(results);
    
    if rem(imageSize(3),2)>0
    cmdstr=['fslroi ' diffMSName ' ' strcat(diffMSName, '_even') ' 0 -1 0 -1 0 ' num2str(imageSize(3)-1)]
    system(cmdstr) 
    cmdstr=['fslroi ' diffRPName ' ' strcat(diffRPName, '_even') ' 0 -1 0 -1 0 ' num2str(imageSize(3)-1)]
    system(cmdstr) 
    else
    cmdstr=['fslroi ' diffMSName ' ' strcat(diffMSName, '_even') ' 0 -1 0 -1 0 ' num2str(imageSize(3))]
    system(cmdstr) 
    cmdstr=['fslroi ' diffRPName ' ' strcat(diffRPName, '_even') ' 0 -1 0 -1 0 ' num2str(imageSize(3))]
    system(cmdstr) 
    end
    
    
%Creating merged b0 reference image for topup

   cmdstr=['fslroi ' strcat(diffMSName, '_even') ' ' strcat(diffMSName, '_firstb0') ' 0 1']
   system(cmdstr)
   cmdstr=['fslroi ' strcat(diffRPName, '_even') ' ' strcat(diffRPName, '_firstb0') ' 0 1']
   system(cmdstr)
   
   cmdstr=['fslmerge -t dwiConcat_firstb0s ' strcat(diffMSName, '_firstb0') ' ' strcat(diffRPName, '_firstb0')]
   system(cmdstr)
   
   cmdstr=['topup --imain=dwiConcat_firstb0s --datain=acq_params.txt --config=b02b0.cnf --out=topup --iout=topup_b0_out']
   system(cmdstr)
   
   cmdstr=['fslmaths topup_b0_out -Tmean topup_b0_out']
   system(cmdstr)
   
   cmdstr=['bet topup_b0_out topup_b0_out_brain -m']
   system(cmdstr)
   
   cmdstr=['eddy_cuda9.1 --imain=' strcat(diffMSName, '_even') ' --mask=topup_b0_out_brain_mask --acqp=acq_params.txt --index=index.txt',... 
   ' --bvecs=' bvecMS ' --bvals=' bvalMS ' --topup=topup --out=' strcat(diffMSName, '_unwarped_eddy') ' --repol --data_is_shelled']
   system(cmdstr)
   
   diffName=strcat(diffMSName, '_unwarped_eddy');
   MASK='topup_b0_out_brain_mask.nii.gz'
   
   % in case you want to use topup outside of eddy, not sure why you would
   % though
%    cmdstr=['applytopup --imain=' diffMSNameNoExt{1} ' --inindex=1 --method=jac --datain=acq_params.txt --topup=topup --out=' strcat(diffRPNameNoExt{1}, '_topup')]
%    system(cmdstr)
end
end

if doBiasCorr>0
disp('Computing bias correction with ANTs on dwi data...');
diffBias=fullfile(fatDir, sessid, runName, strcat(diffName, '_bias.nii.gz'));
cmd_str = ['dwibiascorrect -mask ' MASK ' -ants '  strcat(diffName,'.nii.gz') ' -fslgrad ' bvecMS ' ' bvalMS ' ' diffBias ' -tempdir ./tmp -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
diffName=strcat(diffName, '_bias');
end

if doRicn>0 && revPhase==0
    disp('Perform Rician background noise removal...');
    diffRicn=fullfile(fatDir, sessid, runName, strcat(diffName, '_ricn.nii.gz'));
    cmd_str = ['mrinfo ' strcat(diffName,'.nii.gz') ' -export_grad_mrtrix tmp.b'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    cmd_str = ['mrcalc noise.mif -finite noise.mif 0 -if lowbnoisemap.mif  -quiet'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    cmd_str = ['mrcalc ' DIFF_MRtrix_Denoise_Gibbs_Eddy_Bias ' 2 -pow lowbnoisemap.mif 2 -pow -sub -abs -sqrt - -quiet | mrcalc - -finite - 0 -if tmp.mif -quiet'];
    system(cmd_str)
    cmd_str = ['mrconvert tmp.mif -grad tmp.b ' DIFF_MRtrix_Denoise_Gibbs_Eddy_Bias_Ricn ' -quiet'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    cmd_str = ['rm -f tmp.mif tmp.b'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    diffName=strcat(diffMSName, '_ricn');
else
    disp('No Ricn Denoising applied. You either chose not to use Ricn or you privided revPhase encoding for which Ricn is not supported.')
end

disp('Creating fully preprocessed dwi files in native space...');
diffFinal = fullfile(fatDir, sessid, runName, 'dwi_processed.nii.gz');
cmd_str = ['cp ' strcat(diffName,'.nii.gz') ' ' diffFinal];
system(cmd_str)

cmd_str = ['cp ' bvecMS ' ' 'dwi_processed.bvec'];
system(cmd_str)

cmd_str = ['cp ' bvalMS ' ' 'dwi_processed.bval'];
system(cmd_str)

cmd_str = ['cp topup_b0_out.nii.gz dwi_processed_b0.nii.gz'];
system(cmd_str)

disp('Cleaning up working directory...')
!rm -rf ./tmp;
end

