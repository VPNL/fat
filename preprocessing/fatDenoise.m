function fatDenoise(fatDir,sessid,runName,input,output,noise)

%   fatDenoise: Takes in DWI data and denoises using mrTrix3
%   inputs:
%       fatDir = data directory 
%       sessid = subject folder name 
%       runName = run folder name 
%       input = input dwi file name 
%       output = output denoised file name
%       noise = noise file name

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

noise = fullfile(fatDir,sessid,runName,noise);
input = fullfile(fatDir,sessid,runName,input);
output = fullfile(fatDir,sessid,runName,output);

cmd_str = ['dwidenoise -extent 5,5,5 -noise ' noise ' ' input ' ' output ' -force -quiet'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);

end