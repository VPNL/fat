function fatBiasCorrect(fatDir,sessid,runName,input,mask,bvec,bval,output)

%   fatBiasCorrect: Takes in DWI data and bias corrects using ANTs or FSL
%   inputs:
%       fatDir = data directory 
%       sessid = subject folder name 
%       runName = run folder name 
%       input = input dwi file name 
%       output = output bias corrected file file name

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

input = fullfile(fatDir,sessid,runName,input);
mask = fullfile(fatDir,sessid,runName,mask);
bvec = fullfile(fatDir,sessid,runName,'raw',bvec);
bval = fullfile(fatDir,sessid,runName,'raw',bval);
output = fullfile(fatDir,sessid,runName,output);

cmd_str = ['dwibiascorrect ants -mask ' mask ' -fslgrad ' bvec ' ' bval...
    ' -force -quiet ' input ' ' output ];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);

if ~exist(output,'file')
    warning('Dwibiascorrect failed when using the -ants option. Using -fsl option instead.');
    cmd_str = ['dwibiascorrect -mask ' mask ' -fsl '  input...
        ' -fslgrad ' bvec ' ' bval ' ' output ' -force -tempdir ./tmp -quiet'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
    warning('Dwibiascorrect is using the -fsl option.This is not recommended.');
    cmd_str = ['dwibiascorrect fsl ' input ' ' output ' -mask ' mask ' -fslgrad ' bvec ' ' bval ' -force -quiet'];
    [status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
end




end