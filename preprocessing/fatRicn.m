function fatRicn(fatDir,sessid,runName,input,output,bvec,bval)

%   fatRicn: Takes in DWI data and do denoise using standard Rician
%   model
%   inputs:
%       fatDir = data directory 
%       sessid = subject folder name 
%       runName = run folder name 
%       input = input dwi file name 
%       output = output file with Rician correction 
%       bvec = bvec file name
%       bval = bval file name

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

input = fullfile(fatDir,sessid,runName,input);
output = fullfile(fatDir,sessid,runName,output);


cmd_str = ['mrcalc noise.nii.gz -finite noise.nii.gz 0 -if lowbnoisemap.nii.gz  -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);

cmd_str = ['mrcalc ' input ' 2 -pow lowbnoisemap.nii.gz 2 -pow -sub '...
    '-abs -sqrt - -quiet | mrcalc - -finite - 0 -if tmp.nii.gz -quiet'];
system(cmd_str)

cmd_str = ['mrconvert tmp.nii.gz -fslgrad ' bvec ' ' bval ' ' output ' -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
cmd_str = ['rm -f tmp.mif tmp.b'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
end