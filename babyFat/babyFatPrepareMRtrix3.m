
function babyFatPrepareMRtrix3(dwiDir,sessid, anatid, run)

% modify from niftisToFileBranch
% This function will take two niftis folders and turn them into the
% appropriate folder branching that we will use for the longitudinal study.
% This will create a 96dir_run1, 96dir_run2, and 96dir_concat folders. The
% first two will be used for tractography and LiFE, the concatenated data
% will be used to look at diffusion in cortex.

% Identify the two runs
subjDir = fullfile(dwiDir,sessid);
cd(subjDir);


multiShellDir=dir('*multishell*')
cd(multiShellDir.name)
niftiMultiShell = dir('*.nii.gz'); % This assumes the niftis dti data folder hasn't been renamed
niftiMultiShell = {niftiMultiShell.name};
bvalMultiShell = dir('*.bval*');
bvalMultiShell = {bvalMultiShell.name};
bvecMultiShell = dir('*.bvec*');
bvecMultiShell = {bvecMultiShell.name};

cd(fullfile(subjDir));
revPhaseDir=dir('*pe1');
if isempty(revPhaseDir)
    revPhaseDir=dir('*EPI');
end

cd(revPhaseDir.name)
niftiRevPhase = dir('*.nii.gz'); % This assumes the niftis dti data folder hasn't been renamed
niftiRevPhase = {niftiRevPhase.name};
bvalRevPhase = dir('*.bval*');
bvalRevPhase = {bvalRevPhase.name};
bvecRevPhase = dir('*.bvec*');
bvecRevPhase = {bvecRevPhase.name};

% reorgnize data directory for each run
cd(subjDir);

% rename run dir
mkdir(run);
cd(fullfile(subjDir,run));
mkdir('raw');
cd(fullfile(subjDir));
cd(multiShellDir.name);

% move data to rawdir and rename them
copyfile(niftiMultiShell{1}, fullfile(subjDir,run, 'raw/dwiMultiShell.nii.gz'));
copyfile(bvalMultiShell{1}, fullfile(subjDir,run, 'raw/dwiMultiShell.bval'));
copyfile(bvecMultiShell{1}, fullfile(subjDir,run, 'raw/dwiMultiShell.bvec'));

cd(fullfile(subjDir));
cd(revPhaseDir.name);
copyfile(niftiRevPhase{1}, fullfile(subjDir,run, 'raw/dwiRevPhase.nii.gz'));
copyfile(bvalRevPhase{1}, fullfile(subjDir,run, 'raw/dwiRevPhase.bval'));
copyfile(bvecRevPhase{1}, fullfile(subjDir,run, 'raw/dwiRevPhase.bvec'));
%system(['ln -s ' anatDir_system  ' ' anatDir_system_output]);

cd(fullfile(subjDir,run));
!rm -r t1
!rm -r dti94trilin
cmd_str=['ln -s ' fullfile(dwiDir, anatid) ' ./t1']
system(cmd_str)
end

%cd(anatDirSeg)
% niftiSeg = dir('aseg.nii.gz'); % This assumes the niftis dti data folder hasn't been renamed
% niftiSeg = {niftiSeg.name};
% copyfile(fullfile(anatDirSeg,niftiSeg{1}), fullfile(subjDir,run, 't1/aseg.nii.gz'));
% 
% niftiT1 = dir('brain.nii.gz'); % This assumes the niftis dti data folder hasn't been renamed
% niftiT1 = {niftiT1.name};
% copyfile(fullfile(anatDirSeg,niftiT1{1}), fullfile(subjDir,run, 't1/t1_brain.nii.gz'));
% 
% cd(anatDirT2)
% niftiT2 = dir('*_al_resliced_to_synt11mm.nii.gz'); % This assumes the niftis dti data folder hasn't been renamed
% niftiT2 = {niftiT2.name};
% copyfile(fullfile(anatDirT2,niftiT2{1}), fullfile(subjDir,run, 't1/t2_aligned.nii.gz'));
% cd(fullfile(subjDir,run));

% cd(anatDirMask)
% niftiMask = dir('brainMask_edited.nii.gz'); % This assumes the niftis dti data folder hasn't been renamed
% niftiMask = {niftiMask.name};
% copyfile(fullfile(anatDirMask,niftiMask{1}), fullfile(subjDir,run, 't1/brainMask.nii.gz'));
% 

%end



%     % make a concat dti folder
%     mkdir('96dir_concat');
%     % make an anatomy softlink
%     system(['ln -s ' anatDir  sessid{s} '/T1  96dir_concat/t1']);
%     
%     % concate dwi, bvec and bval
%     bvec =[];bval=[];
%     for i = 1:nRun
%         % load nifti data, but concate late
%         ni(i) = readFileNifti(sprintf('96dir_run%d/raw/run%d.nii.gz',i,i));
%         
%         % concatenate bval and bvec
%         bval = [bval, dlmread(sprintf('96dir_run%d/raw/run%d.bval',i,i))];
%         bvec = [bvec, dlmread(sprintf('96dir_run%d/raw/run%d.bvec',i,i))];
%     end
%     
%     % make raw dir
%     mkdir('96dir_concat','raw');
%     
%     % concate data
%     niConcat = ni(1);
%     niConcat.data = cat(4,ni.data);
%     % Change dimensions field in the nifti to reflect new size:
%     niConcat.dim(1,4) = size(niConcat.data,4);
%     niConcat.fname = '96dir_concat/raw/concat.nii.gz';
%     
%     % Write out the new concatenated nifti:
%     writeFileNifti(niConcat);
%     clear niConcat;
%     
%     % write concated bvec and bval
%     dlmwrite('96dir_concat/raw/concat.bvec',bvec);
%     dlmwrite('96dir_concat/raw/concat.bval',bval);



