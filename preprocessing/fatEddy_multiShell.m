function fatEddy_multiShell(fatDir,sessid,runName,input_ms,input_rp,bvec,bval,output)

%   fatEddy_multiShell: Takes in DWI data and performs eddy current correction
%   inputs:
%       fatDir = data directory 
%       sessid = subject folder name 
%       runName = run folder name 
%       input_ms = input multishell file name 
%       input_rp = input reverse phase file name 
%       bvec = input bvec multishell file name
%       bval = input bval multishell file name
%       output = output eddy file name

bkgrnd = false;
verbose = true;
mrtrixVersion = 3;

input_ms = fullfile(fatDir,sessid,runName,input_ms);
input_ms_name = strrep(input_ms,'.nii.gz','');
input_rp = fullfile(fatDir,sessid,runName,input_rp);
input_rp_name = strrep(input_rp,'.nii.gz','');
output = fullfile(fatDir,sessid,runName,output);
bvec = fullfile(fatDir,sessid,runName,'raw',bvec);
bval = fullfile(fatDir,sessid,runName,'raw',bval);

% Check that we are working with an even number of slices

cmd_str=['mrinfo ' input_ms ' -size'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
imageSize_ms=str2num(results);

cmd_str=['mrinfo ' input_rp ' -size'];
[status,results] = AFQ_mrtrix_cmd(cmd_str, bkgrnd, verbose,mrtrixVersion);
imageSize_rp=str2num(results);

if rem(imageSize_ms(3),2)>0
    cmd_str=['fslroi ' input_ms ' '...
        strcat(input_ms_name, '_even.nii.gz')...
        ' 0 -1 0 -1 0 ' num2str(imageSize_ms(3)-1)];
    system(cmd_str)
elseif rem(imageSize_rp(3),2)>0
    cmd_str=['fslroi ' input_rp ' '...
        strcat(input_rp_name, '_even.nii.gz')...
        ' 0 -1 0 -1 0 ' num2str(imageSize_rp(3)-1)];
    system(cmd_str)
else
    cmd_str=['fslroi ' input_ms ' '...
        strcat(input_ms_name, '_even.nii.gz')...
        ' 0 -1 0 -1 0 ' num2str(imageSize_ms(3))];
    system(cmd_str)

    cmd_str=['fslroi ' input_rp ' '...
        strcat(input_rp_name, '_even.nii.gz')...
        ' 0 -1 0 -1 0 ' num2str(imageSize_rp(3))];
    system(cmd_str)
end


%Creating merged b0 reference image for topup

cmd_str=['fslroi ' strcat(input_ms_name, '_even.nii.gz')...
    ' ' strcat(strrep(input_ms,'.nii.gz',''), '_firstb0.nii.gz') ' 0 1'];
system(cmd_str)
cmd_str=['fslroi ' strcat(input_rp_name, '_even.nii.gz')...
    ' ' strcat(input_rp_name, '_firstb0.nii.gz') ' 0 1'];
system(cmd_str)

cmd_str=['fslmerge -t dwiConcat_firstb0s '...
    strcat(input_ms_name, '_firstb0.nii.gz') ' ' ...
    strcat(input_rp_name, '_firstb0.nii.gz')];
system(cmd_str)

cmd_str=['topup --imain=dwiConcat_firstb0s --datain=acq_params.txt '...
    '--config=b02b0.cnf --out=topup --iout=topup_b0_out'];
system(cmd_str)


cmd_str='fslmaths topup_b0_out -Tmean topup_b0_out';
system(cmd_str)

cmd_str='bet topup_b0_out topup_b0_out_brain -m';
system(cmd_str)

%With motion processing
cmd_str=['eddy_cuda9.1'...
    ' --mporder=3'...
    ' --slspec=./dwiSlSpec.txt'...
    ' --imain=' strcat(input_ms_name, '_even.nii.gz')...
    ' --mask=topup_b0_out_brain_mask'...
    ' --acqp=acq_params.txt'...
    ' --index=index.txt'...
    ' --bvecs=' bvec ...
    ' --bvals=' bval ...
    ' --topup=topup'...
    ' --out=' output...
    ' --repol'...
    ' --data_is_shelled'...
    ' --cnr_maps'...
    ' --residuals'];

system(cmd_str)

fatPlotMotion(strcat(output,'.eddy_movement_over_time'),'On');

end 