% 
% ﻿Diffusion tool combine Vistasoft, MRtrix, LiFE and AFQ  to produce functional defined fasciculus.
%It requires these toolboxs installed, and also required the fROI defined by vistasoft. 
%The pipeline is orgnized as bellow.
%clear all;

% The following parameters need to be adjusted to fit your system
fatDir=fullfile('/sni-storage/kalanit/biac2/kgs/projects/NFA_tasks/data_mrAuto');
anatDir_system =fullfile('/biac2/kgs/3Danat');
anatDir =('/sni-storage/kalanit/biac2/kgs/3Danat');
fsDir=('/sni-storage/kalanit/biac2/kgs/3Danat/FreesurferSegmentations');

sessid={'01_sc_dti_mrTrix3_080917' '02_at_dti_mrTrix3_080517' '03_as_dti_mrTrix3_083016'...
    '04_kg_dti_mrTrix3_101014' '05_mg_dti_mrTrix3_071217' '06_jg_dti_mrTrix3_083016'...
    '07_bj_dti_mrTrix3_081117' '08_sg_dti_mrTrix3_081417' '10_em_dti_mrTrix3_080817'...
    '12_rc_dti_mrTrix3_080717' '13_cb_dti_mrTrix3_081317' '15_mn_dti_mrTrix3_091718'...
    '16_kw_dti_mrTrix3_082117' '17_ad_dti_mrTrix3_081817' '18_nc_dti_mrTrix3_090817'...
    '19_df_dti_mrTrix3_111218' '21_ew_dti_mrTrix3_111618' '22_th_dti_mrTrix3_112718'...
    '23_ek_dti_mrTrix3_113018'  '24_gm_dti_mrTrix3_112818' '25_bl_dti_mrTrix3_120718'...
    '26_mw_dti_mrTrix3_032019' '27_jk_dti_mrTrix3_032019' '28_pe_dti_mrTrix3_040319'... 
    '29_ie_dti_mrTrix3_040319' '30_pw_dti_mrTrix3_041219' '31_ks_dti_mrTrix3_041019'...
    '32_mz_dti_mrTrix3_041519' '33_mm_dti_mrTrix3_041619' '34_ans_dti_mrTrix3_041819'}

%anatid={'erica' 'th' 'ek' 'gm' 'ar'}
anatid={'siobhan' 'avt' 'anthony_new_recon_2017'...
    'kalanit_new_recon_2017' 'mareike' 'jesse_new_recon_2017'...
    'brianna' 'swaroop' 'eshed'...
'richard' 'cody' 'marisa'...
'kari' 'alexis' 'nathan'...
'dawn' 'erica' 'th'...
'ek' 'gm' 'bl'...
'mw' 'jk' 'pe'...
'ie' 'pw' 'ks' ...
'mz' 'mm' 'ans'};

runName={'96dir_run1_local'};
t1_name=['t1.nii.gz'];

lmax=8;
mrtrixversion=3;
multishell=0;
track_tool='freesurfer';
algo='IFOD1';
background=0;
verbose=1;
clobber=1;
seeding='seed_grid_per_voxel';
nSeeds=3;
ET=0;
runLife=0;
classifyConnectome = 1;
cleanConnectome = 1;

for s=1
    for r=1:length(runName)
        % Ok, here we go
        
        % %1) Prepare fat data and directory structure
        % for r=1:length(runName)
        % %
        % % %The following parameters need to be adjusted to fit your system
        %anatDir_system_current=fullfile(anatDir_system, anatid{s});
        %anatDir_system_output=fullfile('/biac2/kgs/projects/NFA_tasks/data_mrAuto/', sessid{s}, runName{r}, 't1');
        %
        % %here we go
        
        % 1) Organize the data
        %fatPrepareMRtrix3(fatDir,sessid{s}, anatDir_system_current, anatDir_system_output, r)
        
        % 2) Preprocess the data using mrTrix3
        %fatPreProcMRtrix3(fatDir,sessid{s},runName{r})
        
        %3) The preprocessing flips our bvecs. We don't want that, so we
        %copy our original bvecs from the raw folder. We also need to fix
        %the nifti header.
%         cmd_str=['mv ' fullfile(fatDir,sessid{s},runName{r},'dwi_processed.bvecs') ' ' fullfile(fatDir,sessid{s},runName{r},'dwi_processed.bve_flipped')]
%         system(cmd_str)
%         cmd_str=['cp ' fullfile(fatDir,sessid{s},runName{r},'raw','*.bvec') ' ' fullfile(fatDir,sessid{s},runName{r},'dwi_processed.bvecs')]
%         system(cmd_str)
%         
%         nii=niftiRead(fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
%         nii.phase_dim=2;
%         niftiWrite(nii,fullfile(fatDir,sessid{s},runName{r},'dwi_processed.nii.gz'));
%         
        %4) Initiate a dt.mat data structure
%        [dt6folder, dt6file]=fatCreateDT6(fatDir,sessid(s),runName(r),t1_name,1);

        %5) Set up tractography for mrtrix 3
%         anatFolder=fullfile(fsDir,anatid{s},'mri');
%         files = AFQ_mrtrixInit(dt6file, ...
%             lmax,...
%             fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix'),...
%             mrtrixversion, ...
%             multishell, ... % true/false
%             track_tool,... % 'fsl', 'freesurfer'
%             1,...
%             anatFolder);
%         
%         %6) Create a better wm mask
%         fatMakeWMmask(fatDir, anatDir_system, anatid(s), sessid(s),runName{r},t1_name,'wm', 1)
%         cmd_str=['mrconvert ' fullfile(anatDir_system, anatid{s},'wm_mask_resliced.nii.gz') ' ' fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix','wm_mask_from_freesurfer.mif')]
%         AFQ_mrtrix_cmd(cmd_str,0,1,mrtrixversion)
%         
        
%5) Create connectomes
[status, results, out_fg] = fatCreateConnectomeMRtrix3ACT(fullfile(fatDir,sessid{s},runName{r},dt6folder.name),...
    files, ...
    fullfile(fatDir,sessid{s},runName{r},dt6folder.name,'mrtrix','dwi_processed_aligned_trilin_noMEC_5tt_seed_gmwmi.mif'), ...
    algo, ...
    seeding, ...
    nSeeds, ...
    background, ...
    verbose, ... %verbose
    clobber, ... %clobber
    mrtrixversion, ...
    ET)


%6) Optional: Run LiFE to optimize the ET connectome
if runLife > 0
    fgname=out_fg;
    out_fg=fatRunLifeMRtrix3(fatDir, sessid{s}, runName{r},fgname,t1_name);
end

%7) Optional: Run AFQ to classify the fibers
if classifyConnectome >0
    fatMakefsROI(anatDir,anatid{s},sessid{s},1) % first create the ROIs needed for AFQ using freesurfer
    
    fgName=out_fg;
    out_fg=fatSegmentConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, fgName)
end

%8) Optional: Clean Connectome with AFQ
if cleanConnectome >0
    for r=1:length(runName)
        fgName=out_fg;
        out_fg=fatCleanConnectomeMRtrix3(fatDir, anatDir, anatid(s), sessid{s}, runName{r}, fgName)
    end
end
    end
end


