function fatGibbs(fatDir,sessid,runName,input,output)

%   fatGibbs: Takes in DWI data and performs a Gibbs correction using mrTrix3
%   inputs:
%       fatDir = data directory 
%       sessid = subject folder name 
%       runName = run folder name 
%       input = input dwi file name 
%       output = output denoised file name

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

input = fullfile(fatDir,sessid,runName,input);
output = fullfile(fatDir,sessid,runName,output);

cmd_str = ['mrdegibbs -nshifts 20 -minW 1 -maxW 3 ' input ' ' output ' -quiet -force'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
end 
       