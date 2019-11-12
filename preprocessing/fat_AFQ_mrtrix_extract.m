function [status, results] = fat_AFQ_mrtrix_extract(files, ...
                                           multishell, ...
                                           bkgrnd, ...  
                                           verbose, ...
                                           mrtrixVersion)

%  GLU 02.2019


if notDefined('verbose'); verbose = true; end
if notDefined('bkgrnd');  bkgrnd  = false;end
if mrtrixVersion ~= 3; error('Only mrTrix version 3 supported.');end


       
% If it is multishell data, we want to extract the shell closest to 1000 for DTI       
if multishell
    bfile = dlmread(files.b);
    bvals = sort(unique(bfile(:,4)));
    if bvals(1) ~= 0; error('There is no 0 bval');end
    % Find the closest value to 1000
    [~, closestIndex] = min(abs(bvals-1000));
    singleShell = bvals(closestIndex);
    cmd_str = ['dwiextract -bzero -force  ' ...
                '-grad ' files.b ' ' ...
                '-singleshell ' ...
                '-shells 0,' num2str(singleShell) ' ' ...
                '-export_grad_mrtrix ' files.bSS ' ' ...
                 files.dwi ' ' ...
                 files.dwiSS', ...
                 '| mrmath - mean ' files.b0 ' -axis 3 -quiet'];
else
    % Create the b0 that we will copy as nifti to the /bin folder
cmd_str = ['dwiextract ' files.dwi ' - -bzero -grad ' files.b ' -quiet', ...
    '| mrmath - mean ' files.b0 ' -axis 3 -quiet'];  
end
                % create new b0 from aligned dwi data
       
   
% Send it to mrtrix:
[status,results] = AFQ_mrtrix_cmd(cmd_str,bkgrnd,verbose,mrtrixVersion);
